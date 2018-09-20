clear; clc; ca;
ver_name = '_fine';
load(['circular_approx_curVar_wSine_3D_rotate_findApex' ver_name]);
tgl_print = 1;

%% find the maximum node number
temp_size = nan(length(rot_arr),length(variable_arr));
for aa = 1:length(rot_arr)
    for rr = 1:length(variable_arr)
        temp_size(aa,rr) = length(X_PKS_ARR{aa,rr});
    end
end
ss = max(max(temp_size));
clear temp_size

%% reshape matrices
XX = nan(ss,length(variable_arr),length(rot_arr));
YY = XX; NN = XX; BB = XX; AA = XX;

for aa = 1:length(rot_arr)
    for rr = 1:length(variable_arr)
        x_pks = X_PKS_ARR{aa,rr};
        y_pks = Y_PKS_ARR{aa,rr};
        
        XX(1:length(x_pks),rr,aa) = x_pks;
        YY(1:length(y_pks),rr,aa) = y_pks;
        NN(1:length(x_pks),rr,aa) = 1:length(x_pks);
        BB(1:length(x_pks),rr,aa) = variable_arr(rr)*ones(length(x_pks),1);
        AA(1:length(x_pks),rr,aa) = rot_arr(aa)*ones(length(x_pks),1);
    end
end

%% by rotation-- plot surface
figure(1);
hold on;
for aa = 1:length(rot_arr)
    surf(XX(:,:,aa),YY(:,:,aa),BB(:,:,aa),AA(:,:,aa),...
        'edgecolor','none',...
        'facealpha',0.5);
end

colormap(plasma(length(rot_arr)));

zlabel('\theta_{bend} (\circ)');
view(3);
hc = colorbar;
ylabel(hc,'\theta_{rot} (\circ)');
hc.Box = 'off';

%% by bending-- plot surface
figure(2);
hold on;
for rr = 1:length(variable_arr)
    surf(permute(XX(:,rr,:),[1,3,2]),...
        permute(YY(:,rr,:),[1,3,2]),...
        permute(AA(:,rr,:),[1,3,2]),...
        permute(BB(:,rr,:),[1,3,2]),...
        'edgecolor','none',...
        'facealpha',0.5);
end

colormap(viridis(length(rot_arr)));

zlabel('\theta_{rot} (\circ)');
view(3);
hc = colorbar;
ylabel(hc,'\theta_{bend} (\circ)');
hc.Box = 'off';

%% format
for ff = 1:2
    figure(ff);
    xlabel('x_{apex} (mm)');
    ylabel('y_{apex} (mm)');
    grid on;
    axis tight;
    if tgl_print
        set(gca,'fontsize',8);
        set(gcf,'paperposition',[0,0,4,3],'unit','inches');
        print('-dtiff','-r300',['plot_findApex_map_' ver_name '_' num2str(ff)]);
        close;
    else
        set(gca,'fontsize',14);
        set(gcf,'position',[1100+700*ff,500,600,600]);
        
    end
end