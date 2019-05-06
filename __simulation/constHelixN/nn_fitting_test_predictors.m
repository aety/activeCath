%% load pre-processed data from simulation
clear;clc;ca;
load nn_fitting_pre_3D
n_train = 5; % number of times to repeat training for

n_arr = 1:8; % number of predictors to run in each simulation (nn loop)

%% generate all possible combinations (choose predictors)
n_pdt = size(PDT,1);  % number of predictors
v = 1:n_pdt;                % array of predictor labels

%%
for nn = 1:length(n_arr)
    
    n = n_arr(nn);          % number of predictors per sample
    ind_arr = combnk(v,n);  % possible combinations of predictors (choose k out of all)
    
    %%
    N_arr = cell(1,size(ind_arr,1));    % preallocate
    TR_arr = N_arr;                     % preallocate
    y_arr = N_arr;                      % preallocate
    e_arr = cell(1,size(ind_arr,1));    % preallocate
    P_arr = nan(1,size(ind_arr,1));     % preallocate
    R_arr = nan(size(ind_arr,1),size(RSP,1));     % preallocate
    
    parfor kk = 1:size(ind_arr,1)
        
        %% load predictors
        predictor = PDT(ind_arr(kk,:),:); % load predictors
        response = RSP;
        
        %% Solve an Input-Output Fitting problem with a Neural Network
        % Script generated by Neural Fitting app
        % Created 28-Sep-2018 17:13:57
        
        disp(['Training neural network with input ' num2str(kk) ' out of ' num2str(size(ind_arr,1))]);
        
        x = predictor;
        t = response;
        
        % Choose a Training Function
        % For a list of all training functions type: help nntrain
        % 'trainlm' is usually fastest.
        % 'trainbr' takes longer but may be better for challenging problems. %%%%%% SUPPORTS REGULARIZATION %%%%%%
        % 'trainscg' uses less memory. Suitable in low memory situations.
        trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.
        
        % Create a Fitting Network
        hiddenLayerSize = 10;
        net = fitnet(hiddenLayerSize,trainFcn);
        
        % Setup Division of Data for Training, Validation, Testing
        net.divideParam.trainRatio = 80/100;
        net.divideParam.valRatio = 15/100;
        net.divideParam.testRatio = 5/100;
        
        temp_net = cell(1,n_train); temp_tr = temp_net; temp_y = temp_net; temp_e = temp_net;
        temp_p = nan(n_train,1); temp_r = nan(n_train,size(RSP,1));
        
        %% repeatedly train the network and find the best
        for tt = 1:n_train
            
            % Train the Network
            [net,tr] = train(net,x,t);
            
            % Test the Network
            y = net(x);
            e = gsubtract(t,y);
            p = perform(net,t,y);
            [r,~,~] = regression(t,y);
            
            temp_net{tt} = net;
            temp_tr{tt} = tr;
            temp_y{tt} = y;
            temp_e{tt} = e;
            temp_p(tt) = p;
            temp_r(tt,:) = r;
            
        end
        
        [~,temp_i] = min(temp_p);
        
        N_arr{kk} = temp_net{temp_i};
        TR_arr{kk} = temp_tr{temp_i};
        y_arr{kk} = temp_y{temp_i};
        e_arr{kk} = temp_e{temp_i};
        P_arr(kk) = temp_p(temp_i);
        R_arr(kk,:) = temp_r(temp_i,:);
        
    end
    save(['nn_fitting_test_predictors_' num2str(nn)],'ind_arr','P_arr','R_arr','N_arr','TR_arr','e_arr','y_arr','*txt_arr');
end