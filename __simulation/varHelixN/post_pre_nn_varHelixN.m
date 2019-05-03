clear; clc; ca;
n_helix_arr = 24; % 4:2:24;

for nnn = length(n_helix_arr):-1:1
    
    n_helix = n_helix_arr(nnn);           % number of sinusoids of the helix
    
    d = ['varHelixN_' num2str(n_helix)];
    
    cd(d);
    
    fname = ['findApex_3DoF_varHelixN_' num2str(n_helix)];
    
    %% view proc
    c_arr = colormap(jet(length(n_helix_arr)));
    load(['pre_nn_' fname]);
    
    for ii = 6
        
        figure(ii);
        hold on;
        %         h = scatter3(RSP(1,:),RSP(2,:),RSP(3,:),20,PDT(ii,:),'filled');
        h = scatter(1:size(PDT,2),PDT(ii,:),20,c_arr(nnn,:),'filled');
        %         alpha(h,0.3);
        %         plot(PDT(ii,:),'color',c_arr(nnn,:));
        title(PDT_txt{ii});
        axis tight;
        %         xlim([0,2000]);
        %         view(3);
    end
    pause;
    
    
    
    %%
    cd ..
    
end