%%
clear; clc; ca;

%%
load nn_fitting_pre PDT RSP

%%
n_layer_max = 20;

x = PDT([45,65],:);
t = RSP;

%% Choose a Training Function
% For a list of all training functions type: help nntrain
% 'trainlm' is usually fastest.
% 'trainbr' takes longer but may be better for challenging problems.
% 'trainscg' uses less memory. Suitable in low memory situations.
trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.


temp_net = cell(1,n_layer_max); temp_y = temp_net; temp_e = temp_net;
temp_p = nan(n_layer_max,1); temp_r = nan(n_layer_max,2);

parfor tt = 1:n_layer_max
    
    % Create a Fitting Network
    hiddenLayerSize = tt;
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
    p = perform(net,t,y);
    [r,~,~] = regression(t,y);
    
    temp_net{tt} = net;
    temp_y{tt} = y;
    temp_e{tt} = e;
    temp_p(tt) = p;
    temp_r(tt,:) = r;
    
end