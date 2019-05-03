% clear; ca; clc;
% fname = 'findApex_3DoF';
% fname = 'incl_pitch_manualPicking';
% fname = '20SDF_H_30_short';
% fname = 'interp_btw_fr_res';

load(['pre_nn_' fname]);
n_tr = 3;
n_pdt = 3;

%% load predictors
v = 1:length(PDT_txt);

pdt_arr = nchoosek(v,n_pdt);

P_ARR = nan(length(pdt_arr),n_tr);
E_ARR = P_ARR;
TR_ARR = cell(length(pdt_arr),1);
Y_ARR = TR_ARR;
T_ARR = TR_ARR;

for ii = 1:length(pdt_arr)
    
    pp = pdt_arr(ii,:);        
    predictor = PDT(pp,:); [predictor,PS_pdt] = mapminmax(predictor); % normalization
    response = RSP; [response,PS_rsp] = mapminmax(response);         % normalization
    
    %% Solve an Input-Output Fitting problem with a Neural Network
    % Script generated by Neural Fitting app
    % Created 28-Sep-2018 17:13:57
    
    x = predictor;
    t = response;
    
    % Choose a Training Function
    % For a list of all training functions type: help nntrain
    % 'trainlm' is usually fastest.
    % 'trainbr' takes longer but may be better for challenging problems. %%%%%% SUPPORTS REGULARIZATION %%%%%%
    % 'trainscg' uses less memory. Suitable in low memory situations.
    trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.
    
    %% repeatedly train the network and find the best
    p_arr = nan(1,n_tr);
    e_arr = p_arr;
    tr_arr = cell(1,n_tr);
    y_arr = tr_arr;
    
    for nn = 1:n_tr
        
        % Create a Fitting Network
        hiddenLayerSize = 10;
        net = fitnet(hiddenLayerSize,trainFcn);
        
        % Setup Division of Data for Training, Validation, Testing
        net.divideParam.trainRatio = 70/100;
        net.divideParam.valRatio = 15/100;
        net.divideParam.testRatio = 15/100;
        
        
        % Train the Network
        [net,tr] = train(net,x,t);
        
        % Test the Network
        y = net(x);
        p = perform(net,t,y);
        
        p_arr(nn) = p;
        tr_arr{nn} = tr;
        
        y = mapminmax('reverse',y,PS_rsp); % reverse normalization
        e = gsubtract(RSP,y); % error
        e_arr(nn) = sum(rssq(e))/length(rssq(e));
        y_arr{nn} = y;
        
        clear net
        
    end
    
    P_ARR(ii,:) = p_arr;
    E_ARR(ii,:) = e_arr;
    TR_ARR{ii} = tr_arr;
    Y_ARR{ii} = y_arr;
    
end

save(['nn_' fname],'*_ARR','pdt_arr','RSP','*_txt');