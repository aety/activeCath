clear; clc; ca;

fsz = 10; % major fontsize
mks = 10; % markersize

vidflag = 0;

if vidflag
    opengl('software');
    anim = VideoWriter(datestr(datetime('now'),'yyyy-mm-dd-HHMMss'),'Motion JPEG AVI');
    anim.FrameRate = 1;
    open(anim);
end


%%
load nn_fitting_test_predictors_proc;
load nn_fitting_pre pdt_txt_arr 

%%

for nn = 1:length(best_net)
    
    c_arr = colormap(lines(2));
    hold on;
    
    text(0,90,'Best predictors:','fontsize',fsz-2);
    
    lab = best_lab{nn};         % best labels of predictors
    response_nn = best_rsp{nn}; % best NN response
    r = best_R(nn,:);             % best correlation coefficient
    pfm = best_pfm(nn);         % best performance
    
    txt_temp = strcat(pdt_txt_arr{lab});
    text(5,85,txt_temp,'fontsize',fsz-2);
    
    
    text(0,80,'Performance:','fontsize',fsz-2);
    text(5,75,num2str(pfm,3),'fontsize',fsz-2);
    
    for pp = 1:2
        a = scatter(response_org(pp,:),response_nn(pp,:),mks,c_arr(pp,:),'o','filled');
        alpha(a,0.4);
        text(95,90-10*pp,['R = ' num2str(r(pp),3)],'color',c_arr(pp,:),'fontsize',fsz);
    end
    
    box off;
    
    axis equal
    axis([-5,95,-5,95]);
    
    legend('\theta_{rot}','\theta_{bend}','location','southeast');
    xlabel('actual (\circ)');
    ylabel('predicted (\circ)');
    title(['n\circ of predictors per sample = ' num2str(length(best_lab{nn}))],'fontweight','normal');
    
    set(gca,'fontsize',fsz);
    set(gcf,'position',[100,150,800,600]);
    set(gcf,'color','w');
    
    if vidflag
        frame = getframe(figure(1));
        writeVideo(anim,frame);
        clf;
    else
        set(gcf,'paperposition',[0,0,4,3],'unit','inches');
        print('-dtiff','-r300',['nn_fitting_test_predictors_proc_plot_' num2str(nn)]);
        close;
    end
    
end


if vidflag
    close(anim);
    close;
end