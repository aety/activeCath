nn_arr = 1:12;

vidflag = 1;

if vidflag
    opengl('software');
    anim = VideoWriter(datestr(datetime('now'),'yyyy-mm-dd-HHMMss'),'Motion JPEG AVI');
    anim.FrameRate = 2;
    open(anim);
end

for nn = nn_arr
    
    load(['nn_neural_fitting_2D_test_predictors_' num2str(nn)]);
    
    hold on;
    
    h1 = scatter(1:length(R_arr(:,1)),R_arr(:,1),60,'dk','filled');
    h2 = scatter(1:length(R_arr(:,2)),R_arr(:,2),60,'ok','filled');
    alpha(h1,0.3);
    alpha(h2,0.3);
    
    box off;
    axis tight
    ylim([0,1]);
    
    legend('\theta_{rot}','\theta_{bend}','orientation','horizontal','location','south');
    xlabel('possible sets of predictors');
    ylabel('R');
    title([num2str(nn) ' predictors per sample'],'fontweight','normal');
    set(gca,'xtick',[0,size(R_arr,1)]);
    
    set(gca,'fontsize',14);
    set(gca,'position',[0.11,0.15,0.78,0.78]);
    set(gcf,'position',[100,200,800,400]);
    set(gcf,'color','w');
    
    if vidflag
        frame = getframe(figure(1));
        writeVideo(anim,frame);
    else
        pause;
    end
    clf;
end

if vidflag
    close(anim);
    close;
end