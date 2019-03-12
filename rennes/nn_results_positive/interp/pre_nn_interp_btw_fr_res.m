% PDT % 10x940
% PDT_txt % 1x10
% PKS1 % 20x2x188x5 
% PKS2 % 20x2x188x5 
% RSP % 2x940
% RSP_txt % 1x2
% TIPx % 1x940
% TIPy % 1x940
% XY % 80x940 xxx

%% load
clear; clc; ca;
load interp\interp_btw_fr_res

PDT_txt = {'Y_0','mean(d_i)','std(d_i)','mean(d_i)_1 - mean(d_i)_2','\alpha_e - \alpha_0',...
    'mean[\Delta\alpha]','std[\Delta\alpha]','CV[d_i]','CV[\Delta\alpha]','mean(d_i)_1 / mean(d_i)_2'};
RSP_txt = {'\theta_{roll}','\theta_{bend}'};

load ..\pre_nn_20SDF_H_30_short TIPx TIPy n_* *_act_arr

%%
PDT = nan(length(PDT_txt),n_roll*n_bend);
RSP = nan(length(RSP_txt),n_roll*n_bend);

nn = 0;

roll_range = 13:154; % 1:n_roll
pks_range = 1:14; 

for dd = 1:n_bend
    
    for ii = roll_range 
        
        plt1 = PKS1(pks_range,:,ii,dd);
        plt2 = PKS2(pks_range,:,ii,dd);
        
        nn = nn + 1; % counter
        
        slc = plt2(1,2) < plt1(1,2);    % pick a point at the lowest y-position
        temp = [plt1(1,2),plt2(1,2)];   % pick a point at the lowest y-position
        
        dlat1 = rssq(diff(plt1)')'; % local lateral distance (set 1)
        dlat2 = rssq(diff(plt2)')'; % local lateral distance (set 2)
        dlat = [dlat1;dlat2];       % all local distances (both sets)
        
        alp1 = atan2(diff(plt1(:,1)),diff(plt1(:,2))); % local slope angle (set 1)  % x-over-y to avoid inf
        alp2 = atan2(diff(plt2(:,1)),diff(plt2(:,2))); % local slope angle (set 2)  % x-over-y to avoid inf
        dalp1 = diff(alp1);
        dalp2 = diff(alp2);
        dalp = [dalp1;dalp2];
        
        PDT(1,nn) = temp(slc+1);                            % predictor 1 -- d0
        PDT(2,nn) = nanmean(dlat);                          % predictor 2 -- mean(di)
        PDT(3,nn) = nanstd(dlat);                           % predictor 3 -- std(di)
        PDT(4,nn) = nanmean(dlat1) - nanmean(dlat2);        % predictor 4 -- mean(di)_left - mean(di)_right
        PDT(5,nn) = atan2(TIPx(:,nn),TIPy(:,nn));           % predictor 5 -- alpha_e - alpha_0 (global slope angle, assuming base slope is 0)
        PDT(6,nn) = nanmean(dalp);                          % predictor 6 -- mean[del(alpha)]
        PDT(7,nn) = nanstd(dalp);                           % predictor 7 -- std[del(alpha)]
        PDT(8,nn) = nanstd(dlat)/nanmean(dlat);             % predictor 8 -- CV[di]
        PDT(9,nn) = nanstd(dalp)/nanmean(dalp);             % predictor 9 -- CV[del(alpha)]
        PDT(10,nn) = nanmean(dlat1)/nanmean(dlat2);         % predictor 10 -- mean(di)_left / mean(di)_right
        
        RSP(1,nn) = th_roll_act_arr(ii);   % response 1 -- roll angle
        RSP(2,nn) = th_bend_act_arr(dd);   % response 2 -- bend angle        
        
    end
end

tgl = isnan(RSP(1,:));
PDT(:,tgl) = [];
RSP(:,tgl) = [];

save pre_nn_interp_btw_fr_res PDT* RSP* TIPx TIPy n_roll n_bend *_act_arr *_range

%% plot predictors 
for dd = 1:size(PDT,1)
    figure;
    plot(PDT(dd,:),'.-k');
    
    title(PDT_txt{dd},'fontweight','normal');
    box off;
    axis tight;
    set(gcf,'paperposition',[0,0,2,1]);
    print('-dtiff','-r300',['pre_nn_interp_btw_fr_res_' num2str(dd)]);
    close;
end