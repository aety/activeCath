clear; clc; ca;
load circular_approx_curVar_wSine_3D_rotate_findApex
color_arr = colormap(cool(length(rot_arr)));

%% loop for rotation

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
YY = XX; NN = XX; TT = XX; AA = XX;

for aa = 1:length(rot_arr)
    for rr = 1:length(variable_arr)
        
        %         X = X_ARR{aa,rr}; Y = Y_ARR{aa,rr}; Z = Z_ARR{aa,rr};
        %         xh = XH_ARR{aa,rr}; yh = YH_ARR{aa,rr}; zh = ZH_ARR{aa,rr};
        x_pks = X_PKS_ARR{aa,rr};
        y_pks = Y_PKS_ARR{aa,rr};
        
        XX(1:length(x_pks),rr,aa) = x_pks;
        YY(1:length(y_pks),rr,aa) = y_pks;
        NN(1:length(x_pks),rr,aa) = 1:length(x_pks);
        TT(1:length(x_pks),rr,aa) = variable_arr(rr)*ones(length(x_pks),1);
        AA(1:length(x_pks),rr,aa) = rot_arr(aa)*ones(length(x_pks),1);
    end
end

%% plot surfaces
for aa = 1:length(rot_arr)
    subplot(1,3,1); hold on;
    surf(NN(:,:,aa),TT(:,:,aa),XX(:,:,aa),AA(:,:,aa),'edgecolor','none');
    subplot(1,3,2); hold on;
    surf(NN(:,:,aa),TT(:,:,aa),YY(:,:,aa),AA(:,:,aa),'edgecolor','none');
end

zlb_arr = {'x_{apex} (mm)','y_{apex} (mm)'};
for ff = 1:2
    subplot(1,3,ff);
    axis tight
    xlabel('n\circ');
    ylabel('\theta_{bend} (\circ)');
    zlabel(zlb_arr{ff});
    %     view(3);
    view([0,0]);
    axis tight;
    grid on;
    set(gca,'fontsize',8);
end

set(gcf,'position',[60,100,900,300]);
set(gcf,'paperposition',[0,0,6,2],'unit','inches');
