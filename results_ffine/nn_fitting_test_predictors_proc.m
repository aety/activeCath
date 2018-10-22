clear; clc; ca;
%%
nn_arr = 1:2; % subscripts of files to load

best_net = cell(1,length(nn_arr));
best_lab = best_net;
best_pdt = best_net;
best_rsp = best_net;
best_R = nan(length(nn_arr),2);
best_pfm = nan(1,length(nn_arr));

load nn_fitting_pre PDT_MX PDT_mn RSP_MX RSP_mn

for nn = nn_arr
    
    disp(['Process data from dataset ' num2str(nn)]);
    
    load(['nn_fitting_test_predictors_' num2str(nn)]);
    
    % find best results
    [Y,I] = min(P_arr);
    n = I(1);                   % best index
    net = N_arr{n};             % best neural net
    lab = ind_arr(n,:);         % best predictor labels
    pdt = nn_denormalize_Mm(PDT(lab,:),PDT_MX,PDT_mn);  % best predictors
    temp = y_arr{n};            
    rsp_nn = nn_denormalize_Mm(temp,RSP_MX,RSP_mn);% best response
    
    % save best results
    best_net{nn} = net;         % best network
    best_lab{nn} = lab;         % best labels of predictors
    best_pdt{nn} = pdt;         % best predictors
    best_rsp{nn} = rsp_nn;      % best NN response
    best_R(nn,:) = R_arr(n,:);  % best correlation coefficient
    best_pfm(nn) = P_arr(n);    % best performance        
end

response_org = nn_denormalize_Mm(RSP,RSP_MX,RSP_mn);

save('nn_fitting_test_predictors_proc','best_*','response_org');