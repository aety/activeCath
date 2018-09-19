clear; clc; ca;
load circular_approx_curVar_wSine_3D_rotate_findApex
color_arr = colormap(cool(length(rot_arr)));

%% loop for rotation

for aa = 1:length(rot_arr)
    
    %% loop for bending the catheter
    for rr = 1:length(variable_arr)
        
        X = X_ARR{aa,rr}; Y = Y_ARR{aa,rr}; Z = Z_ARR{aa,rr};
        xh = XH_ARR{aa,rr}; yh = YH_ARR{aa,rr}; zh = ZH_ARR{aa,rr};
        x_pks = X_PKS_ARR{aa,rr};
        y_pks = Y_PKS_ARR{aa,rr};
        
        
        subplot(1,3,1); hold on;
        plot3(rot_arr(aa)*ones(1,length(x_pks)),1:length(x_pks),x_pks,'color',color_arr(rr,:),'linewidth',1);
        subplot(1,3,2); hold on;
        plot3(rot_arr(aa)*ones(1,length(x_pks)),1:length(y_pks),y_pks,'color',color_arr(rr,:),'linewidth',1);
    end
    
end
ttl_arr = {'x_{apex} (mm)','y_{apex} (mm)'};
for ff = 1:2
    subplot(1,3,ff);
    xlabel('\theta_{bend} (\circ)');
    ylabel('n\circ');
    zlabel(ttl_arr{ff});
    view(3);
    axis tight;
    grid on;
    set(gca,'fontsize',8);
end
subplot(1,3,3);
hc = colorbar;
set(hc,'ytick',1/(length(rot_arr))*(1:length(rot_arr)),'yticklabel',rot_arr);
hc.Box = 'off';
ylabel(hc,'\theta_{rot} (\circ)','fontsize',12);

set(gcf,'position',[60,100,1200,400]);
set(gcf,'paperposition',[0,0,6,2],'unit','inches');
print('-dtiff','-r300','plot_findApex_summary');
close;