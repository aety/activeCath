clear; clc; ca;
load circular_approx_curVar_wSine_3D_rotate_findApex
color_arr = colormap(plasma(length(rot_arr)));
xminortick_size = diff(variable_arr(1:2))/(length(rot_arr)+1);

%%
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

%% format
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

set(gcf,'position',[60,100,900,300]);
set(gcf,'paperposition',[0,0,6,2],'unit','inches');
print('-dtiff','-r300','plot_findApex_hist');
close;