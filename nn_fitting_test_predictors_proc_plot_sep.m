clear; clc; ca;

TGL_test = 1; % plot testing set only (vs. plot all data)

fsz = 10; % major fontsize
mks = 10; % markersize

%%
c_map = {plasma,viridis};

if TGL_test
    ttl_txt = 'test';
else
    ttl_txt = 'train';
end

%%
load nn_fitting_test_predictors_proc;
load nn_fitting_pre pdt_txt_arr rsp_txt_arr

%%
for nn = 1:length(best_net)
    
    lab = best_lab{nn};         % best labels of predictors
    response_nn = best_rsp{nn}; % best NN response
    
    if TGL_test
        ind = best_tr{nn}.testInd;
    else
        ind = best_tr{nn}.trainInd;
    end
    
    r = regression(response_org(:,ind),response_nn(:,ind));
    
    c_lab = 2:-1:1;
    
    for pp = 1:2
        
        figure(pp); hold on;
        colormap(c_map{pp});
        
        txt_temp = strcat(pdt_txt_arr{lab});
        text(5,75,'Best predictors:','fontsize',fsz-2);
        text(10,70,txt_temp,'fontsize',fsz-2);
        
        a = scatter(response_org(pp,ind),response_nn(pp,ind),mks,response_org(c_lab(pp),ind),'o','filled');
        alpha(a,0.7);
        
        box off;
        axis tight;
        temp = [get(gca,'xlim'),get(gca,'ylim')];
        temp = [min(temp),max(temp)];
        axis([temp,temp]);
        temp = linspace(temp(1),temp(2),300);
        a = scatter(temp,temp,2,0.25*[1,1,1],'filled');
        alpha(a,0.3);
        
        title([ttl_txt ', R = ' num2str(r(pp),3)],'fontweight','normal');
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
        print('-dtiff','-r300',['nn_fitting_test_predictors_proc_plot_sep_' ttl_txt '_' num2str(nn) '_' num2str(pp)]);
        close;
    end
end