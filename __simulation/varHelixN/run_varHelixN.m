clear; clc; ca;
n_helix_arr = 4:24;

for nnn = 1:length(n_helix_arr)
    
    n_helix = n_helix_arr(nnn);
    
    d = ['varHelixN_' num2str(n_helix)];
    
    proc_findApex_3DoF_varHelixN;
    clearvars -except nn n_helix_arr n_helix d
    
    fname = ['findApex_3DoF_varHelixN_' num2str(n_helix)];
    load(['proc_' fname]);
    
    mkdir(d);
    cd(d);
    pre_nn;
    clearvars -except nn n_helix_arr n_helix d fname
    
    nn_training;
    clearvars -except nn n_helix_arr n_helix d fname
    
    nn_plot;
    clearvars -except nn n_helix_arr n_helix d fname
    
    cd ..
    
end

post_nn_varHelixN;
clearvars -except nn n_helix_arr n_helix d fname

plot_pre_nn;