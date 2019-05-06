% BEST_E_ARR = nan(length(n_helix_arr),84);
% 
% for nnn = 1:length(n_helix_arr)
%     
%     n_helix = n_helix_arr(nnn);           % number of sinusoids of the helix
%     
%     d = ['varHelixN_' num2str(n_helix)];
%     
%     cd(d);
%     
%     fname = ['findApex_3DoF_varHelixN_' num2str(n_helix)];
%     
%     %% view nn results
%     c_map = [27,158,119; 217,95,2; 117,112,179]/255;
%     load(['nn_' fname]);
%     load(['pre_nn_' fname],'*_txt');
%     
%     BEST_E_ARR(nnn,:) = min(E_ARR,[],2);
%     
%     cd ..
%     
% end
% 
% save post_nn_varHelixN_all BEST_* n_helix_arr RSP_txt pdt_arr

%% plot results
load post_nn_varHelixN_all
hold on;
% boxplot(BEST_E_ARR',n_helix_arr,'color','k');
plot(n_helix_arr,min(BEST_E_ARR,[],2),'*-k');
xlabel('no. of helices');
ylabel('Sum of three error (deg)');
title('error varying with predictors','fontweight','normal');
% axis tight;
box off;
set(gcf,'paperposition',[0,0,4,2]);
% print('-dtiff','-r300','post_nn_varHelixN_all');
% close;