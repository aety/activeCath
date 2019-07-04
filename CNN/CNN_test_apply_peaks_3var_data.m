clear; ca; clc;

%% Load data from expTrainedExpData
load C:\Users\yang\ownCloud\MATLAB\__simulation\varHelixN\3_vars\pitch_0_50\varHelixN_16\proc_findApex_3DoF_varHelixN_16

%%
axis_lim = [0,100,-5,55];
plt_scale = 5;
wd = plt_scale*(axis_lim(2)-axis_lim(1));
ht = plt_scale*(axis_lim(4)-axis_lim(3));
imsize = [wd,ht];
I = nan(wd,ht,1,size(PKS,2));

for dd = 1:size(PKS,2)
    
    temp1 = PKS{dd}(1,:);
    temp2 = PKS{dd}(2,:);
    
    scatter(temp1,temp2,20,'k','filled');
    axis equal;
    axis off;
    axis(axis_lim);
    
    set(gca,'position',[0,0,1,1]);
    set(gcf,'position',[500,500,wd,ht+1]);
    
    temp = getframe;
    I(:,:,1,dd) = imcomplement(mat2gray(temp.cdata(:,:,1)))';

end

close;
save C:\Users\yang\ownCloud\MATLAB_largefiles\CNN_test_apply_peaks_3var_data I b_arr r_arr p_arr imsize