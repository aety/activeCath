clear; clc; ca;
ver_name = '_fine';
load(['circular_approx_curVar_wSine_3D_rotate_findApex' ver_name]);

%% by rotation-- plot history of the x and y locations of the apexes
color_arr = colormap(plasma(length(rot_arr)));
xminortick_size = diff(variable_arr(1:2))/(length(rot_arr)+1);

subplot(1,3,1); hold on;

for rr = 1:length(variable_arr) % bending
    for aa = 1:length(rot_arr) % rotation
        plot(variable_arr(rr) + aa*xminortick_size,X_PKS_ARR{aa,rr},'.','color',color_arr(aa,:),'markersize',8);
    end
end

subplot(1,3,2); hold on;
for rr = 1:length(variable_arr) % bending
    for aa = 1:length(rot_arr) % rotation
        plot(variable_arr(rr) + aa*xminortick_size,Y_PKS_ARR{aa,rr},'.','color',color_arr(aa,:),'markersize',8);
    end
end

% format
ttl_arr = {'x_{apex} (mm)','y_{apex} (mm)'};
for ff = 1:2
    subplot(1,3,ff);
    xlabel('\theta_{bend} (\circ)');
    ylabel(ttl_arr{ff});
    axis tight;
    temp = get(gca,'ylim');
    plot(repmat(variable_arr,2,1),repmat(temp',1,length(variable_arr)),':k');
    set(gca,'fontsize',8);
end
subplot(1,3,3);
axis off;
hc = colorbar;
set(hc,'ytick',1/(length(rot_arr))*(1:length(rot_arr)),'yticklabel',rot_arr);
hc.Box = 'off';
ylabel(hc,'\theta_{rot} (\circ)','fontsize',8);

set(gcf,'position',[60,100,1500,500]);
set(gcf,'paperposition',[0,0,6,2],'unit','inches');
print('-dtiff','-r300',['plot_findApex_hist' ver_name]);
close;

%% by bending-- plot history of the x and y locations of the apexes

color_arr = colormap(viridis(length(variable_arr)));
xminortick_size = diff(rot_arr(1:2))/(length(variable_arr)+1);

subplot(1,3,1); hold on;

for aa = 1:length(rot_arr) % rotation
    for rr = 1:length(variable_arr) % bending
        plot(rot_arr(aa) + rr*xminortick_size,X_PKS_ARR{aa,rr},'.','color',color_arr(rr,:),'markersize',8);
    end
end

subplot(1,3,2); hold on;
for aa = 1:length(rot_arr) % rotation
    for rr = 1:length(variable_arr) % bending
        plot(rot_arr(aa) + rr*xminortick_size,Y_PKS_ARR{aa,rr},'.','color',color_arr(rr,:),'markersize',8);
    end
end

% format
ttl_arr = {'x_{apex} (mm)','y_{apex} (mm)'};
for ff = 1:2
    subplot(1,3,ff);
    xlabel('\theta_{rot} (\circ)');
    ylabel(ttl_arr{ff});
    axis tight;
    temp = get(gca,'ylim');
    plot(repmat(rot_arr,2,1),repmat(temp',1,length(rot_arr)),':k');
    set(gca,'fontsize',8);
end
subplot(1,3,3);
axis off;
hc = colorbar;
set(hc,'ytick',1/(length(variable_arr))*(1:length(variable_arr)),'yticklabel',variable_arr);
hc.Box = 'off';
ylabel(hc,'\theta_{bend} (\circ)','fontsize',8);

set(gcf,'position',[60,100,1500,500]);
set(gcf,'paperposition',[0,0,6,2],'unit','inches');
print('-dtiff','-r300',['plot_findApex_hist_byBend' ver_name]);
close;