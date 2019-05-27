%% navigate directory and load data
clear; clc; ca;
fname = 'proc_incl_pitch_manualPicking_new';
cd C:\Users\yang\ownCloud\MATLAB\__simTrainedExpData\3vars
load(['C:\Users\yang\ownCloud\MATLAB\__experiment\roll_bend_pitch\proc\' fname]);

%% modify exp data for compatibility with simulation data
X = -flipud(X); % flip x-y
Y = -flipud(Y); % flip x-y

ref_pt = -fliplr(ref_pt);                       % flip x-y and signs

n_helix = 16;
PKS_scale = cell(1,75);
PKS_org = PKS;

for ii = 1:length(PKS)
    
    temp = -flipud(PKS_org{ii}(1:2,:)); % flip pks (x and y) and signs
    temp0 = -PKS_org{ii}(3,:) + 1;      % flip toggle
    
    temp1 = temp(1,:) - ref_pt(1);  % offset experimental peaks X
    temp2 = temp(2,:) - ref_pt(2);  % offset experimental peaks Y
    
    %% generate data of same configuration from simulation
    bend_arr = b_arr(ii);
    roll_arr = r_arr(ii);
    pitch_arr = p_arr(ii);
    
    disp([num2str(ii) '/' num2str(length(PKS))]);
    [x_pks,y_pks,tgl,~,~,ref_pt_sim] = proc_findApex_3DoF_varHelixN_Func(bend_arr,roll_arr,pitch_arr,n_helix);
    
    temp3 = x_pks - ref_pt_sim(1); % simulated peaks X
    temp4 = y_pks - ref_pt_sim(2); % simulated peaks Y
    
    %% scale peaks (according to a factor determined by zero angles)
    fac1 = rssq([range(temp1),range(temp2)]);
    fac3 = rssq([range(temp3),range(temp4)]);
    fac = 0.1833; % 0.9*fac3/fac1;
    temp1 = temp1*fac;
    temp2 = temp2*fac;
    
    PKS_scale{ii}(1,:) = temp1;
    PKS_scale{ii}(2,:) = temp2;
    PKS_scale{ii}(3,:) = temp0;
    
    %% optional debug plot
    %     hold on;
    %     plot(PKS_scale{ii}(1,:),PKS_scale{ii}(2,:),'*k');
    %     plot(PKS_scale{ii}(1,logical(temp0)),PKS_scale{ii}(2,logical(temp0)),'*r');
    %     plot(temp3,temp4,'ok');
    %     plot(temp3(tgl),temp4(tgl),'or');
    %     legend('exp','sim','location','northwest');
    %     title([bend_arr,roll_arr,pitch_arr]);
    %     axis equal
    %     pause;
    %     clf;
    
    clear temp* fac*
    
end

%% update peaks and reference point
ref_pt = ref_pt_sim;
PKS = PKS_scale;

%% compile for NN and rename
pre_nn;
PDT_exp = PDT;

%% optional comparison between EXP and SIM predictors
% % load C:\Users\yang\ownCloud\MATLAB\__simulation\varHelixN\pitch_0_50\varHelixN_16\pre_nn_findApex_3DoF_varHelixN_16 PDT
% %
% % for ii = 4:6
% %     plot(PDT(ii,:)); hold on;
% %     plot(PDT_exp(ii,:),'*-','linewidth',2);
% %     title(ii); pause; clf;
% % end

%% load trained network and evaluate
load C:\Users\yang\ownCloud\MATLAB\__simulation\varHelixN\3_pdt\pitch_0_50\varHelixN_16\nn_findApex_3DoF_varHelixN_16 PDT_best Y TR NET
net = NET;
pp = PDT_best;
predictor = PDT(pp,:); % [predictor,PS_pdt] = mapminmax(predictor); % normalization
response = RSP; % [response,PS_rsp] = mapminmax(response);         % normalization

x = predictor;
t = response;

y = net(x);
p = perform(net,t,y);

% y = mapminmax('reverse',y,PS_rsp); % reverse normalization
e = gsubtract(RSP,y); % error
% sum_e = sum(rssq(e))/length(rssq(e)); % square root of sum of all errors (averaged per sample)

%% plot results
% 4D error plot (error as functions of variables)
figure; hold on;
scatter3(RSP(1,:),RSP(2,:),RSP(3,:),[],sum(abs(e)),'filled');
xlabel(RSP_txt{1});
ylabel(RSP_txt{2});
zlabel(RSP_txt{3});
cb = colorbar;
ylabel(cb,'sum of all errors (deg');
view(3);
grid on;
set(gca,'fontsize',8);
set(gcf,'paperposition',[0,0,4,3],'unit','inches');
print('-dtiff','-r300','simTrainedExpData_err3d');
close;

% separate correlation plots
for nn = 1:size(RSP,1)
    temp = [min(min(RSP(nn,:))),max(max(RSP(nn,:)))];
    figure; hold on;
    plot(temp,temp,'k');
    h(nn) = scatter(RSP(nn,:),y(nn,:),'filled'); % plot correlation
    r = regression(RSP(nn,:),y(nn,:));
    alpha(h(nn),0.5);
    
    axis equal
    title(num2str(r));
    xlabel(RSP_txt{nn});
    ylabel('NN output');
    set(gca,'fontsize',8);
    set(gcf,'paperposition',[0,0,3,3],'unit','inches');
    print('-dtiff','-r300',['simTrainedExpData_corr_' num2str(nn)]);
    close;
end