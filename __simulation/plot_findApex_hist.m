clear; clc; ca;
load('catheter_simulator_findApex');

sbp_a = 0.16; % top/bottom border size
sbp_b = 0.075; % left/right broder size
sbp_w = 0.35;
sbp_h = .8;
pos = [sbp_b, sbp_a, sbp_w, sbp_h;...
    sbp_b*2+sbp_w, sbp_a, sbp_w, sbp_h;...
    sbp_b*2+sbp_w*2, sbp_a, 0.1, sbp_h];

%% by rotation-- plot history of the x and y locations of the apexes
color_arr = colormap(plasma(length(rot_arr)));
xminortick_size = diff(variable_arr(1:2))/(length(rot_arr)+1);

subplot('Position',pos(1,:)); hold on;

for rr = 1:length(variable_arr) % bending
    for aa = 1:length(rot_arr) % rotation
        plot(variable_arr(rr) + aa*xminortick_size,X_PKS_ARR{aa,rr},'.','color',color_arr(aa,:),'markersize',8);
    end
end

subplot('Position',pos(2,:)); hold on;
for rr = 1:length(variable_arr) % bending
    for aa = 1:length(rot_arr) % rotation
        plot(variable_arr(rr) + aa*xminortick_size,Y_PKS_ARR{aa,rr},'.','color',color_arr(aa,:),'markersize',8);
    end
end

% format
ttl_arr = {'x_{apex} (mm)','y_{apex} (mm)'};
for ff = 1:2
    subplot('Position',pos(ff,:));
    xlabel('\theta_{bend} (\circ)');
    ylabel(ttl_arr{ff});
    axis tight;
    
    ha = get(gca);
    ha.XAxis.TickValues = variable_arr + diff(variable_arr(1:2))/2;
    ha.XAxis.TickLabels = variable_arr;
    ha.XAxis.TickLength = [0,0];
    
    temp = get(gca,'ylim');
    plot(repmat(variable_arr,2,1),repmat(temp',1,length(variable_arr)),':k');
    set(gca,'fontsize',8);
end
subplot('Position',pos(3,:));
axis off;
hc = colorbar;
set(hc,'ytick',1/(length(rot_arr))*(1:length(rot_arr)),'yticklabel',rot_arr);
hc.Box = 'off';
ylabel(hc,'\theta_{rot} (\circ)','fontsize',8);

set(gcf,'position',[60,100,1000,300]);
set(gcf,'paperposition',[0,0,6,2.5],'unit','inches');
print('-dtiff','-r300','plot_findApex_hist_1');
close;

%% by bending-- plot history of the x and y locations of the apexes

color_arr = colormap(viridis(length(variable_arr)));
xminortick_size = diff(rot_arr(1:2))/(length(variable_arr)+1);

subplot('Position',pos(1,:)); hold on;

for aa = 1:length(rot_arr) % rotation
    for rr = 1:length(variable_arr) % bending
        plot(rot_arr(aa) + rr*xminortick_size,X_PKS_ARR{aa,rr},'.','color',color_arr(rr,:),'markersize',8);
    end
end

subplot('Position',pos(2,:)); hold on;
for aa = 1:length(rot_arr) % rotation
    for rr = 1:length(variable_arr) % bending
        plot(rot_arr(aa) + rr*xminortick_size,Y_PKS_ARR{aa,rr},'.','color',color_arr(rr,:),'markersize',8);
    end
end

% format
ttl_arr = {'x_{apex} (mm)','y_{apex} (mm)'};
for ff = 1:2
    subplot('Position',pos(ff,:));
    xlabel('\theta_{rot} (\circ)');
    ylabel(ttl_arr{ff});
    axis tight;
    
    ha = get(gca);
    ha.XAxis.TickValues = rot_arr + diff(rot_arr(1:2))/2;
    ha.XAxis.TickLabels = rot_arr;
    ha.XAxis.TickLength = [0,0];
    
    temp = get(gca,'ylim');
    plot(repmat(rot_arr,2,1),repmat(temp',1,length(rot_arr)),':k');
    set(gca,'fontsize',8);
end
subplot('Position',pos(3,:));
axis off;
hc = colorbar;
set(hc,'ytick',1/(length(variable_arr))*(1:length(variable_arr)),'yticklabel',variable_arr);
hc.Box = 'off';
ylabel(hc,'\theta_{bend} (\circ)','fontsize',8);

set(gcf,'position',[60,100,1000,300]);
set(gcf,'paperposition',[0,0,6,2.5],'unit','inches');
print('-dtiff','-r300','plot_findApex_hist_2');
close;