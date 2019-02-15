clear; clc; ca;

bend_arr = 0:20:80;
n_bend = length(bend_arr);
n_pks = 20;
m_dist = 5; % minimal distance required to keep points (when removing overlaps)
y_lim = 440; % figure y-limin (pixels)

dname_arr = {'20SDR-H_30_0003','20SDR-H_30_0021','20SDR-H_30_0067','20SDR-H_30_0083','20SDR-H_30_0099'}; %

cmap1 = RdBu;
cmap2 = BrBG;

tgl_cbar = 0;
tgl_plot = 0;
tgl_svpl = 0;
tgl_save = 1;

load(['proc_auto_data_' dname_arr{1}],'ind_arr');
load th1_arr

%% name predictors and responses
% PDT_txt = {'Y_0','max(\Delta\alpha)','max(\alpha_{end})','mean(\Delta\alpha)','std(\Delta\alpha)','std(\alpha)','CV(d_{lat})','diff(mean(d_{lat}))'};
PDT_txt = {'Y_0','max(\Delta\alpha)','mean(\Delta\alpha)','std(\Delta\alpha)','std(\alpha)','CV(d_{lat})'};
RSP_txt = {'\theta_{roll}','\theta_{bend}'};

%% select only a certain range
n_roll = ind_arr(end) - ind_arr(1); % plot all
idx1 = 1; idx2 = n_roll;            % plot all

%% preallocate
n_pts = nan(5,n_roll);
XY = nan(n_pks*4,n_roll*n_bend);

PDT = nan(8,n_roll*n_bend);
RSP = nan(2,n_roll*n_bend);

nn = 0 ;

%% loop through bending angles
for dd = 1:n_bend
    
    % load data
    dname = dname_arr{dd};
    load(['proc_auto_data_' dname]);
    
    % preallocate
    PKS1 = nan(n_pks,2,length(TGL)); PKS2 = PKS1;
    
    %% find bending angles(ground truth)
    ind_0 = find(th1_arr==min(abs(th1_arr)));
    x0 = X(1:2,ind_0);
    y0 = Y(1:2,ind_0);
    th_bend_act_arr = atan2(diff(y0),diff(x0));
    th_bend_act = th_bend_act_arr*180/pi;
    
    %% loop through frames
    for ii = idx1:idx2
        
        disp([dd,ii]);
        
        % load data
        tgl = TGL{ii};
        ref = REF(:,ii);
        PXY = BBOX{ii};
        
        % subtract reference points to get relative positions
        PXY = repmat(ref',length(PXY),1) - PXY;
        
        % remove NaN's
        tgl(isnan(PXY(:,1))) = [];
        PXY(isnan(PXY(:,1)),:) = [];
        
        % separate-- set 1 -- inner
        pxy1 = PXY(tgl,:);
        pxy1 = sortrows(pxy1,2);
        n = min([n_pks,size(pxy1,1)]);  % pick the smaller between the actual and defined number of peaks
        plt1 = nan(n_pks,2);            % preallocate
        plt1(1:n,:) = pxy1(1:n,:);      % find the first n peaks
        
        % separate-- set 2 -- outer
        pxy2 = PXY(~tgl,:);
        pxy2 = sortrows(pxy2);
        n = min([n_pks,size(pxy2,1)]);  % pick the smaller between the actual number of peaks and defined threshold
        
        pxy1 = PeaksInterp(pxy1); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% interpolate gaps %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        plt2 = nan(n_pks,2);            % preallocate
        plt2(1:n,:) = pxy2(1:n,:);      % find the first n peaks
        
        %% plot
        if tgl_plot
            hold on;
            
            yyaxis left;
            plt = pxy1;
            f = scatter(plt(:,1),plt(:,2),10,ii*ones(size(plt,1),1),'filled');
            alpha(f,0.8);
            fig = gcf;
            fig.Colormap = cmap1;
            
            yyaxis right;
            plt = pxy2;
            f = scatter(plt(:,1),plt(:,2),10,ii*ones(size(plt,1),1),'filled');
            alpha(f,0.8);
            b = gca;
            b.Colormap = cmap2;
            
        end
        
        
        %% compile NN predictors (set 1 -- on the right) (set 2 -- on the left)
        nn = nn + 1; % counter
        
        slc = plt2(1,2) < plt1(1,2);    % pick a point at the lowest y-position
        temp = [plt1(1,2),plt2(1,2)];   % pick a point at the lowest y-position
        
        %         slp1 = diff(plt1(:,2))./diff(plt1(:,1)); % local slope between adjacent points (set 1)
        slp2 = diff(plt2(:,2))./diff(plt2(:,1)); % local slope between adjacent points (set 2)
        
        %         temp1 = plt1; temp1(isnan(plt1(:,1)),:) = []; temp1 = temp1([1,end],:); temp1 = diff(temp1); % x and y distances bewteen the first and last points (set 1)
        %         temp2 = plt2; temp2(isnan(plt2(:,1)),:) = []; temp2 = temp2([1,end],:); temp2 = diff(temp2); % x and y distances bewteen the first and last points (set 2)
        %         mslpend = max(abs([temp1(2)/temp1(1),temp2(2)/temp2(1)])); % take the (absolute) slope between the first and last points and pick the greater one out of the two
        
        %         dlat1 = sqrt(diff(plt1(:,2)).^2 + diff(plt1(:,1)).^2); % local lateral distance (set 1)
        dlat2 = sqrt(diff(plt2(:,2)).^2 + diff(plt2(:,1)).^2); % local lateral distance (set 2)
        %         dlat = [dlat1;dlat2]; % all local distances (both sets)
        dlat = dlat2; % all local distances (both sets)
        %         diffdlat = abs(diff([nanmean(dlat1),nanmean(dlat2)]));
        
        PDT(1,nn) = temp(slc+1);                            % predictor 1 -- Y0
        PDT(2,nn) = nanmax(abs(diff(slp2)));   % predictor 2 -- maximum local slope change
        %         PDT(2,nn) = nanmax(abs([diff(slp1);diff(slp2)]));   % predictor 2 -- maximum local slope change
        %         PDT(3,nn) = mslpend;                                % predictor 3 -- absolute slope between the first and last points
        %         PDT(4,nn) = nanmean([diff(slp1);diff(slp2)]);       % predictor 4 -- average of local slope change
        PDT(3,nn) = nanmean(diff(slp2));                  % predictor 4 -- average of local slope change
        %         PDT(5,nn) = nanstd([diff(slp1);diff(slp2)]);        % predictor 5 -- standard deviation of ALL local slope change
        PDT(4,nn) = nanstd(diff(slp2));                   % predictor 5 -- standard deviation of ALL local slope change
        %         PDT(6,nn) = nanstd([slp1;slp2]);                    % predictor 6 -- standard deviation of ALL local slope
        PDT(5,nn) = nanstd(slp2);                           % predictor 6 -- standard deviation of ALL local slope
        PDT(6,nn) = nanstd(dlat)/nanmean(dlat);             % predictor 7 -- coefficient of variation of ALL lateral distances
        %         PDT(7,nn) = diffdlat;                               % predictor 8 -- absolute difference between average lateral distances of set 1 and set 2
        
        RSP(1,nn) = th1_arr(ind_arr(ii));   % response 1 -- roll angle
        RSP(2,nn) = th_bend_act;            % response 2 -- bend angle
        
        XY(:,nn) = [plt1(:,1);plt1(:,2);plt2(:,1);plt2(:,2)]; % master storage for all all x-y points
        
    end
    
    %% format plot
    if tgl_plot
        yyaxis left;
        axl = axis;
        yyaxis right;
        axr = axis;
        temp = [min([axl(1),axr(1)]),max([axl(2),axr(2)]),0,y_lim];
        yyaxis left; axis(temp); yyaxis right; axis (temp);
        axis off;
        
        %%
        set(gca,'fontsize',12);
        w_ratio = diff(temp(1:2))/diff(temp(3:4));
        ht = 800;
        set(gcf,'position',[1000,100,ht*w_ratio,ht]);
        ht = 6;
        set(gca,'position',[0,0,1,1]);
        set(gcf,'paperposition',[0,0,ht*w_ratio+1,ht]);
        if tgl_svpl
            print('-dtiff','-r300',['pre_nn_' dname]);
            close;
        end
    end
end

if tgl_save
    save pre_nn_20SDF_H_30_short XY PDT* RSP*
end

%% colorbar
if tgl_cbar
    carr = {cmap1,cmap2};
    for cc = 1:2
        figure;
        colormap(carr{cc});
        cb = colorbar;
        th1 = th1_arr(ind_arr(1)); the = th1_arr(ind_arr(end));
        temp = interp1([0,1],[th1,the],cb.Ticks);
        cb.TickLabels = round(temp,1);
        cb.Box = 'off';
        cb.Position = [0.4, 0.1, 0.1, 0.8];
        axis off;
        ylabel(cb,'\theta_{rot}','fontsize',15);
        set(gcf,'paperposition',[0,0,6/3.5,6]);
        print('-dtiff','-r300',['pre_nn_cb_' num2str(cc)]);
        close;
    end
end