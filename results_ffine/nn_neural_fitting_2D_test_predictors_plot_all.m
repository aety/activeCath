nn_arr = 1:12;

vidflag = 1;

if vidflag
    opengl('software');
    anim = VideoWriter(datestr(datetime('now'),'yyyy-mm-dd-HHMMss'),'Motion JPEG AVI');
    anim.FrameRate = 2;
    open(anim);
end

% c_arr = colormap(viridis(length(nn_arr)));
c_arr = zeros(12,3);

for nn = nn_arr
    
    load(['nn_neural_fitting_2D_test_predictors_' num2str(nn)]);
    
    hold on;
    
    plot(R_arr(:,1),'^','color',c_arr(nn,:));
    plot(R_arr(:,2),'*','color',c_arr(nn,:));
    
    box off;
    axis tight
    ylim([0,1]);
    
    legend('\theta_{rot}','\theta_{bend}','orientation','horizontal','location','south');
    xlabel('possible sets of predictors');
    ylabel('R');
    title(['n\circ of predictors per sample = ' num2str(nn)],'fontweight','normal');
    set(gca,'xtick',[0,size(R_arr,1)]);
    
    set(gca,'fontsize',14);
    set(gca,'position',[0.11,0.15,0.78,0.78]);
    set(gcf,'position',[1800,600,800,400]);
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