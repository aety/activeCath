clear; clc; ca;

dname_arr = {'20SDR-H_30_0003','20SDR-H_30_0021','20SDR-H_30_0067','20SDR-H_30_0083','20SDR-H_30_0099'}; %
cmap1 = RdBu;
cmap2 = BrBG;
n_pts = nan(5,375);

tgl_slpk = 1; % select only a certain number of peaks to plot
n_pks = 20;
tgl_cbar = 1;
tgl_save = 1;

m_dist = 5;

for dd = 1:length(dname_arr)
    
    dname = dname_arr{dd};
    
    load(['proc_auto_data_' dname]);
    load th1_arr
    
    %%
    figure; hold on;
    
    for ii = 1:length(TGL)
        
        tgl = TGL{ii};
        ref = REF(:,ii);
        PXY = BBOX{ii};
        
        tgl(isnan(PXY(:,1))) = [];
        PXY(isnan(PXY(:,1)),:) = [];
        
        PXY = repmat(ref',length(PXY),1) - PXY; %%%%%%%%%%%% plot points in relation to the reference
        
        
        
        
        
        tgl_near = RemoveOverlap(PXY,m_dist);
        tgl(~tgl_near) = [];
        PXY(~tgl_near,:) = [];
        
        
        
        % plot set 1
        yyaxis left;
        pxy1 = PXY(tgl,:);
        if tgl_slpk
            n = min([n_pks,size(pxy1,1)]); % pick the smaller between the actual number of peaks and defined threshold
            plt = nan(n_pks,2);
            plt(1:n,:) = pxy1((size(pxy1,1)+1-n):end,:); % find the last n peaks
        else
            plt = pxy1;
        end
        f = scatter(plt(:,1),plt(:,2),10,ii*ones(size(plt,1),1),'filled');
        alpha(f,0.8);
        fig = gcf;
        fig.Colormap = cmap1;
        
        
        
        % plot set 2
        yyaxis right;
        pxy2 = PXY(~tgl,:);
        if tgl_slpk
            n = min([n_pks,size(pxy2,1)]); % pick the smaller between the actual number of peaks and defined threshold
            plt = nan(n_pks,2);
            plt(1:n,:) = pxy2((size(pxy2,1)+1-n):end,:); % find the last n peaks
        else
            plt = pxy2;
        end
        f = scatter(plt(:,1),plt(:,2),10,ii*ones(size(plt,1),1),'filled');
        alpha(f,0.8);
        b = gca;
        b.Colormap = cmap2;
        
    end
    
    yyaxis left;
    axl = axis;
    yyaxis right;
    axr = axis;
    temp = [min([axl(1),axr(1)]),max([axl(2),axr(2)]),0,500];
    yyaxis left; axis(temp); yyaxis right; axis (temp);
    axis off;
    
    %%
    set(gca,'fontsize',12);
    w_ratio = diff(temp(1:2))/diff(temp(3:4));
    ht = 800;
    set(gcf,'position',[1000,100,ht*w_ratio,ht]);
    ht = 6;
    set(gcf,'paperposition',[0,0,ht*w_ratio+1,ht]);
    if tgl_save
        print('-dtiff','-r300',['proc_auto_' num2str(tgl_slpk*n_pks) '_' dname]);
        close;
    end
    
end

%%
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
        print('-dtiff','-r300',['proc_auto_cb_' num2str(cc)]);
        close;
    end
end