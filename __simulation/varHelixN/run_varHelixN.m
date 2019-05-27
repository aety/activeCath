clear; clc; ca;
n_helix_arr = 16;

n_pdt = 3;

dnname = [num2str(n_pdt) '_pdt'];
mkdir(dnname);
cd(dnname);

pitch_range_arr = [0,50];

for ppp = 1:size(pitch_range_arr,1)
    
    pitch_range = pitch_range_arr(ppp,:);
    dpname = ['pitch_' num2str(pitch_range(1)) '_' num2str(pitch_range(2))];
    mkdir(dpname);
    cd(dpname);
    
    for nnn = 1:length(n_helix_arr)
        
        n_helix = n_helix_arr(nnn);
        
        d = ['varHelixN_' num2str(n_helix)];
        
        proc_findApex_3DoF_varHelixN; clearvars -except nn n_helix_arr n_helix d pitch_* n_pdt
        
        fname = ['findApex_3DoF_varHelixN_' num2str(n_helix)];
        load(['proc_' fname]);
        
        mkdir(d);
        cd(d);
        pre_nn; clearvars -except nn n_helix_arr n_helix d fname pitch_* n_pdt
        
        nn_training; clearvars -except nn n_helix_arr n_helix d fname pitch_* n_pdt
        
        nn_plot; clearvars -except nn n_helix_arr n_helix d fname pitch_* n_pdt
        
        cd ..
        
    end
    
    plot_pre_nn;
    
    cd ..
    
end

cd ..