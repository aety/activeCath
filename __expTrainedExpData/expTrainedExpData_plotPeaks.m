%% navigate directory and load data
clear; clc; ca;

fname = 'expTrainedExpData';
cd C:\Users\yang\ownCloud\MATLAB\__simTrainedExpData
load('C:\Users\yang\ownCloud\MATLAB\__experiment\roll_bend\pre_nn\positive\_pre_nn_positive_interp\interp_btw_fr_res');

%% extract only continuous (roll variation) data
roll_range = 13:154;
PKS1 = PKS1(:,:,roll_range,:);
PKS2 = PKS2(:,:,roll_range,:);

pks_range = 1:14;
PKS1 = PKS1(pks_range,:,:,:);
PKS2 = PKS2(pks_range,:,:,:);

%% modify exp data for compatibility with simulation data
PKS_scale = cell(1,size(PKS1,3)*size(PKS1,4));
b_arr = nan(size(PKS1,3)*size(PKS1,4),1); p_arr = b_arr; r_arr = b_arr;
nn = 0;

for dd = 1:size(PKS1,4) % bend
    
    figure;
    
    for ii = 1:size(PKS1,3) % roll
        
        temp = [flipud(PKS1(:,:,ii,dd)'),flipud(PKS2(:,:,ii,dd)')]; % flip x and y
        temp0 = [ones(1,size(PKS1,1)),zeros(1,size(PKS1,1))]; % combined toggle
        
        temp1 = temp(1,:); % keep x signs
        temp2 = - temp(2,:); % flip y signs
        
        %% generate data of same configuration from simulation        
        disp([num2str(ii) '/' num2str(size(PKS1,3)) ', ' num2str(dd) '/' num2str(size(PKS1,4))]);
        
        nn = nn + 1;
        PKS_scale{nn}(1,:) = temp1;
        PKS_scale{nn}(2,:) = temp2;
        PKS_scale{nn}(3,:) = temp0;        
        
        hold on;
        scatter(PKS_scale{nn}(1,:),PKS_scale{nn}(2,:),10,ii*ones(1,length(PKS_scale{nn})),'filled');
        
    end
    axis equal
end