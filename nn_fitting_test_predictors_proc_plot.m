clear; clc; ca;

TGL_test = 1; % plot testing set only (vs. plot all data)

fsz = 8; % major fontsize
mks = 15; % markersize

vidflag = 1;

%%
if vidflag
    fsz = fsz + 10;
    mks = 2*mks;
    opengl('software');
    anim = VideoWriter('nn_fitting_test_predictor_proc_plot','Motion JPEG AVI');
    anim.FrameRate = 1;
    open(anim);
end

if TGL_test
    ttl_txt = 'test';
else
    ttl_txt = 'train';
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
    
    if TGL_test
        ind = best_tr{nn}.testInd;
    else
        ind = best_tr{nn}.trainInd;
    end
    
    r = regression(response_org(:,ind),response_nn(:,ind));
    
    for tt = 1:length(lab)
        text(5,90-5*tt,pdt_txt_arr{lab(tt)},'fontsize',fsz-2);
    end
    
    for pp = 1:2
        a = scatter(response_org(pp,ind),response_nn(pp,ind),mks,c_arr(pp,:),'o','filled');
        alpha(a,0.4);
        text(95,90-10*pp,['R = ' num2str(r(pp),3)],'color',c_arr(pp,:),'fontsize',fsz);
    end
    
    box off;
    
    axis equal
    axis([-5,95,-5,95]);
    
    legend('\theta_{rot}','\theta_{bend}','location','southeast');
    xlabel('actual (\circ)');
    ylabel('predicted (\circ)');
    title([ttl_txt ' (n = ' num2str(length(ind)) ')'],'fontweight','normal');
    
    set(gca,'fontsize',fsz);
    set(gcf,'position',[100,150,800,600]);
    set(gcf,'color','w');
    
    if vidflag
        frame = getframe(figure(1));
        writeVideo(anim,frame);
        clf;
    else
        set(gcf,'paperposition',[0,0,4,3],'unit','inches');
        print('-dtiff','-r300',['nn_fitting_test_predictors_proc_plot__' ttl_txt '_' num2str(nn)]);
        close;
    end
    
end

if vidflag
    close(anim);
    close;
end