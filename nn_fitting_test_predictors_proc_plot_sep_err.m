clear; clc; ca;

TGL_test = 0; % plot testing set only (vs. plot all data)

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
        
    c_lab = 2:-1:1;
    
    for pp = 1:2
        
        figure(pp); hold on;
        colormap(c_map{pp});
               
        err = response_nn(pp,ind) - response_org(pp,ind);
        errm = mean(err);
        errstd = std(err);
        
        a = scatter(response_org(pp,ind),err,mks,response_org(c_lab(pp),ind),'o','filled');
        alpha(a,0.7);
        
        box off;
        axis tight;
        
        title({[ttl_txt ' (n = ' num2str(length(err)) ')'];...
            ['(m \pm std = ' num2str(errm,3) '\pm' num2str(errstd,3) ')']},'fontweight','normal');
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
        print('-dtiff','-r300',['nn_fitting_test_predictors_proc_plot_sep_err_' ttl_txt '_' num2str(nn) '_' num2str(pp)]);
        close;
    end
end