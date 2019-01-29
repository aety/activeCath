clear; ca; clc;

dname_arr = {'20SDR-H_30_0003','20SDR-H_30_0021','20SDR-H_30_0067','20SDR-H_30_0083','20SDR-H_30_0099'}; %

for dd = 1:length(dname_arr)
    
    clearvars -except dd dname_arr
    
    dname = dname_arr{dd};
    
    load(['proc_auto_data_' dname]);
    load th1_arr
    
    %%
    cmap = colormap(parula(length(TGL)));
    for ii = 1:length(TGL)
        hold on;
        bbox = BBOX{ii};
        f = scatter(bbox(:,1),bbox(:,2),20,cmap(ii,:),'filled');
        alpha(f,0.5);
    end
    
    cb = colorbar;
    th1 = th1_arr(ind_arr(1)); the = th1_arr(ind_arr(end));
    temp = interp1([0,1],[th1,the],cb.Ticks);
    cb.TickLabels = round(temp,1);
    cb.Box = 'off';
    
    axis tight;
    axis off;
    temp = [get(gca,'xlim'),get(gca,'ylim')];
    
    w_ratio = diff(temp(1:2))/diff(temp(3:4));
    ht = 800;
    set(gcf,'position',[100,100,ht*w_ratio,ht]);
    ht = 6;
    set(gcf,'paperposition',[0,0,ht*w_ratio+1,ht]);
    print('-dtiff','-r300',['plot_pre_nn_' dname]);
    close;
    
end
