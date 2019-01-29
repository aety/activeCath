clear; ca; clc;
load proc_auto_data_20SDR-H_30_0003;

%%
cmap = colormap(parula(length(TGL)));
for ii = 1:length(TGL)    
    hold on;
    bbox = BBOX{ii};
    f = scatter(bbox(:,1),bbox(:,2),20,cmap(ii,:),'filled');
    alpha(f,0.5);

end