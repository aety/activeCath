fname = 'expTrainedExpData';
load(['nn_' fname]);

%% plot average error for all predictors

if size(pdt_arr,2)==2
    E_avg = mean(E_ARR,2);
    
    figure;
    hold on;
    
    % --------- version 1: colormap -----------
    %     colormap(hot);
    %     scatter(pdt_arr(:,1),pdt_arr(:,2),50,E_avg,'filled');
    %     cb = colorbar;
    %     ylabel(cb,['norm of all errors / no. of samples']);
    %     txt = 'cmap';
    
    % --------- version 2: markersize -----------
    scatter(pdt_arr(:,1),pdt_arr(:,2),E_avg*100/max(E_avg),'k','filled');
    text(3,3,'marker sizes \propto error');
    txt = 'dsize';
    
    set(gca,'xtick',1:length(PDT_txt),'xticklabel',PDT_txt);
    set(gca,'ytick',1:length(PDT_txt),'yticklabel',PDT_txt);
    xlabel('predictor #1');
    ylabel('predictor #2');
    xtickangle(30);
    ytickangle(30);
    
    axis equal;
    set(gca,'fontsize',8);
    set(gcf,'paperposition',[0,0,4,3]);
    print('-dtiff','-r300',['pairwisePDTplot' fname '_' txt]);
    close;
    
end