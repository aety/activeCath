%% debugging-- something is wrong with this frame (and potentially others too)
clear;
clc;
ca;

load proc_findApex_3DoF_varHelixN_24

%%
% for ii = 1:size(PDT,1)
%     subplot(10,1,ii);
%     plot(PDT(ii,:));
%     title(PDT_txt{ii});
%     axis tight;
% end

%%
ind = 1:length(PKS); % find(p_arr==40);

for ii = 1463 % 1:length(ind) % 1:size(X,2)
    
    id = ind(ii);
    
    temp = PKS{id};
    tg = logical(TGL{id});
    
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