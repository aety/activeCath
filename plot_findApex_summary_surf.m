clear; clc; ca;
ver_name = '_fine';
load(['circular_approx_curVar_wSine_3D_rotate_findApex' ver_name]);

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

%% plot surfaces
for aa = 1:length(rot_arr)
    subplot(1,3,1); hold on;
        surf(NN(:,:,aa),BB(:,:,aa),XX(:,:,aa),AA(:,:,aa),'edgecolor','none');
    subplot(1,3,2); hold on;
        surf(NN(:,:,aa),BB(:,:,aa),YY(:,:,aa),AA(:,:,aa),'edgecolor','none');
end

zlb_arr = {'x_{apex} (mm)','y_{apex} (mm)'};
for ff = 1:2
    subplot(1,3,ff);
    axis tight
    xlabel('n\circ');
    ylabel('\theta_{bend} (\circ)');
    zlabel(zlb_arr{ff});
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
ylabel(hc,'\theta_{rot} (\circ)','fontsize',8);

set(gcf,'position',[60,100,900,300]);
set(gcf,'paperposition',[0,0,6,2],'unit','inches');
print('-dtiff','-r300',['plot_findApex_summary_surf' ver_name]);
close;

%% plot surfaces-- by bend
% rearrange from [node number, bending, rotation] to [node number,
% rotation, bending]
color_arr = colormap(viridis);

XX = permute(XX,[1,3,2]);
YY = permute(YY,[1,3,2]);
NN = permute(NN,[1,3,2]);
BB = permute(BB,[1,3,2]);
AA = permute(AA,[1,3,2]);

for rr = 1:length(variable_arr)
    subplot(1,3,1); hold on;
        surf(NN(:,:,rr),AA(:,:,rr),XX(:,:,rr),BB(:,:,rr),'edgecolor','none');
    subplot(1,3,2); hold on;
        surf(NN(:,:,rr),AA(:,:,rr),YY(:,:,rr),BB(:,:,rr),'edgecolor','none');
end

zlb_arr = {'x_{apex} (mm)','y_{apex} (mm)'};
for ff = 1:2
    subplot(1,3,ff);
    axis tight
    xlabel('n\circ');
    ylabel('\theta_{rot} (\circ)');
    zlabel(zlb_arr{ff});
    view(3);
    axis tight;
    grid on;
    set(gca,'fontsize',8);
end

subplot(1,3,3);
axis off;
hc = colorbar;
set(hc,'ytick',1/(length(variable_arr))*(1:length(variable_arr)),'yticklabel',variable_arr);
hc.Box = 'off';
ylabel(hc,'\theta_{bend} (\circ)','fontsize',8);

set(gcf,'position',[60,100,900,300]);
set(gcf,'paperposition',[0,0,6,2],'unit','inches');
print('-dtiff','-r300',['plot_findApex_summary_surf_byBend' ver_name]);
close;