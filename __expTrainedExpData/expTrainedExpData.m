%% navigate directory and load data
clear; clc; ca;

fname = 'expTrainedExpData';
load C:\Users\yang\ownCloud\MATLAB\__experiment\roll_bend\pre_nn\positive\_pre_nn_positive_interp\interp_btw_fr_res
load C:\Users\yang\ownCloud\MATLAB\__experiment\roll_bend\pre_nn\positive\pre_nn_20SDF_H_30_short *_act_arr

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
        %         [x_pks,y_pks,tgl,~,~,ref_pt_sim] = proc_findApex_3DoF_varHelixN_Func(bend_arr,roll_arr,pitch_arr,n_helix);
        %
        %         temp3 = x_pks - ref_pt_sim(1); % simulated peaks X
        %         temp4 = y_pks - ref_pt_sim(2); % simulated peaks Y
        
        %% scale peaks (according to a factor determined by zero angles)
        %         fac1 = rssq([range(temp1),range(temp2)]);
        %         fac3 = rssq([range(temp3),range(temp4)]);
        %         fac = 0.1965; % fac3/fac1; % (based on ii = end, dd = 1)
        %         temp1 = temp1*fac;
        %         temp2 = temp2*fac;
        
        nn = nn + 1;
        PKS_scale{nn}(1,:) = temp1;
        PKS_scale{nn}(2,:) = temp2;
        PKS_scale{nn}(3,:) = temp0;
        r_arr(nn) = th_roll_act_arr(ii);
        b_arr(nn) = th_bend_act_arr(dd);
        p_arr(nn) = 0;
        
        %% optional debug plot
        %         hold on;
        %         h1 = plot(PKS_scale{nn}(1,:),PKS_scale{nn}(2,:),'*k');
        %         plot(PKS_scale{nn}(1,logical(temp0)),PKS_scale{nn}(2,logical(temp0)),'*r');
        %         text(PKS_scale{nn}(1,1),PKS_scale{nn}(2,1),'1');
        %         %         h2 = plot(temp3,temp4,'ok');
        %         %         plot(temp3(tgl),temp4(tgl),'or');
        %         %         legend([h1,h2],'exp','sim','location','northwest');
        %         %         title([bend_arr,roll_arr,pitch_arr]);
        %         %         axis equal
        %         pause;%(0.01);
        %         clf;
        
        clear temp* fac*
        
    end
end

%% update peaks and reference point
ref_pt = [0,0];
PKS = PKS_scale;
X = nan(100,nn);
Y = nan(100,nn);

%% compile for NN and rename
pre_nn;
RSP = RSP(1:2,:); RSP_txt = RSP_txt(1:2);
n_pdt = 2;
nn_training;
nn_plot;