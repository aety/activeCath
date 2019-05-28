clear;
clc;
ca;

cd C:\Users\yang\ownCloud\MATLAB\__simulation\varHelixN\3_vars\pitch_0_50

n_helix_arr = 4:2:24;
n_pdt = 3;

BEST_PDT = nan(length(n_helix_arr),n_pdt);
BEST_R_ARR = nan(length(n_helix_arr),3);
BEST_E_ARR = BEST_R_ARR;

for nnn = 1:length(n_helix_arr)
    
    n_helix = n_helix_arr(nnn);           % number of sinusoids of the helix
    
    d = ['varHelixN_' num2str(n_helix)];
    
    cd(d);    
    
    fname = ['findApex_3DoF_varHelixN'];
    
    %% view nn results
    c_map = [27,158,119; 217,95,2; 117,112,179]/255;
    load(['pre_nn_' fname],'*_txt');
    cd([num2str(n_pdt) '_pdt']);
    load(['nn_' fname]);
    cd ..
    
    [ind_a,ind_b] = find(P_ARR==min(min(P_ARR))); % find best predictors
    
    tr = TR;
    y = Y;
    best_pdt = pdt_arr(ind_a,:);
    
    ind = tr.testInd;
    
    %% plot combined
    r_arr = nan(1,3);
    e_arr = r_arr;
    
    for rr = 1:size(y,1)
        a = RSP(rr,ind);
        b = y(rr,ind);
        [r,~,~] = regression(a,b);
        
        err = abs(y(rr,ind) - RSP(rr,ind));
        merr = mean(err);
        
        r_arr(rr) = r;
        e_arr(rr) = merr;
    end
    
    %% store
    BEST_PDT(nnn,:) = best_pdt;
    BEST_R_ARR(nnn,:) = r_arr;
    BEST_E_ARR(nnn,:) = e_arr;
    
    %%
    cd ..
    
end

save post_nn_varHelixN BEST_* n_helix_arr RSP_txt PDT_txt

%% plot results
load post_nn_varHelixN

p_arr = {BEST_R_ARR,BEST_E_ARR};
t_arr = {'R','E (deg)'};
for pp = 1:length(p_arr)
    plot(n_helix_arr,p_arr{pp},'.--','markersize',15);    
    ylabel(t_arr{pp});
    xlabel('no. of helices');
    set(gca,'fontsize',12);
    box off;
    axis tight;
% % %     if pp==2
% % %         ylim([0,7.5]);
% % %         title(['\theta_{pitch} = [' num2str(pitch_range(1)) ', ' num2str(pitch_range(2)) ']'],'fontweight','normal');
% % %     end
    set(gcf,'paperposition',[0,0,4,3]);
    print('-dtiff','-r300',['post_nn_varHelixN_' num2str(pp)]);
    if pp==2
        legend(RSP_txt,'location','northeastoutside','fontsize',12);
        print('-dtiff','-r300',['post_nn_varHelixN_lgd']);
    end
    close;
end


%% plot sum
load post_nn_varHelixN

for pp = 1:length(p_arr)
    plot(n_helix_arr,sum(BEST_E_ARR'),'.--k','markerfacecolor','k','markersize',15);
    ylabel('sum of three errors (deg)');
    xlabel('no. of helices');
    set(gca,'fontsize',12);
    box off;
    axis tight;
end
set(gcf,'paperposition',[0,0,4,3]);
print('-dtiff','-r300','post_nn_varHelixN_all');
close;

%% show best predictors
load post_nn_varHelixN

plot(repmat(n_helix_arr',1,n_pdt),BEST_PDT,'ok','markerfacecolor','k','markersize',4);
set(gca,'xtick',n_helix_arr);
set(gca,'ytick',1:length(PDT_txt),'yticklabel',PDT_txt);
axis([n_helix_arr(1),n_helix_arr(end),1,length(PDT_txt)]);
title('best predictors','fontweight','normal');
xlabel('no. of helices');
box off;
set(gca,'fontsize',12);
set(gcf,'paperposition',[0,0,5,3]);
print('-dtiff','-r300','post_nn_varHelixN_PDT');
close;