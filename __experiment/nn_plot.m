%% load data
clear; clc; ca;
fname = 'incl_pitch_manualPicking';
% fname = '20SDF_H_30_short';
% fname = 'interp_btw_fr_res';

cmap = {flipud(parula),flipud(parula),jet}; % for "positive" (sequential, sequential)
% cmap = {flipud(parula),RdYlGn}; % for "both" (sequential, diverging)

load(['nn_' fname]);

[ind_a,ind_b] = find(P_ARR==min(min(P_ARR))); % find best predictors
% ind_a = 1; ind_b = 4; % Y_0 and mean(d_i)

tr = TR_ARR{ind_a}{ind_b};
y = Y_ARR{ind_a}{ind_b};
best_pdt = pdt_arr(ind_a,:);

ind = tr.testInd;

%% plot combined
% c_map = [118,42,131;27,120,55;]/255;
c_map = [27,158,119; 217,95,2; 117,112,179]/255;

for rr = 1:size(y,1)
    
    hold on;
    
    temp2 = max([max(max(t)),max(max(y))]);
    temp1 = min([min(min(t)),min(min(y))]);
    axis([temp1,temp2,temp1,temp2]);
    p = plot([temp1,temp2],[temp1,temp2],'color',0.75*[1,1,1],'linewidth',1);    
    
    h = scatter(t(rr,ind),y(rr,ind),20,c_map(rr,:),'filled');
    alpha(h,0.5);
    
    [r,m,b] = regression(t(rr,ind),y(rr,ind));
    
    text(temp1+2,temp2-10*rr,[RSP_txt{rr} ', R = ' num2str(r,3)],'color',c_map(rr,:),'fontsize',12);
    
end

% title(['Predictors: ' PDT_txt{best_pdt(1)} ', ' PDT_txt{best_pdt(2)}],'fontweight','normal');
ax = xlabel('actual (deg)');
ay = ylabel('predicted (deg)');
temp = round([temp1,temp2]);
axis equal;
axis([temp,temp]);
ay.Position(1) = ay.Position(1) + 3;
ax.Position(2) = ax.Position(2) + 5;
set(gca,'xtick',temp,'ytick',temp);
set(gca,'fontsize',12);
set(gcf,'paperposition',[0,0,2.7,2.7]);
print('-dtiff','-r300',['nn_' fname '_cmb']);
close;

%% plot error
for rr = 1:size(y,1)
    figure;
    hold on;
    
    plt = abs(y(rr,ind) - t(rr,ind));
    h = scatter(t(rr,ind),plt,10,'k','filled');
    alpha(h,0.5);
    
    mplt = mean(plt);
    seplt = std(plt)/sqrt(length(plt));
    h1 = plot([min(t(rr,ind)),max(t(rr,ind))],mplt*ones(1,2),'k');
    h2 = plot([min(t(rr,ind)),max(t(rr,ind))],(mplt+seplt)*ones(1,2),'--k');
    plot([min(t(rr,ind)),max(t(rr,ind))],(mplt-seplt)*ones(1,2),'--k');
    
    legend([h1,h2],num2str(mplt,3),['\pm ' num2str(seplt,3) ' (SE)'],'location','northwest');
    
    xlabel(['actual ' RSP_txt{rr}]);
    ylabel(['|' RSP_txt{rr} ' error|']);
    axis tight;
    
    set(gca,'fontsize',8);
    set(gcf,'paperposition',[0,0,3,1.5]);
    print('-dtiff','-r300',['nn_' fname '_err_' num2str(rr)]);
    close;
end

%% plot average error for all predictors
P_avg = mean(P_ARR,2);

figure;
hold on;

scatter(pdt_arr(:,1),pdt_arr(:,2),P_avg/5,'k','filled');

set(gca,'xtick',1:length(PDT_txt),'xticklabel',PDT_txt);
set(gca,'ytick',1:length(PDT_txt),'yticklabel',PDT_txt);

xlabel('predictor #1');
ylabel('predictor #2');
text(3,3,'marker sizes \propto error');

xtickangle(30);
ytickangle(30);

axis equal;
set(gca,'fontsize',8);
set(gcf,'paperposition',[0,0,4,3]);
print('-dtiff','-r300',['nn_' fname '_err_all']);
close;