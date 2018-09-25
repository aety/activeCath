clear; clc; ca;
load('circular_approx_curVar_wSine_3D_rotate_findApex');
tgl_print = 1;

%% plot mapping wires by BENDING
figure;
color_arr = colormap(viridis(length(variable_arr)));
hold on;

for aa = 1:length(rot_arr) % rotation
    for rr = 1:length(variable_arr) % bending
        
        X = X_ARR{aa,rr}; Y = Y_ARR{aa,rr}; Z = Z_ARR{aa,rr};
        xh = XH_ARR{aa,rr}; yh = YH_ARR{aa,rr}; zh = ZH_ARR{aa,rr};
        x_pks = X_PKS_ARR{aa,rr};
        y_pks = Y_PKS_ARR{aa,rr};
        
        plot3(x_pks,y_pks,rot_arr(aa)*ones(1,length(x_pks)),'color',color_arr(rr,:),'linewidth',1);
        
    end
end

% format
xlabel('x_{apex} (mm)');
ylabel('y_{apex} (mm)');
zlabel('\theta_{rot} (\circ)');

hc = colorbar;
set(hc,'ytick',1/(length(variable_arr))*(1:length(variable_arr)),'yticklabel',variable_arr);
hc.Box = 'off';
ylabel(hc,'\theta_{bend} (\circ)','fontsize',8);

axis tight;
grid on;
view(2);

if tgl_print
set(gcf,'paperposition',[0,0,4,3],'unit','inches');
print('-dtiff','-r300','plot_findApex_map_lines_2_v2');
close;
else
set(gca,'fontsize',14);
    set(gcf,'position',[1100+0,500,600,600]);
end
%% plot mapping wires by ROTATION
figure;
color_arr = colormap(plasma(length(rot_arr)));
hold on;

for aa = 1:length(rot_arr) % rotation
    for rr = 1:length(variable_arr) % bending
        
        X = X_ARR{aa,rr}; Y = Y_ARR{aa,rr}; Z = Z_ARR{aa,rr};
        xh = XH_ARR{aa,rr}; yh = YH_ARR{aa,rr}; zh = ZH_ARR{aa,rr};
        x_pks = X_PKS_ARR{aa,rr};
        y_pks = Y_PKS_ARR{aa,rr};
        
        plot3(x_pks,y_pks,variable_arr(rr)*ones(1,length(x_pks)),'color',color_arr(aa,:),'linewidth',1);
        
    end
end

% format
xlabel('x_{apex} (mm)');
ylabel('y_{apex} (mm)');
zlabel('\theta_{bend} (\circ)');

hc = colorbar;
set(hc,'ytick',1/(length(rot_arr))*(1:length(rot_arr)),'yticklabel',rot_arr);
hc.Box = 'off';
ylabel(hc,'\theta_{rot} (\circ)','fontsize',8);

axis tight;
grid on;
view(2);
if tgl_print
    set(gcf,'paperposition',[0,0,4,3],'unit','inches');
    print('-dtiff','-r300','plot_findApex_map_lines_1_v2');
    close;
else
    set(gca,'fontsize',14);
    set(gcf,'position',[1100+700,500,600,600]);
end