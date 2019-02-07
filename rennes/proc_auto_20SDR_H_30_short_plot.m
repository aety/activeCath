clear; clc; ca;

dname_arr = {'20SDR-H_30_0003','20SDR-H_30_0021','20SDR-H_30_0067','20SDR-H_30_0083','20SDR-H_30_0099'}; %
cmap1 = RdBu;
cmap2 = BrBG;
n_pts = nan(5,375);

tgl_slpk = 1; % select only a certain number of peaks to plot
n_pks = 20;
tgl_cbar = 0;
tgl_save = 0;



for dd = 5%1:length(dname_arr)
    
    dname = dname_arr{dd};
    
    load(['proc_auto_data_' dname]);
    load th1_arr
            
    %%
    figure; hold on;
    
    for ii = 1:length(TGL)
        tgl = TGL{ii};
        ref = REF(:,ii);
        bbox = BBOX{ii};
        tgl(isnan(bbox(:,1))) = [];
        bbox(isnan(bbox(:,1)),:) = [];
        
        bbox = repmat(ref',length(bbox),1) - bbox; %%%%%%%%%%%% plot points in relation to the reference
        
        yyaxis left;
        bbox1 = bbox(tgl,:);
        if tgl_slpk
            n = min([n_pks,size(bbox1,1)]); % pick the smaller between the actual number of peaks and defined threshold
            plt = nan(n_pks,2);
            plt(1:n,:) = bbox1((size(bbox1,1)+1-n):end,:); % find the last n peaks
        else
            plt = bbox1;
        end
        f = scatter(plt(:,1),plt(:,2),10,ii*ones(size(plt,1),1),'filled');
        alpha(f,0.8);
        fig = gcf;
        fig.Colormap = cmap1;
        
        yyaxis right;
        bbox2 = bbox(~tgl,:);
        if tgl_slpk
            n = min([n_pks,size(bbox2,1)]); % pick the smaller between the actual number of peaks and defined threshold
            plt = nan(n_pks,2);
            plt(1:n,:) = bbox2((size(bbox2,1)+1-n):end,:); % find the last n peaks
        else
            plt = bbox2;
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
    %     temp = [min([axl(1),axr(1)]),max([axl(2),axr(2)]),min([axl(3),axr(3)]),max([axl(4),axr(4)])];
    yyaxis left; axis(temp); yyaxis right; axis (temp);
    %     axis off;
    
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