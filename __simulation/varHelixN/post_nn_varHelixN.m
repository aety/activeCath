clear; clc; ca;
n_helix_arr = 4:2:24;

BEST_PDT = nan(length(n_helix_arr),3);
BEST_R_ARR = BEST_PDT;
BEST_E_ARR = BEST_PDT;

for nnn = 1:length(n_helix_arr)
    
    n_helix = n_helix_arr(nnn);           % number of sinusoids of the helix
    
    d = ['varHelixN_' num2str(n_helix)];
    
    cd(d);
    
    fname = ['findApex_3DoF_varHelixN_' num2str(n_helix)];
        
    %% view nn results
    c_map = [27,158,119; 217,95,2; 117,112,179]/255;
    load(['nn_' fname]);
    load(['pre_nn_' fname],'*_txt');
    
    [ind_a,ind_b] = find(P_ARR==min(min(P_ARR))); % find best predictors
    
    tr = TR_ARR{ind_a}{ind_b};
    y = Y_ARR{ind_a}{ind_b};
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

save post_nn_varHelixN BEST_* n_helix_arr RSP_txt

%% plot results
load post_nn_varHelixN

p_arr = {BEST_R_ARR,BEST_E_ARR,BEST_R_ARR./BEST_E_ARR};
t_arr = {'R','E','R/E'};
for pp = 1:length(p_arr)
    subplot(1,length(p_arr),pp);
    plot(n_helix_arr,p_arr{pp},'.--','markersize',10);
    title(t_arr{pp},'fontweight','normal');
    xlabel('no. of helices');
    set(gca,'fontsize',8);
    box off;
    axis tight;
end
legend(RSP_txt,'location','northeast');
set(gcf,'paperposition',[0,0,8,2]);
print('-dtiff','-r300','post_nn_varHelixN');
close;