clear; clc; ca;
n_helix_arr = 4:2:24;

for nnn = 1:length(n_helix_arr)
    
    n_helix = n_helix_arr(nnn);           % number of sinusoids of the helix
    
    d = ['varHelixN_' num2str(n_helix)];
    
    cd(d);
    
    fname = ['findApex_3DoF_varHelixN_' num2str(n_helix)];
    
    %% view proc
    load(['pre_nn_' fname]);
    disp(nnn);
    PDT_MAT(:,:,nnn) = PDT;
    
    cd ..
    
end

%% plot predictors
c_arr = colormap(parula(length(n_helix_arr)));
PDT_MAT = permute(PDT_MAT,[2,3,1]);

%%
for ii = 1:size(PDT,1)    
    figure(ii);
    hold on;
    for nn = 1:size(PDT_MAT,2)
        h(nn) = scatter(1:size(PDT,2),PDT_MAT(:,nn,ii),5,c_arr(nn,:),'filled');
        alpha(h(nn),0.5);
    end
    title(PDT_txt{ii});
    axis tight;
    set(gca,'xtick',[]);
    lg = legend(h,cellfun(@num2str,num2cell(n_helix_arr),'un',0),'location','eastoutside');
    title(lg,'no. of helices');
    
    box off;
    set(gca,'fontsize',8);
    set(gcf,'paperposition',[0,0,4,2]);
    print('-dtiff','-r300',['plot_pre_nn_' num2str(ii)]);
    close;
end