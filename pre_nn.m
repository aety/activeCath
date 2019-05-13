% clear;
% clc;
% ca;
% fname = 'incl_pitch_manualPicking';
% fname = 'findApex_3DoF';
% load(['proc_' fname]);

PDT_txt = {'Y_0','mean(d_i)','std(d_i)','mean(d_i)_1 - mean(d_i)_2','\alpha_e - \alpha_0',...
    'mean[\Delta\alpha]','std[\Delta\alpha]','CV[d_i]','mean(d_i)_1 / mean(d_i)_2'};
RSP_txt = {'\theta_{roll}','\theta_{bend}','\theta_{pitch}'};

% n_pks = 15;
n_fr = length(p_arr);
PDT = nan(length(PDT_txt),n_fr);

%%
ref = ref_pt';

TIPx = X(1,:) - X(end,:); % catheter tip X-location % end-- base; 1--tip
TIPy = Y(1,:) - Y(end,:); % catheter tip Y-location % end-- base; 1--tip

for nn = 1:n_fr
    %% load data
    tgl = logical(TGL{nn});
    PXY = PKS{nn};
    
    % subtract reference points AND MIRROR Y-coordinates to get relative positions
    %     PXY = PXY - repmat(ref,1,length(PXY)); PXY(2,:) = -PXY(2,:);
    
    % remove NaN's
    %     tgl(isnan(PXY(:,1))) = [];
    %     PXY(isnan(PXY(:,1)),:) = [];
    
    % separate
    pxy1 = PXY(:,tgl);
    pxy2 = PXY(:,~tgl);
    if size(pxy1,1)<=2
        pxy1 = pxy1';
        pxy2 = pxy2';
    end
    plt1 = pxy1; %     plt1 = sortrows(pxy1,2);
    plt2 = pxy2; %     plt2 = sortrows(pxy2,2);
    
    %% compile NN predictors (set 1 -- on the right) (set 2 -- on the left)
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
    PDT(5,nn) = atan2(TIPx(nn),TIPy(nn));               % predictor 5 -- alpha_e - alpha_0 (global slope angle, assuming base slope is 0)
    PDT(6,nn) = nanmean(dalp);                          % predictor 6 -- mean[del(alpha)]
    PDT(7,nn) = nanstd(dalp);                           % predictor 7 -- std[del(alpha)]
    PDT(8,nn) = nanstd(dlat)/nanmean(dlat);             % predictor 8 -- CV[di]
    PDT(9,nn) = nanmean(dlat1)/nanmean(dlat2);          % predictor 9 -- mean(di)_left / mean(di)_right
%     PDT(9,nn) = nanstd(dalp)/nanmean(dalp);             % predictor 9 -- CV[del(alpha)]
    
end

RSP = [r_arr,b_arr,p_arr]';

%% plot (optional)
% scatter(X(1,:),Y(1,:),10,'k','filled');
% hold on;
% for nn = 1:n_fr
%     temp = PKS{nn};
%     scatter(temp(1,:),temp(2,:),10,1:30,'filled');
% end

%% save results
save(['pre_nn_' fname],'PDT*','RSP*','TIP*');