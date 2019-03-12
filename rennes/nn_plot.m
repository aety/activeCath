cmap = {flipud(parula),flipud(parula)}; % for "positive" (sequential, sequential)
% cmap = {flipud(parula),RdYlGn}; % for "both" (sequential, diverging)

%% plot separate
% fname = '20SDF_H_30_short';
fname = 'interp_btw_fr_res'; 
load(['nn_' fname]);

[ind_a,ind_b] = find(P_ARR==min(min(P_ARR)));

tr = TR_ARR{ind_a}{ind_b};
y = Y_ARR{ind_a}{ind_b};

ind = tr.testInd;
c_plt = [2,1];

for rr = 1:size(y,1)
    figure;
    hold on;
    
    temp2 = max([max(max(t(rr,:))),max(max(y(rr,:)))]);
    temp1 = min([min(min(t(rr,:))),min(min(y(rr,:)))]);
    axis([temp1,temp2,temp1,temp2]);
    plot([temp1,temp2],[temp1,temp2],'color',0.75*[1,1,1],'linewidth',2);
    
    
    colormap(cmap{rr});
    h = scatter(t(rr,ind),y(rr,ind),10,RSP(c_plt(rr),ind),'filled');
    alpha(h,0.5);
    
    [r,m,b] = regression(t(rr,ind),y(rr,ind));
    
    title(['Predictors: ' PDT_txt{1} ', ' PDT_txt{ind_a} ', R = ' num2str(r)],'fontweight','normal');
    xlabel(['actual ' RSP_txt{rr}]);
    ylabel(['predicted ' RSP_txt{rr}]);
    
    axis equal
    
    c = colorbar;
    c.Label.String = RSP_txt{c_plt(rr)};
    c.Box = 'off';
    
    set(gca,'fontsize',8);
    set(gcf,'paperposition',[0,0,4,3]);
    print('-dtiff','-r300',['nn_' fname '_' num2str(rr)]);
    close;
end

%% plot combined
c_map = [118,42,131;27,120,55]/255;

for rr = 1:size(y,1)
    
    hold on;
    
    temp2 = max([max(max(t)),max(max(y))]);
    temp1 = min([min(min(t)),min(min(y))]);
    axis([temp1,temp2,temp1,temp2]);
    plot([temp1,temp2],[temp1,temp2],'color',0.75*[1,1,1],'linewidth',2);
    
    h = scatter(t(rr,ind),y(rr,ind),10,c_map(rr,:),'filled');
    alpha(h,0.5);
    
    [r,m,b] = regression(t(rr,ind),y(rr,ind));
    
    text(temp1+10,temp2-10*rr,[RSP_txt{rr} ', R = ' num2str(r,3)],'color',c_map(rr,:));
    
end

% title(['Predictors: ' PDT_txt{1} ', ' PDT_txt{ind_a}],'fontweight','normal');
xlabel('actual');
ylabel('predicted');
axis tight;
axis equal;
set(gca,'fontsize',8);
set(gcf,'paperposition',[0,0,3,3]);
print('-dtiff','-r300',['nn_' fname '_cmb']);
close;

%% plot error
for rr = 1:size(y,1)
    figure;
    hold on;
        
%     colormap(cmap{rr});
    h = scatter(t(rr,ind),abs(y(rr,ind) - t(rr,ind)),10,'k','filled');    
    alpha(h,0.5);
    
    xlabel(['actual ' RSP_txt{rr}]);
    ylabel(['|' RSP_txt{rr} ' error|']);
    axis tight;
    
%     c = colorbar;
%     c.Label.String = RSP_txt{c_plt(rr)};
%     c.Box = 'off';
    
    set(gca,'fontsize',8);
    set(gcf,'paperposition',[0,0,3,1.5]);
    print('-dtiff','-r300',['nn_' fname '_err_' num2str(rr)]);
    close;
end