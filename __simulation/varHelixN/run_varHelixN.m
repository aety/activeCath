clear; clc; ca;
n_helix_arr = 4:2:24;

pitch_range_arr = [-25,0;
    0,25;
    25,50;
    -25,25;
    0,50];

for ppp = 1:length(pitch_range_arr)
    
    pitch_range = pitch_range_arr(ppp,:);
    dpname = ['pitch_' num2str(pitch_range(1)) '_' num2str(pitch_range(1))];
    mkdir(dpname);
    cd(dpname);
    
    for nnn = 1:length(n_helix_arr)
        
        n_helix = n_helix_arr(nnn);
        
        d = ['varHelixN_' num2str(n_helix)];
        
        proc_findApex_3DoF_varHelixN;
        clearvars -except nn n_helix_arr n_helix d pitch_*
        
        fname = ['findApex_3DoF_varHelixN_' num2str(n_helix)];
        load(['proc_' fname]);
        
        mkdir(d);
        cd(d);
        pre_nn;
        clearvars -except nn n_helix_arr n_helix d fname pitch_*
        
        nn_training;
        clearvars -except nn n_helix_arr n_helix d fname pitch_*
        
        nn_plot;
        clearvars -except nn n_helix_arr n_helix d fname pitch_*
        
        cd ..
        
    end
    
    post_nn_varHelixN;
    clearvars -except nn n_helix_arr n_helix d fname pitch_*
    
    plot_pre_nn;
    
    cd ..
    
end