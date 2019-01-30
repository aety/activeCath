clear; ca; clc;

dname_arr = {'20SDR-H_30_0003','20SDR-H_30_0021','20SDR-H_30_0067','20SDR-H_30_0083','20SDR-H_30_0099'}; %
cmap1 = RdBu;
cmap2 = BrBG;

n_pts = nan(5,375);

for dd = 1%:length(dname_arr)
    
    clearvars -except dd dname_arr n_pts cmap*
    
    dname = dname_arr{dd};
    
    load(['proc_auto_data_' dname]);
    load th1_arr
    
    %%
    figure; hold on;
    NN = length(TGL);
    
    for ii = 1:length(TGL)
        bbox = BBOX{ii};
        tgl = TGL{ii};
        
        yyaxis left;
        f = scatter(bbox(tgl,1),bbox(tgl,2),10,ii*ones(size(bbox(tgl,1))),'filled');
        alpha(f,0.8);
        fig = gcf;
        fig.Colormap = cmap1;
        
        yyaxis right;
        f = scatter(bbox(~tgl,1),bbox(~tgl,2),10,ii*ones(size(bbox(~tgl,1))),'filled');
        alpha(f,0.8);
        b = gca;
        b.Colormap = cmap2;
        
        NN(dd,ii) = length(bbox);
    end
    
    yyaxis left;
    axl = axis;
    yyaxis right;
    axr = axis;
    temp = [min([axl(1),axr(1)]),max([axl(2),axr(2)]),min([axl(3),axr(3)]),max([axl(4),axr(4)])];
    yyaxis left; axis(temp); yyaxis right; axis (temp);
    axis off;
    
    %%
    w_ratio = diff(temp(1:2))/diff(temp(3:4));
    ht = 800;
    set(gcf,'position',[1000,100,ht*w_ratio,ht]);
    ht = 6;
    set(gcf,'paperposition',[0,0,ht*w_ratio+1,ht]);
    print('-dtiff','-r300',['plot_pre_nn_' dname]);
    savefig(['plot_pre_nn_' dname]);
    close;
    
    %%
    
    carr = {cmap,cmap2};
    for cc = 1:2
        figure;
        colormap(carr{cc});
        cb = colorbar;
        th1 = th1_arr(ind_arr(1)); the = th1_arr(ind_arr(end));
        temp = interp1([0,1],[th1,the],cb.Ticks);
        cb.TickLabels = round(temp,1);
        cb.Box = 'off';
        cb.Position = [0.4, 0.1, 0.2, 0.8];
        axis off;
        ylabel(cb,'\theta_{rot}');
        
        set(gcf,'paperposition',[0,0,6/3.5,6]);
        print('-dtiff','-r300',['plot_pre_nn_cb' num2str(cc)]);
        close;
    end   
    
    
end
