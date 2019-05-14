%% debugging-- something is wrong with this frame (and potentially others too)
clear;
clc;
ca;

load proc_findApex_3DoF_varHelixN_4

%%
ind = 1:length(PKS); 

for ii = 272
    
    id = ind(ii);
    
    temp = PKS{id}(1:2,:);
    tg = logical(PKS{id}(3,:));
    
    hold on;
    h0 = plot(X(:,id),Y(:,id),'k');
    h1 = scatter(temp(1,tg),temp(2,tg),'filled','b');
    h2 = scatter(temp(1,~tg),temp(2,~tg),'filled','m');
    
    axis equal
    title({ii;[b_arr(id),r_arr(id),p_arr(id)]});
    pause;
    
    alpha(h1,0.1);
    alpha(h2,0.1);
    delete(h0);
    
end