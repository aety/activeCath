clear; ca; clc;

%% Load images
p_range = [-25,25];

load(['..\..\MATLAB_largefiles\CNN_test_apply_peaks_3var_data_'...
    num2str(p_range(1)) '_' num2str(p_range(2))]);

tr_pct = 0.7;
va_pct = 0.15;
te_pct = 0.15;

X = I;
Y = normalize([b_arr,r_arr,p_arr]);

n_fr = size(I,4);
n_fr_te = round(n_fr*te_pct);
n_fr_tr = round(n_fr*tr_pct);
n_fr_va = n_fr - n_fr_te - n_fr_tr;
rand_ind = randperm(n_fr);
Train_ind = rand_ind(1:n_fr_tr);
Validation_ind = rand_ind(n_fr_tr+(1:n_fr_va));
Test_ind = rand_ind((n_fr_tr+n_fr_va+1):end);

XTrain = X(:,:,:,Train_ind);
YTrain = Y(Train_ind,:);
XValidation = X(:,:,:,Validation_ind);
YValidation = Y(Validation_ind,:);
XTest = X(:,:,:,Test_ind);
YTest = Y(Test_ind,:);

%% Check Data Normalization
for ii = 1:size(YTrain,2)
    figure;
    histogram(YTrain(:,ii))
    axis tight
    ylabel('Counts')
    xlabel(['Predictor' num2str(ii)]);
end

%% Create Network Layers
FilterSize = 3;  % a small odd number
NumFilters = 30; % related to the variety of patterns to capture
OutputSize = 3;  % number of output variables
PoolSize = 2;    % size of pooling (grouping of convolved maps)

layers = [
    imageInputLayer([imsize, 1])
    
    convolution2dLayer(FilterSize,NumFilters,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    averagePooling2dLayer(PoolSize,'Stride',2) % 1
    
    convolution2dLayer(FilterSize,NumFilters,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    averagePooling2dLayer(PoolSize,'Stride',2) % 2
    
    convolution2dLayer(FilterSize,NumFilters,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    averagePooling2dLayer(PoolSize,'Stride',2) % 3
    
    convolution2dLayer(FilterSize,NumFilters,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    averagePooling2dLayer(PoolSize,'Stride',2) % 4
    
    convolution2dLayer(FilterSize,NumFilters,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    averagePooling2dLayer(PoolSize,'Stride',2) % 5
    
    convolution2dLayer(FilterSize,NumFilters,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    averagePooling2dLayer(PoolSize,'Stride',2) % 6
    
    convolution2dLayer(FilterSize,NumFilters,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    convolution2dLayer(FilterSize,NumFilters,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    dropoutLayer(0.2)
    fullyConnectedLayer(OutputSize) % number of output variables
    regressionLayer];

%% Train Network
miniBatchSize  = 64; % ~2341/40
validationFrequency = floor(numel(YTrain)/miniBatchSize);
options = trainingOptions('sgdm', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',30, ...
    'InitialLearnRate',1e-3, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.1, ...
    'LearnRateDropPeriod',20, ...
    'Shuffle','every-epoch', ...
    'ValidationData',{XValidation,YValidation}, ...
    'ValidationFrequency',validationFrequency, ...
    'Plots','training-progress', ...
    'Verbose',false);

net = trainNetwork(XTrain,YTrain,layers,options);

net.Layers;

save(['CNN_test_apply_peaks_3var_' num2str(p_range(1)) '_' num2str(p_range(2))],...
    'net','XValidation','XTrain','YValidation','YTrain','XTest','YTest','miniBatchSize','PoolSize','OutputSize','NumFilters','FilterSize');

%% Test Network
load(['CNN_test_apply_peaks_3var_' num2str(p_range(1)) '_' num2str(p_range(2))]);

YPredicted = predict(net,XTest);

a = YTest;
b = YPredicted;

predictionError = a - b;

r = regression(a', b');
squares = predictionError.^2;
rmse = sqrt(mean(squares));

%% plot results
RSP_txt = {'\theta_{bend}','\theta_{roll}','\theta_{pitch}'};

for rr = 1:numel(r)
    
    figure;
    hold on;
    h = scatter(a(:,rr),b(:,rr),40,'k','filled');
    alpha(h,0.25);
    title(['R = ' num2str(r(rr),3) ' (n = ' num2str(length(a)) ')'],'fontsize',12,'fontweight','normal');
    axis tight;
    
    temp = [get(gca,'xlim');get(gca,'ylim')];
    temp2 = max(temp(:,2)); temp1 = min(temp(:,1));
    
    ax = xlabel(['actual ' RSP_txt{rr}  ' (deg)']);
    ay = ylabel('NN output');
    set(gca,'fontsize',20);
    set(gcf,'paperposition',[0,0,4,4.5]);
    print('-dtiff','-r300',['CNN_test_apply_peaks_3var_' num2str(p_range(1)) '_' num2str(p_range(2)) '_' num2str(rr)]);
    close;
end