clear; clc; ca;

n_pdt_arr = 1:8; % N by 1 array (number of predictors)
pitch_range_arr = [0,50]; % N by 2 array (ranges of pitch variations)
n_helix_arr = 16; % N by 1 array (number of helices)

for ppp = 1:size(pitch_range_arr,1) % pitch range
    
    pitch_range = pitch_range_arr(ppp,:);
    dpname = ['pitch_' num2str(pitch_range(1)) '_' num2str(pitch_range(2))];
    mkdir(dpname);
    cd(dpname);
    
    for hhh = 1:length(n_helix_arr) % number of helices
        
        n_helix = n_helix_arr(hhh);
        dname = ['varHelixN_' num2str(n_helix)];
        mkdir(dname);
        cd(dname);
        
%         proc_findApex_3DoF_varHelixN; clearvars -except nn n_helix_arr n_helix d pitch_* n_pdt ttt ppp hhh n_pdt_arr
        
        fname = 'findApex_3DoF_varHelixN';
        load(['proc_' fname '_' num2str(n_helix)]);
        
%         pre_nn; clearvars -except nn n_helix_arr n_helix d fname pitch_* n_pdt ttt ppp hhh n_pdt_arr
        
        R_MAT = cell(length(n_pdt_arr),size(pitch_range_arr,1),length(n_helix_arr)); % master R (correlation coefficient) array
        E_MAT = R_MAT; % master E (mean) array
        
        for ttt = 1:length(n_pdt_arr)
            
            n_pdt = n_pdt_arr(ttt);
            dnname = [num2str(n_pdt) '_pdt'];
            mkdir(dnname);
            cd(dnname);
            
            nn_training; clearvars -except nn n_helix_arr n_helix d fname pitch_* n_pdt ttt ppp hhh n_pdt_arr
            
            nn_plot;
            R_MAT{ttt,ppp,hhh} = r_arr;
            E_MAT{ttt,ppp,hhh} = e_arr;
            clearvars -except nn n_helix_arr n_helix d fname pitch_* n_pdt ttt ppp hhh n_pdt_arr
            cd ..
            
        end
                
        cd ..
        
    end
    
    cd ..
    
end