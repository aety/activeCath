clear; ca; clc;

tgl_cbar = 0;
tgl_save = 0;

n_roll = 375;
bend_arr = 0:20:80;
n_bend = length(bend_arr);
n_pks = 20;

dname_arr = {'20SDR-H_30_0003','20SDR-H_30_0021','20SDR-H_30_0067','20SDR-H_30_0083','20SDR-H_30_0099'}; %
cmap1 = RdBu;
cmap2 = BrBG;
n_pts = nan(5,n_roll);

%% preallocate
XY = nan(n_pks*4,n_roll*n_bend);
ROLL = nan(1,n_roll*n_bend);
BEND = ROLL;

%% loop
for dd = 1:n_bend
    
    dname = dname_arr{dd};
    
    load(['proc_auto_data_' dname]);
    load th1_arr
    
    %%
    PKS1 = nan(n_pks,2,length(TGL)); PKS2 = PKS1;
    
    for ii = 1:n_roll
        tgl = TGL{ii};
        bbox = BBOX{ii};
        tgl(isnan(bbox(:,1))) = [];
        bbox(isnan(bbox(:,1)),:) = [];
        
        bbox1 = bbox(tgl,:);
        n = min([n_pks,size(bbox1,1)]); % pick the smaller between the actual number of peaks and defined threshold
        plt1 = nan(n_pks,2);
        plt1(1:n,:) = bbox1((size(bbox1,1)+1-n):end,:); % find the last n peaks
        
        bbox2 = bbox(~tgl,:);
        n = min([n_pks,size(bbox2,1)]); % pick the smaller between the actual number of peaks and defined threshold
        plt2 = nan(n_pks,2);
        plt2(1:n,:) = bbox2((size(bbox2,1)+1-n):end,:); % find the last n peaks
        
        %         PKS1(:,:,ii) = plt1;
        %         PKS2(:,:,ii) = plt2;
        
        nn = ii + (dd-1)*length(TGL);
        
        XY(:,nn) = [plt1(:,1);plt1(:,2);plt2(:,1);plt2(:,2)];
        ROLL(nn) = th1_arr(ind_arr(ii));
        BEND(nn) = bend_arr(dd);
    end
end

save pre_nn_20SDF_H_30_short XY ROLL BEND
