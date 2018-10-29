clear; clc; ca;
%%
nn_arr = 1:7; % subscripts of files to load

best_net = cell(1,length(nn_arr));
best_tr = best_net;
best_lab = best_net;
best_pdt = best_net;
best_rsp = best_net;

load nn_fitting_pre PDT PDT_MX PDT_mn RSP RSP_MX RSP_mn

for nn = nn_arr
    
    disp(['Process data from dataset ' num2str(nn)]);
    
    load(['nn_fitting_test_predictors_' num2str(nn)]);
    
    % find best results
    [~,n] = min(P_arr);         % best index
    net = N_arr{n};             % best neural net
    tr = TR_arr{n};             % training parameters of the best neural net
    lab = ind_arr(n,:);         % best predictor labels
    pdt = nn_denormalize_Mm(PDT(lab,:),PDT_MX,PDT_mn);  % best predictors    
    rsp_nn = nn_denormalize_Mm(y_arr{n},RSP_MX,RSP_mn); % best response
    
    % save best results
    best_net{nn} = net;         % best neural net
    best_tr{nn} = tr;           % training parameters of the best neural net
    best_lab{nn} = lab;         % best predictor labels
    best_pdt{nn} = pdt;         % best predictors
    best_rsp{nn} = rsp_nn;      % best response    
end

response_org = nn_denormalize_Mm(RSP,RSP_MX,RSP_mn);

save('nn_fitting_test_predictors_proc','best_*','response_org');