%% load pre-processed data from simulation
clear;clc;ca;
load nn_fitting_pre

%% generate all possible combinations (choose predictors)
n_pdt = size(predictor,1);  % number of predictors
v = 1:n_pdt;                % array of predictor labels
predictor_org = predictor;  % save original predictor array
response_org = response;    % save original response array

n_arr = 1:12;

for nn = 1:3 % :length(n_arr)
    
    n = n_arr(nn);          % number of predictors per sample
    ind_arr = combnk(v,n);  % possible combinations of predictors (choose k out of all)
    
    %%
    R_arr = nan(size(ind_arr,1),2);     % preallocate
    N_arr = cell(1,size(ind_arr,1));    % preallocate
    P_arr = nan(1,size(ind_arr,1));     % preallocate
    e_arr = cell(1,size(ind_arr,1));    % preallocate
    
    for kk = 1:size(ind_arr,1)
        
        predictor = predictor_org(ind_arr(kk,:),:);
        
        disp(['Training neural network with input ' num2str(kk) ' out of ' num2str(size(ind_arr,1))]);
        
        %% Solve an Input-Output Fitting problem with a Neural Network
        % Script generated by Neural Fitting app
        % Created 28-Sep-2018 17:13:57
        %
        % This script assumes these variables are defined:
        %
        %   predictor - input data.
        %   response - target data.
        
        x = predictor;
        t = response;
        
        % Choose a Training Function
        % For a list of all training functions type: help nntrain
        % 'trainlm' is usually fastest.
        % 'trainbr' takes longer but may be better for challenging problems.
        % 'trainscg' uses less memory. Suitable in low memory situations.
        trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.
        
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
        e = gsubtract(t,y);
        performance = perform(net,t,y);
        
        % % View the Network
        % view(net)
        
        % % Plots
        % % Uncomment these lines to enable various plots.
        %figure, plotperform(tr)
        %figure, plottrainstate(tr)
        %figure, ploterrhist(e)
        %figure, plotregression(t,y)
        %figure, plotfit(net,x,t)
        
        [r,m,b] = regression(t,y);
        
        P_arr(kk) = performance;
        R_arr(kk,:) = r;
        N_arr{kk} = net;
        e_arr{kk} = e;
        
        save temp
        
    end
    save(['nn_fitting_test_predictors_' num2str(nn)],'ind_arr','response_org','predictor_org','P_arr','R_arr','N_arr','e_arr','*txt_arr');
end