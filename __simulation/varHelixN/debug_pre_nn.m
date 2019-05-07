clear; clc; ca;
n_helix_arr = 4:4:24;

for nnn = 1:length(n_helix_arr)
    
    n_helix = n_helix_arr(nnn);           % number of sinusoids of the helix
    
    d = ['varHelixN_' num2str(n_helix)];
    
    cd(d);
    
    fname = ['findApex_3DoF_varHelixN_' num2str(n_helix)];
    
    %% view proc
    c_arr = colormap(parula(length(n_helix_arr)));
    load(['pre_nn_' fname]);
    
    for ii = 4%1:size(PDT,1)
        
        figure(ii);
        hold on;
        h = scatter(1:size(PDT,2),PDT(ii,:),20,c_arr(nnn,:),'filled');
        alpha(h,0.5);
        title(PDT_txt{ii});
        axis tight;
                
        if ii==size(PDT,1)
            
        end
    end
    
    %%
    cd ..
    
end