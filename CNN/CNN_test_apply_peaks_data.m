clear; ca; clc;

%% Load data from expTrainedExpData
fname = 'expTrainedExpData';
load ..\__experiment\roll_bend\pre_nn\positive\_pre_nn_positive_interp\interp_btw_fr_res
load ..\__experiment\roll_bend\pre_nn\positive\pre_nn_20SDF_H_30_short *_act_arr

%% extract only continuous (roll variation) data
roll_range = 13:154;
PKS1 = PKS1(:,:,roll_range,:);
PKS2 = PKS2(:,:,roll_range,:);
th_roll_act_arr = th_roll_act_arr(roll_range);

pks_range = 1:14;
PKS1 = PKS1(pks_range,:,:,:);
PKS2 = PKS2(pks_range,:,:,:);

%% modify exp data for compatibility with simulation data
% n_helix = 16; % for simulation (comparison)
PKS_scale = cell(1,size(PKS1,3)*size(PKS1,4));
b_arr = nan(size(PKS1,3)*size(PKS1,4),1); p_arr = b_arr; r_arr = b_arr;
nn = 0;

axis_lim = [0,590,-25,350];
wd = axis_lim(2)-axis_lim(1);
ht = axis_lim(4)-axis_lim(3);
imsize = [wd,ht];
I = nan(wd,ht,1,size(PKS1,3)*size(PKS1,4));

for dd = 1:size(PKS1,4) % bend
    
    for ii = 1:size(PKS1,3) % roll
        
        temp = [flipud(PKS1(:,:,ii,dd)'),flipud(PKS2(:,:,ii,dd)')]; % flip x and y
        temp0 = [ones(1,size(PKS1,1)),zeros(1,size(PKS1,1))]; % combined toggle
        
        temp1 = temp(1,:); % keep x signs
        temp2 = -temp(2,:); % flip y signs
        
        %% generate data of same configuration from simulation
        bend_arr = th_bend_act_arr(dd);
        roll_arr = th_roll_act_arr(ii);
        pitch_arr = 0;
        
        disp([num2str(ii) '/' num2str(size(PKS1,3)) ', ' num2str(dd) '/' num2str(size(PKS1,4))]);
        
        nn = nn + 1;
        PKS_scale{nn}(1,:) = temp1;
        PKS_scale{nn}(2,:) = temp2;
        PKS_scale{nn}(3,:) = temp0;
        r_arr(nn) = th_roll_act_arr(ii);
        b_arr(nn) = th_bend_act_arr(dd);
        p_arr(nn) = 0;
        
        scatter(temp1,temp2,20,'k','filled');
        axis equal;
        axis off;
        axis(axis_lim);
        
        set(gca,'position',[0,0,1,1]);
        set(gcf,'position',[0,0,wd,ht+1]);
        
        temp = getframe;
        I(:,:,1,nn) = imcomplement(mat2gray(temp.cdata(:,:,1)))';
        
        clear temp* fac*
        
    end
end

close;
save ..\..\MATLAB_largefiles\CNN_test_apply_peaks_data I b_arr r_arr imsize