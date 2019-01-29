clear; ca; clc;
load proc_auto_data_20SDR-H_30_0003;

%%

for ii = 1:length(TGL)
    
    hold on;
    plot(Y(end,ii),X(end,ii),'*');
    axis equal
    
end