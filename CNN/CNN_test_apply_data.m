%% Load Data
filearr = {'03','21','67','83','99'};

nn = 0;

scale_fac = 1;
xr = 51:520; % 1:650*scale_fac;
yr = 101:400; % 1:550*scale_fac;

imsize = [range(xr)+1,range(yr)+1];

tr_pct = 0.70;
n_roll = 375;
n_bend = 5;
n_fr = n_roll*n_bend; % length(ind_arr);
trainIdx = randperm(n_fr,round(tr_pct*n_fr));
validIdx = 1:n_fr; validIdx(trainIdx) = [];

X = nan(imsize(1),imsize(2),1,n_fr);
Y = [];

bend_arr = 0:20:80;

for aa = 1:n_bend
    load(['C:\Users\yang\ownCloud\MATLAB_largefiles\__experiment\roll_bend\proc\proc_auto_data_20SDR-H_30_00' filearr{aa} '_wImage.mat'],'I_disp_arr','th1_arr','ind_arr');
    
    for ff = 1:n_roll
        disp([aa,ff]);
        nn = nn + 1;
        temp = mat2gray(I_disp_arr{ff});
%         temp = imresize(temp,scale_fac);
        temp = imadjust(temp(xr,yr));
        temp = imbinarize(imsharpen(temp));
        X(:,:,1,ff) = temp;
        
    end
    Y = [Y; th1_arr(ind_arr),bend_arr(aa)*ones(n_roll,1)];
        
end

XTrain = X(:,:,1,trainIdx); 
XValidation = X(:,:,1,validIdx);

YTrain = Y(trainIdx,:); 
YValidation = Y(validIdx,:);

save C:\Users\yang\ownCloud\MATLAB_largefiles\CNN_test_apply_data XValidation YValidation XTrain YTrain imsize