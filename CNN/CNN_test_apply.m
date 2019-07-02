clear; ca; clc;

%% Load Data
filearr = {'03','21','67','83','99'};

nn = 0;

scale_fac = 0.1;
xr = 1:650*scale_fac;
yr = 1:550*scale_fac;

imsize = [range(xr)+1,range(yr)+1];

tr_pct = 0.70;
n_fr = 375; % length(ind_arr);
trainIdx = 1:n_fr; % randperm(n_fr,round(tr_pct*n_fr));
validIdx = 1:n_fr; % validIdx(trainIdx) = [];

XTrain = nan(imsize(1),imsize(2),1,length(trainIdx)*length(filearr));
XValidation = nan(imsize(1),imsize(2),1,length(validIdx)*length(filearr));
YTrain = [];
YValidation = [];

bend_arr = 0:20:80;

for aa = 1:length(filearr)
    load(['C:\Users\yang\ownCloud\MATLAB_largefiles\__experiment\roll_bend\proc\proc_auto_data_20SDR-H_30_00' filearr{aa} '_wImage.mat']);
    
    for ff = 1:length(trainIdx)
        disp([aa,ff]);
        nn = nn + 1;
        temp = mat2gray(I_disp_arr{trainIdx(ff)});
        temp = imresize(temp,0.1);
        temp = imadjust(temp(xr,yr));
        XTrain(:,:,1,ff) = temp;
        
    end
    YTrain = [YTrain; th1_arr(ind_arr(trainIdx)),bend_arr(aa)*ones(n_fr,1)];
    
    
    for ff = 1:length(validIdx)
        temp = mat2gray(I_disp_arr{validIdx(ff)});
        temp = imresize(temp,0.1);
        temp = imadjust(temp(xr,yr));
        XValidation(:,:,1,ff) = temp;
    end
    YValidation = [YValidation; th1_arr(ind_arr(validIdx)),bend_arr(aa)*ones(n_fr,1)];
    
end

%% Check Data Normalization
figure
histogram(YTrain(:,1))
figure;
histogram(YTrain(:,2))
axis tight
ylabel('Counts')
xlabel('Bend Angle')

%% Create Network Layers
ftsize = 3;
n_output = 2;

layers = [
    imageInputLayer([imsize, 1])
    
    convolution2dLayer(ftsize,8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    averagePooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(ftsize,16,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    averagePooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(ftsize,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    convolution2dLayer(ftsize,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    dropoutLayer(0.2)
    fullyConnectedLayer(n_output) % number of output variables
    regressionLayer];

%% Train Network
miniBatchSize  = 128;
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
plot(predictionError,'*-');

% residualMatrix = reshape(predictionError,15,25);

% figure
% boxplot(residualMatrix);%,...
%     'Labels',{'0','1','2','3','4','5','6','7','8','9'})
% xlabel('Digit Class')
% ylabel('Degrees Error')
% title('Residuals')
