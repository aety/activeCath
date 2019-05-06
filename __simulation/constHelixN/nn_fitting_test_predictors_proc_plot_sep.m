clear; clc; ca;

TGL_test = 1; % plot testing set only (vs. plot all data)

fsz = 10; % major fontsize
mks = 10; % markersize

%%
c_map = {plasma,viridis,parula};

if TGL_test
    ttl_txt = 'test';
else
    ttl_txt = 'train';
end

%%
load nn_fitting_test_predictors_proc;
load nn_fitting_pre_3D pdt_txt_arr rsp_txt_arr

%%
for nn = 3%1:length(best_net)
    
    lab = best_lab{nn};         % best labels of predictors
    response_nn = best_rsp{nn}; % best NN response
    
    if TGL_test
        ind = best_tr{nn}.testInd;
    else
        ind = best_tr{nn}.trainInd;
    end
    
    r = regression(response_org(:,ind),response_nn(:,ind));
    
    for pp = 1:size(response_org,1)
        
        test = 1:size(response_org,1);
        q_arr = test(test~=pp);
        
        for qq = 1:length(q_arr)
            
            q = q_arr(qq);
            figure; hold on;
            colormap(c_map{q});
            
            a = scatter(response_org(pp,ind),response_nn(pp,ind),mks,response_org(q,ind),'o','filled');
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
            ylabel(cb,['actual ' rsp_txt_arr{q} ' (\circ)']);
            
            set(gcf,'paperposition',[0,0,4,3],'unit','inches');
            print('-dtiff','-r300',['nn_fitting_test_predictors_proc_plot_sep_' ttl_txt '_' num2str(nn) '_' num2str(pp) '_' num2str(q)]);
            close;
        end
    end
end