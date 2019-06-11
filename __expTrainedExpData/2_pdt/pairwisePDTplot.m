fname = 'expTrainedExpData';
load(['nn_' fname]);

PDT_txt = {'Y_0','m(d_i)','sd(d_i)','m(d_i)_1 - m(d_i)_2','\alpha_{dist}','m[\Delta\alpha]','sd[\Delta\alpha]','CV[d_i]','m(d_i)_1 / m(d_i)_2'};

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
%     text(3,3,'circle size \propto error');
    txt = 'dsize';
    
    set(gca,'xtick',1:length(PDT_txt),'xticklabel',PDT_txt);
    set(gca,'ytick',1:length(PDT_txt),'yticklabel',PDT_txt);
    xlabel('predictor #1');
    ylabel('predictor #2');
    xtickangle(30);
    ytickangle(30);
    
    axis equal;
    set(gca,'fontsize',8);
    
    t = title('circle size \propto error','fontweight','normal','fontsize',12);
    t.Position(2) = t.Position(2)*1.1;
    
    set(gcf,'paperposition',[0,0,4,3.5]);
    print('-dtiff','-r300',['pairwisePDTplot' fname '_' txt]);
    close;
    
end