clear; clc; ca;

bend_arr = 0:20:80;
n_bend = length(bend_arr);
n_pks = 20;
m_dist = 5; % minimal distance required to keep points (when removing overlaps)
y_lim = [0,450]; % figure y-limin (pixels)

dname_arr = {'20SDR-H_30_0003','20SDR-H_30_0021','20SDR-H_30_0067','20SDR-H_30_0083','20SDR-H_30_0099'}; %


% r_range = [-60,60]; cmap1 = RdBu; cmap2 = BrBG; % for "both"
r_range = [0,75]; cmap1 = PuBu; cmap2 = YlOrBr; % for "positive"

tgl_cbar = 0;
tgl_plot = 1;
tgl_svpl = 1;
tgl_save = 1;

load(['proc_auto_data_' dname_arr{1}],'ind_arr');
load th1_arr

% select only a certain range
idx1 = find(th1_arr(ind_arr) < r_range(2),1);   % plot part
idx2 = find(th1_arr(ind_arr) < r_range(1),1)-1; % plot part
n_roll = idx2-idx1;                             % plot part

%% name predictors and responses

PDT_txt = {'Y_0','mean(d_i)','std(d_i)','mean(d_i)_1 - mean(d_i)_2','\alpha_e - \alpha_0',...
    'mean[\Delta\alpha]','std[\Delta\alpha]','CV[d_i]','CV[\Delta\alpha]','mean(d_i)_1 / mean(d_i)_2'};
RSP_txt = {'\theta_{roll}','\theta_{bend}'};


%% preallocate
XY = nan(n_pks*4,n_roll*n_bend);

PDT = nan(length(PDT_txt),n_roll*n_bend);
RSP = nan(length(RSP_txt),n_roll*n_bend);
TIPx = nan(1,n_roll*n_bend);
TIPy = TIPx;
PKS1 = nan(n_pks,2,n_roll,n_bend); PKS2 = PKS1;

%% loop through bending angles
nn = 0 ;
for dd = 1:n_bend
    
    % load data
    dname = dname_arr{dd};
    load(['proc_auto_data_' dname]);
    
    %% find bending angles(ground truth)
    ind_0 = find(th1_arr==min(abs(th1_arr)));
    x0 = X(1:2,ind_0);
    y0 = Y(1:2,ind_0);
    th_bend_act_arr = atan2(diff(y0),diff(x0));
    th_bend_act = th_bend_act_arr*180/pi;
    
    %% loop through frames
    for ii = idx1:idx2
        
        % load data
        tgl = TGL{ii};
        ref = REF(:,ii);
        PXY = BBOX{ii};
        
        % subtract reference points AND MIRROR Y-coordinates to get relative positions
        PXY = PXY - repmat(ref',length(PXY),1); PXY(:,2) = -PXY(:,2);
        
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
        pxy2 = sortrows(pxy2,2);
        n = min([n_pks,size(pxy2,1)]);  % pick the smaller between the actual number of peaks and defined threshold
        %         pxy2 = PeaksInterp(pxy2); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% interpolate gaps %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        plt2 = nan(n_pks,2);            % preallocate
        plt2(1:n,:) = pxy2(1:n,:);      % find the first n peaks
        
        PKS1(:,:,ii,dd) = plt1;
        PKS2(:,:,ii,dd) = plt2;
        
        %% plot
        if tgl_plot
            hold on;
            
            yyaxis left;
            plt = pxy1;
            f = scatter(plt(:,1),plt(:,2),10,ii*ones(size(plt,1),1),'filled');
            fig = gcf;
            fig.Colormap = cmap1;
            
            yyaxis right;
            plt = pxy2;
            f = scatter(plt(:,1),plt(:,2),10,ii*ones(size(plt,1),1),'filled');
            b = gca;
            b.Colormap = cmap2;
            
        end
        
        
        %% compile NN predictors (set 1 -- on the right) (set 2 -- on the left)
        nn = nn + 1; % counter
        
        TIPx(:,nn) = X(1,ii) - X(end,ii); % catheter tip X-location
        TIPy(:,nn) = Y(1,ii) - Y(end,ii); % catheter tip Y-location
        
        slc = plt2(1,2) < plt1(1,2);    % pick a point at the lowest y-position
        temp = [plt1(1,2),plt2(1,2)];   % pick a point at the lowest y-position
        
        dlat1 = rssq(diff(plt1)')'; % local lateral distance (set 1)
        dlat2 = rssq(diff(plt2)')'; % local lateral distance (set 2)
        dlat = [dlat1;dlat2];       % all local distances (both sets)
        
        alp1 = atan2(diff(plt1(:,1)),diff(plt1(:,2))); % local slope angle (set 1)  % x-over-y to avoid inf
        alp2 = atan2(diff(plt2(:,1)),diff(plt2(:,2))); % local slope angle (set 2)  % x-over-y to avoid inf
        dalp1 = diff(alp1);
        dalp2 = diff(alp2);
        dalp = [dalp1;dalp2];
        
        PDT(1,nn) = temp(slc+1);                            % predictor 1 -- d0
        PDT(2,nn) = nanmean(dlat);                          % predictor 2 -- mean(di)
        PDT(3,nn) = nanstd(dlat);                           % predictor 3 -- std(di)
        PDT(4,nn) = nanmean(dlat1) - nanmean(dlat2);        % predictor 4 -- mean(di)_left - mean(di)_right
        PDT(5,nn) = atan2(TIPx(:,nn),TIPy(:,nn));           % predictor 5 -- alpha_e - alpha_0 (global slope angle, assuming base slope is 0)
        PDT(6,nn) = nanmean(dalp);                          % predictor 6 -- mean[del(alpha)]
        PDT(7,nn) = nanstd(dalp);                           % predictor 7 -- std[del(alpha)]
        PDT(8,nn) = nanstd(dlat)/nanmean(dlat);             % predictor 8 -- CV[di]
        PDT(9,nn) = nanstd(dalp)/nanmean(dalp);             % predictor 9 -- CV[del(alpha)]
        PDT(10,nn) = nanmean(dlat1)/nanmean(dlat2);         % predictor 10 -- mean(di)_left / mean(di)_right
        
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
        temp = [min([axl(1),axr(1)]),max([axl(2),axr(2)]),y_lim];
        yyaxis left; axis(temp); yyaxis right; axis (temp);
        disp(temp);
        axis off;
        box on;
        
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
    save pre_nn_20SDF_H_30_short XY PDT* RSP* TIPx TIPy PKS*
end

%% colorbar
txt_arr = {'convex','concave'};
if tgl_cbar
    carr = {cmap1,cmap2};
    for cc = 1:2
        figure;
        colormap(carr{cc});
        axis off;
        %                 cb = colorbar;            % vertical
        cb = colorbar('southoutside'); % horizontal
        cb.Box = 'off';
        %                 cb.Position = [0.5, 0.1, 0.1, 0.8]; % vertical
        cb.Position = [0.1, 0.5, 0.8, 0.1]; % horizontal
        ylabel(cb,['\theta_{roll} ' txt_arr{cc}],'fontsize',10);
        th1 = th1_arr(ind_arr(idx1)); the = th1_arr(ind_arr(idx2));
        cb.Ticks = 0:0.2:1;
        temp = interp1([0,1],[th1,the],cb.Ticks);
        cb.TickLabels = round(temp);
        %                 set(gcf,'paperposition',[0,0,6/4.5,6]); % vertical
        set(gcf,'paperposition',[0,0,3.5,1]); % horizontal
        print('-dtiff','-r300',['pre_nn_cb_' num2str(cc)]);
        close;
    end
end