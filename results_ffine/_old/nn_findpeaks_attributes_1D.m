clear; clc; ca;
load circular_approx_curVar_wSine_3D_rotate_findApex;

%%
readme = 'Constant bending angle (50 deg), varying rotation angles';
jjj = 10;

x0 = X_PKS_ARR{1,jjj}(end);
y0 = Y_PKS_ARR{1,jjj}(end);

txt_arr = {'x sum','y sum','xy sum',...
    'x mean','y mean','xy mean',...
    'x std','y std','xy std',...
    'x max','y max','xy max',...
    'x min','y min','xy min',...
    'end slope'};

predictor = nan(size(X_ARR,1),16);
response = nan(size(X_ARR,1),1);

for ii = 1:size(X_ARR,1)
    for jj = jjj
        
        x = X_PKS_ARR{ii,jj};
        y = Y_PKS_ARR{ii,jj};
        
        predictor(ii,1) = sum(x);
        predictor(ii,2) = sum(y);
        predictor(ii,3) = sum(sqrt(x.^2 + y.^2));
        
        predictor(ii,4) = mean(x);
        predictor(ii,5) = mean(y);
        predictor(ii,6) = mean(sqrt(x.^2 + y.^2));
        
        predictor(ii,7) = std(x);
        predictor(ii,8) = std(y);
        predictor(ii,9) = std(sqrt(x.^2 + y.^2));
        
        predictor(ii,10) = max(x);
        predictor(ii,11) = max(y);
        predictor(ii,12) = max(sqrt(x.^2 + y.^2));
        
        predictor(ii,13) = min(x);
        predictor(ii,14) = min(y);
        predictor(ii,15) = min(sqrt(x.^2 + y.^2));
        
        predictor(ii,16) = atan2(y(end)-y0,x(end)-x0);
        
        response(ii,1) = rot_arr(ii);
    end
end
hold on;
c_arr = colormap(plasma(16));
for kk = 1:16
    subplot(4,4,kk);
    plot(rot_arr,predictor(:,kk),'*','color',c_arr(kk,:));
    title(txt_arr{kk},'color',c_arr(kk,:));
end

%% save
save nn_findpeaks_attributes_1D predictor response txt_arr readme;