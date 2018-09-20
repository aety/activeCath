clear; clc; ca;
load circular_approx_curVar_wSine_3D_rotate_findApex
color_arr = colormap(cool(length(rot_arr)));

%%
for aa = 1:length(rot_arr) % rotation
    
    %     figure(aa);
    %     hold on;
    
    for rr = 1:length(variable_arr) % bending
        
        X = X_ARR{aa,rr}; Y = Y_ARR{aa,rr}; Z = Z_ARR{aa,rr};
        xh = XH_ARR{aa,rr}; yh = YH_ARR{aa,rr}; zh = ZH_ARR{aa,rr};
        x_pks = X_PKS_ARR{aa,rr};
        y_pks = Y_PKS_ARR{aa,rr};
        
        %         plot(x_pks,rr*ones(1,length(x_pks)),'o-');
        subplot(1,3,1); hold on;
        plot3(1:length(x_pks),variable_arr(rr)*ones(1,length(x_pks)),x_pks,'color',color_arr(aa,:),'linewidth',1);
        subplot(1,3,2); hold on;
        plot3(1:length(y_pks),variable_arr(rr)*ones(1,length(y_pks)),y_pks,'color',color_arr(aa,:),'linewidth',1);
    end
    
end

%% format
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
axis off;
hc = colorbar;
set(hc,'ytick',1/(length(rot_arr))*(1:length(rot_arr)),'yticklabel',rot_arr);
hc.Box = 'off';
ylabel(hc,'\theta_{rot} (\circ)','fontsize',12);

set(gcf,'position',[60,100,900,300]);
set(gcf,'paperposition',[0,0,6,2],'unit','inches');
print('-dtiff','-r300','plot_findApex_summary');
close;