clear; clc; ca;

load ..\results_forTest\nn_fitting_pre PDT* RSP*

fsz = 10; % major fontsize
mks = 10; % markersize

%%
c_map = {plasma,viridis};
ttl_txt = 'independent test';

%%
load nn_fitting_test_predictors_proc best_*;
load nn_fitting_pre pdt_txt_arr rsp_txt_arr

%%
for nn = 1:length(best_net)
    
    %% Predict responses from the trained network using new inputs
    lab = best_lab{nn};         % best labels of predictors
    net = best_net{nn};
    response_org = RSP;
    response_org = nn_denormalize_Mm(response_org,RSP_MX,RSP_mn);
    response_nn = net(PDT(lab,:));
    response_nn = nn_denormalize_Mm(response_nn,RSP_MX,RSP_mn);
    
    c_lab = 2:-1:1;
    
    for pp = 1:2
        
        figure(pp); hold on;
        colormap(c_map{pp});
                
        err = response_nn(pp,:) - response_org(pp,:);
        errm = mean(err);
        errstd = std(err);
        
        a = scatter(response_org(pp,:),err,mks,response_org(c_lab(pp),:),'o','filled');
        alpha(a,0.7);
                        
        title({[ttl_txt ' (n = ' num2str(length(err)) ')'];...
            ['(m \pm std = ' num2str(errm,3) '\pm' num2str(errstd,3) ')']},'fontweight','normal');
        xlabel(['actual ' rsp_txt_arr{pp} '(\circ)']);
        ylabel(['error ' rsp_txt_arr{pp} '(\circ)']);
        
        set(gca,'fontsize',fsz);
        set(gcf,'position',[100,150,800,600]);
        set(gcf,'color','w');
        
        cb = colorbar;
        cb.Box = 'off';
        cb.Location = 'eastoutside';
        ylabel(cb,['actual ' rsp_txt_arr{c_lab(pp)} ' (\circ)']);
        
        box off;
        axis tight;
        
        set(gcf,'paperposition',[0,0,4,3],'unit','inches');
        print('-dtiff','-r300',['nn_fitting_test_predictors_proc_plot_sep_newInputs_err_' num2str(nn) '_' num2str(pp)]);
        close;
    end
end