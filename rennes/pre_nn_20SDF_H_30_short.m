clear; clc; ca;

tgl_cbar = 0;
tgl_save = 0;

bend_arr = 0:20:80;
n_bend = length(bend_arr);
n_pks = 20;

dname_arr = {'20SDR-H_30_0003','20SDR-H_30_0021','20SDR-H_30_0067','20SDR-H_30_0083','20SDR-H_30_0099'}; %
cmap1 = RdBu;
cmap2 = BrBG;

load(['proc_auto_data_' dname_arr{1}],'ind_arr');
load th1_arr

%% select only a certain range 
% rg = [45,-45];                    % plot some
% i1 = find(th1_arr<rg(1),1);       % plot some
% i2 = find(th1_arr<rg(2),1);       % plot some
% idx1 = i1 - ind_arr(1);           % plot some
% idx2 = idx1 + i2 - i1;            % plot some
% n_roll = idx1 - idx2;             % plot some

n_roll = ind_arr(end) - ind_arr(1); % plot all
idx1 = 1; idx2 = n_roll;            % plot all

%% preallocate
n_pts = nan(5,n_roll);
XY = nan(n_pks*4,n_roll*n_bend);
% ROLL = nan(1,n_roll*n_bend);
% BEND = ROLL;
% Y0 = nan(1,n_roll*n_bend); % distance between proximal point to reference
% DSLP = Y0;
% MSLP = Y0; 
PDT = nan(3,n_roll*n_bend);
RSP = nan(2,n_roll*n_bend);

nn = 0 ;

%% loop
for dd = 1:n_bend    
    
    dname = dname_arr{dd};
    
    load(['proc_auto_data_' dname]);    
    
    %%
    PKS1 = nan(n_pks,2,length(TGL)); PKS2 = PKS1;
    
    for ii = idx1:idx2
        tgl = TGL{ii};
        ref = REF(:,ii);
        bbox = BBOX{ii};        
        tgl(isnan(bbox(:,1))) = [];
        bbox(isnan(bbox(:,1)),:) = [];
        
        bbox = repmat(ref',length(bbox),1) - bbox; % subtract reference points to get relative positions
        
        bbox1 = bbox(tgl,:);
        n = min([n_pks,size(bbox1,1)]); % pick the smaller between the actual number of peaks and defined threshold
        plt1 = nan(n_pks,2);
        plt1(n_pks+1-n:end,:) = bbox1((size(bbox1,1)+1-n):end,:); % find the last n peaks
        plt1 = flipud(plt1); % flip the array upside down so the first element corresponds to the most proximal point
        
        bbox2 = bbox(~tgl,:);
        n = min([n_pks,size(bbox2,1)]); % pick the smaller between the actual number of peaks and defined threshold
        plt2 = nan(n_pks,2);
        plt2(n_pks+1-n:end,:) = bbox2((size(bbox2,1)+1-n):end,:); % find the last n peaks
        plt2 = flipud(plt2); % flip the array upside down so the first element corresponds to the most proximal point
        
        nn = nn + 1; % counter 
        
        slc = plt2(1,2) < plt1(1,2);    % pick a point at the lowest y-position 
        temp = [plt1(1,2),plt2(1,2)];   % pick a point at the lowest y-position 
        
        slp1 = diff(plt1(:,2))./diff(plt1(:,1));
        slp2 = diff(plt2(:,2))./diff(plt2(:,1));
        
        temp1 = plt1; temp1(isnan(plt1(:,1)),:) = []; temp1 = temp1([1,end],:); temp1 = diff(temp1);
        temp2 = plt2; temp2(isnan(plt2(:,1)),:) = []; temp2 = temp2([1,end],:); temp2 = diff(temp2);
        mslpend = max([temp1(2)/temp1(1),temp2(2)/temp2(1)]);
        
        PDT(1,nn) = temp(slc+1);                            % predictor 1 -- Y0
        PDT(2,nn) = nanmax(abs([diff(slp1);diff(slp2)]));   % predictor 2 -- maximum local slope change
        PDT(3,nn) = mslpend;                                % predictor 3 -- slope between the first and last points
        
        RSP(1,nn) = th1_arr(ind_arr(ii));   % response 1 -- roll angle
        RSP(2,nn) = bend_arr(dd);           % response 2 -- bend angle
        
        XY(:,nn) = [plt1(:,1);plt1(:,2);plt2(:,1);plt2(:,2)]; % master storage for all all x-y points 
        
    end
end

PDT_txt = {'Y_0','max(\Delta\alpha)','max(\alpha_{end})'};
RSP_txt = {'\theta_{roll}','\theta_{bend}'};

save pre_nn_20SDF_H_30_short XY PDT* RSP*