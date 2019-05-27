%% navigate directory and load data
clear; clc; ca;

fname = 'simTrainedExpData';
cd C:\Users\yang\ownCloud\MATLAB\__simTrainedExpData\2vars
load('C:\Users\yang\ownCloud\MATLAB\__experiment\roll_bend\pre_nn\positive\_pre_nn_positive_interp\interp_btw_fr_res');
load C:\Users\yang\ownCloud\MATLAB\__experiment\roll_bend\pre_nn\positive\pre_nn_20SDF_H_30_short TIPx TIPy n_* *_act_arr

%% extract only continuous (roll variation) data
roll_range = 13:154;
PKS1 = PKS1(:,:,roll_range,:);
PKS2 = PKS2(:,:,roll_range,:);
th_roll_act_arr = th_roll_act_arr(roll_range);

%% modify exp data for compatibility with simulation data
% ref_pt = unique(REF); ref_pt = -fliplr(ref_pt);                       % flip x-y and signs

n_helix = 16;
PKS_scale = cell(1,size(PKS1,3)*size(PKS1,4));
b_arr = nan(size(PKS1,3)*size(PKS1,4),1); p_arr = b_arr; r_arr = b_arr;
nn = 0;

for dd = 1:size(PKS1,4) % bend
    
    for ii = 1:size(PKS1,3) % roll
        
        temp = [flipud(PKS1(:,:,ii,dd)'),flipud(PKS2(:,:,ii,dd)')]; % flip x and y
        temp0 = [ones(1,size(PKS1,1)),zeros(1,size(PKS1,1))]; % combined toggle
        
        temp1 = temp(1,:); % keep x signs
        temp2 = - temp(2,:); % flip y signs
        
        %% generate data of same configuration from simulation
        bend_arr = th_bend_act_arr(dd);
        roll_arr = th_roll_act_arr(ii);
        pitch_arr = 0;
        
        disp([num2str(ii) '/' num2str(size(PKS1,3)) ', ' num2str(dd) '/' num2str(size(PKS1,4))]);
        %         [x_pks,y_pks,tgl,~,~,ref_pt_sim] = proc_findApex_3DoF_varHelixN_Func(bend_arr,roll_arr,pitch_arr,n_helix);
        
        %         temp3 = x_pks - ref_pt_sim(1); % simulated peaks X
        %         temp4 = y_pks - ref_pt_sim(2); % simulated peaks Y
        
        %% scale peaks (according to a factor determined by zero angles)
        %         fac1 = rssq([range(temp1),range(temp2)]);
        %         fac3 = rssq([range(temp3),range(temp4)]);
        fac = 0.1965; % fac3/fac1; (based on ii = end, dd = 1)
        temp1 = temp1*fac;
        temp2 = temp2*fac;
        
        nn = nn + 1;
        PKS_scale{nn}(1,:) = temp1;
        PKS_scale{nn}(2,:) = temp2;
        PKS_scale{nn}(3,:) = temp0;
        r_arr(nn) = th_roll_act_arr(ii);
        b_arr(nn) = th_bend_act_arr(dd);
        p_arr(nn) = 0;
        
        %% optional debug plot
        %         hold on;
        %         h1 = plot(PKS_scale{nn}(1,:),PKS_scale{nn}(2,:),'*k');
        %         plot(PKS_scale{nn}(1,logical(temp0)),PKS_scale{nn}(2,logical(temp0)),'*r');
        %         h2 = plot(temp3,temp4,'ok');
        %         plot(temp3(tgl),temp4(tgl),'or');
        %         legend([h1,h2],'exp','sim','location','northwest');
        %         title([bend_arr,roll_arr,pitch_arr]);
        %         axis equal
        %         pause(0.01);
        %         clf;
        
        clear temp* fac*
        
    end
end


%% update peaks and reference point
ref_pt = [0,0]; % ref_pt_sim;
PKS = PKS_scale;
X = nan(100,nn);
Y = nan(100,nn);

%% compile for NN and rename
pre_nn;
PDT_exp = PDT;

%% optional comparison between EXP and SIM predictors
load C:\Users\yang\ownCloud\MATLAB\__simulation\varHelixN\2_pdt\pitch_0_0\varHelixN_16\pre_nn_findApex_3DoF_varHelixN_16 PDT
PDT_sim = PDT;
for ii = [1,4]
    plot(PDT_sim(ii,:)); hold on;
    plot(PDT_exp(ii,:),'*-','linewidth',2);
    title(ii); pause; clf;
end
PDT = PDT_exp;

%% load trained network and evaluate
load C:\Users\yang\ownCloud\MATLAB\__simulation\varHelixN\2_pdt\pitch_0_0\varHelixN_16\nn_findApex_3DoF_varHelixN_16 PDT_best Y TR NET
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
sum_e = sum(rssq(e))/length(rssq(e)); % square root of sum of all errors (averaged per sample)

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
print('-dtiff','-r300',[fname '_err3d']);
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
    print('-dtiff','-r300',[fname '_corr_' num2str(nn)]);
    close;
end