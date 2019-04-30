%% debugging-- something is wrong with this frame (and potentially others too)
clear;
clc;
ca;

load proc_findApex_3DoF_varHelixN_10
%%
for ii = 1:size(X,2)
    
    temp = PKS{ii};
    tg = TGL{ii};
    
    hold on;
%     plot(X(:,ii),Y(:,ii),'k');
    h1 = scatter(temp(1,tg),temp(2,tg),'filled','b');
    h2 = scatter(temp(1,~tg),temp(2,~tg),'filled','m');
    
    axis equal    
    title([b_arr(ii),r_arr(ii),p_arr(ii)]);
    pause;
    
    alpha(h1,0.1);
    alpha(h2,0.1    );
    
end