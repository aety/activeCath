clear; clc; ca;

fsz = 10; % major fontsize
mks = 10; % markersize

%%
load nn_fitting_test_predictors_proc;
load nn_fitting_pre pdt_txt_arr rsp_txt_arr

c_map = {plasma,viridis};

%%

for nn = 1:length(best_net)
    
    lab = best_lab{nn};         % best labels of predictors
    response_nn = best_rsp{nn}; % best NN response
    r = best_R(nn,:);           % best correlation coefficient
    pfm = best_pfm(nn);         % best performance
    
    c_lab = 2:-1:1;
    for pp = 1:2
        
        figure(pp); hold on;
        colormap(c_map{pp});
        
        txt_temp = strcat(pdt_txt_arr{lab});
        text(5,60,'Best predictors:','fontsize',fsz-2);
        text(10,55,txt_temp,'fontsize',fsz-2);
        
        a = scatter(response_org(pp,:),response_nn(pp,:),mks,response_org(c_lab(pp),:),'o','filled');
        alpha(a,0.7);
        
        box off;
        axis tight;
        axis equal;
        
        title(['R = ' num2str(r(pp),3)],'fontweight','normal');
        xlabel(['actual ' rsp_txt_arr{pp} '(\circ)']);
        ylabel(['predicted ' rsp_txt_arr{pp} '(\circ)']);
        
        set(gca,'fontsize',fsz);
        set(gcf,'position',[100,150,800,600]);
        set(gcf,'color','w');
        
        cb = colorbar;
        cb.Box = 'off';
        cb.Location = 'eastoutside';
        ylabel(cb,['actual ' rsp_txt_arr{c_lab(pp)} ' (\circ)']);
        
        set(gcf,'paperposition',[0,0,4,3],'unit','inches');
        print('-dtiff','-r300',['nn_fitting_test_predictors_proc_plot_sep' num2str(nn) '_' num2str(pp)]);
        close;
    end
end