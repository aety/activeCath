clear; ca; clc;

%% Check Data Normalization
load C:\Users\yang\ownCloud\MATLAB_largefiles\CNN_test_apply_data

YTrain = normalize(YTrain);
YValidation = normalize(YValidation);

figure
histogram(YTrain(:,1))
figure;
histogram(YTrain(:,2))
axis tight
ylabel('Counts')
xlabel('Bend Angle')

%% Create Network Layers
FilterSize = 3; % odd number
NumFilters = 24; % number of channels, high numbers are linked to overfitting
% Stride = 1; % default
Padding = 'same';

PoolSize = 2; % 
Stride = 2; % number of pixels to skip (to decrease size)

OutputSize = 2; % number of output variables

layers = [
    % input 
    imageInputLayer([imsize, 1])
    
    convolution2dLayer(FilterSize,NumFilters,'Padding',Padding) 
    batchNormalizationLayer
    reluLayer
    
    averagePooling2dLayer(PoolSize,'Stride',Stride) % 1 
    
    convolution2dLayer(FilterSize,NumFilters,'Padding',Padding)
    batchNormalizationLayer
    reluLayer
    
    averagePooling2dLayer(PoolSize,'Stride',Stride) % 2
    
    convolution2dLayer(FilterSize,NumFilters,'Padding',Padding)
    batchNormalizationLayer
    reluLayer
    
    averagePooling2dLayer(PoolSize,'Stride',Stride) % 3 
    
    convolution2dLayer(FilterSize,NumFilters,'Padding',Padding)
    batchNormalizationLayer
    reluLayer
    
    averagePooling2dLayer(PoolSize,'Stride',Stride) % 4
    
    convolution2dLayer(FilterSize,NumFilters,'Padding',Padding)
    batchNormalizationLayer
    reluLayer
    
    averagePooling2dLayer(PoolSize,'Stride',Stride) % 5
    
    convolution2dLayer(FilterSize,NumFilters,'Padding',Padding)
    batchNormalizationLayer
    reluLayer
    
    averagePooling2dLayer(PoolSize,'Stride',Stride) % 6
    
    convolution2dLayer(FilterSize,NumFilters,'Padding',Padding)
    batchNormalizationLayer
    reluLayer
    
    convolution2dLayer(FilterSize,NumFilters,'Padding',Padding)
    batchNormalizationLayer
    reluLayer
    
    dropoutLayer(0.2)
    fullyConnectedLayer(OutputSize) % number of output variables
    regressionLayer];

%% Train Network
miniBatchSize  = 32; % ~1875/40
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

%% Test Network
YPredicted = predict(net,XValidation);

predictionError = YValidation - YPredicted;

thr = 10;
numCorrect = sum(abs(predictionError) < thr);
numValidationImages = numel(YValidation);

accuracy = numCorrect/numValidationImages;

squares = predictionError.^2;
rmse = sqrt(mean(squares));

figure;
hold on;
h = scatter(YValidation(:,1),YPredicted(:,1),10,'filled');
alpha(h,0.5);
h = scatter(YValidation(:,2),YPredicted(:,2),10,'filled');
alpha(h,0.5);
axis equal
legend('\theta_{bend}','\theta_{roll}','location','northwest');
xlabel('ground truth (norm.)');
ylabel('predicted');
box off
set(gca,'fontsize',10);
set(gcf,'paperposition',[0,0,3,3],'unit','inches');
% print('-dtiff','-r300','CNN_test_apply_peaks_corr');
% close;