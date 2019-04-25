clear; clc; ca;
n_helix_arr = 2:2:20;

nn = 1;

n_helix = n_helix_arr(nn);           % number of sinusoids of the helix

d = ['varHelixN_' num2str(n_helix)];

proc_findApex_3DoF_varHelixN;

clearvars -except nn n_helix_arr n_helix d

fname = ['findApex_3DoF_varHelixN_' num2str(n_helix)];
load(['proc_' fname]);

mkdir(d);
cd(d);
pre_nn;
nn_training;
nn_plot;

cd ..