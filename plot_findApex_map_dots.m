clear; clc; ca;
load('circular_approx_curVar_wSine_3D_rotate_findApex');
tgl_print = 1;

%% plot mapping wires by BENDING
figure;
hold on;
color_arr = colormap(viridis(length(variable_arr)));

for aa = 1:length(rot_arr) % rotation
    for rr = 1:length(variable_arr) % bending
        
        X = X_ARR{aa,rr}; Y = Y_ARR{aa,rr}; Z = Z_ARR{aa,rr};
        xh = XH_ARR{aa,rr}; yh = YH_ARR{aa,rr}; zh = ZH_ARR{aa,rr};
        x_pks = X_PKS_ARR{aa,rr};
        y_pks = Y_PKS_ARR{aa,rr};
        
        length_pks = sqrt( (y_pks(end)-y_pks(1))^2 + (x_pks(end)-x_pks(1))^2); % distance between the first and last nodes
        
        plot3(x_pks,y_pks,length_pks*ones(1,length(x_pks)),'color',color_arr(rr,:),'linewidth',1);
    end
end

% format
xlabel('x_{apex} (mm)');
ylabel('y_{apex} (mm)');
zlabel('\DeltaD_{apex} (mm)');

hc = colorbar;
set(hc,'ytick',1/(length(variable_arr))*(1:length(variable_arr)),'yticklabel',variable_arr);
hc.Box = 'off';
ylabel(hc,'\theta_{bend} (\circ)','fontsize',8);

axis tight;
grid on;
view(3);

if tgl_print
    set(gcf,'paperposition',[0,0,4,3],'unit','inches');
    print('-dtiff','-r300','plot_findApex_map_dots_2');
    close;
else
    set(gca,'fontsize',14);
end

%% plot mapping wires by ROTATION
figure;
hold on;
color_arr = colormap(plasma(length(rot_arr)));

for aa = 1:length(rot_arr) % rotation
    for rr = 1:length(variable_arr) % bending
        
        X = X_ARR{aa,rr}; Y = Y_ARR{aa,rr}; Z = Z_ARR{aa,rr};
        xh = XH_ARR{aa,rr}; yh = YH_ARR{aa,rr}; zh = ZH_ARR{aa,rr};
        x_pks = X_PKS_ARR{aa,rr};
        y_pks = Y_PKS_ARR{aa,rr};
        
        length_pks = sqrt( (y_pks(end)-y_pks(1))^2 + (x_pks(end)-x_pks(1))^2); % distance between the first and last nodes
        
        plot3(x_pks,y_pks,length_pks*ones(1,length(x_pks)),'color',color_arr(aa,:),'linewidth',1);
    end
end

% format
xlabel('x_{apex} (mm)');
ylabel('y_{apex} (mm)');
zlabel('\DeltaD_{apex} (mm)');

hc = colorbar;
set(hc,'ytick',1/(length(rot_arr))*(1:length(rot_arr)),'yticklabel',rot_arr);
hc.Box = 'off';
ylabel(hc,'\theta_{rot} (\circ)','fontsize',8);

axis tight;
grid on;
view(3);

if tgl_print
    set(gcf,'paperposition',[0,0,4,3],'unit','inches');
    print('-dtiff','-r300','plot_findApex_map_dots_1');
    close;
else
    set(gca,'fontsize',14);
end