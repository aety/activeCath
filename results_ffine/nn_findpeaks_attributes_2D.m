clear; clc; ca;
load circular_approx_curVar_wSine_3D_rotate_findApex;

%%
readme = 'Varying bending angles and varying rotation angles';

% x0 = X_PKS_ARR{1,jjj}(end);
% y0 = Y_PKS_ARR{1,jjj}(end);

txt_arr = {'x sum','y sum','xy sum',...
    'x mean','y mean','xy mean',...
    'x std','y std','xy std',...
    'x max','y max','xy max',...
    'x min','y min','xy min'};

predictor = nan(size(X_ARR,1),15);
response = nan(size(X_ARR,1),2);

for ii = 1:size(X_ARR,1)
    for jj = 1:size(X_ARR,2)
        
        x = X_PKS_ARR{ii,jj};
        y = Y_PKS_ARR{ii,jj};
        
        nn = ii + (jj-1)*size(X_ARR,1);
        predictor(nn,1) = sum(x);
        predictor(nn,2) = sum(y);
        predictor(nn,3) = sum(sqrt(x.^2 + y.^2));
        
        predictor(nn,4) = mean(x);
        predictor(nn,5) = mean(y);
        predictor(nn,6) = mean(sqrt(x.^2 + y.^2));
        
        predictor(nn,7) = std(x);
        predictor(nn,8) = std(y);
        predictor(nn,9) = std(sqrt(x.^2 + y.^2));
        
        predictor(nn,10) = max(x);
        predictor(nn,11) = max(y);
        predictor(nn,12) = max(sqrt(x.^2 + y.^2));
        
        predictor(nn,13) = min(x);
        predictor(nn,14) = min(y);
        predictor(nn,15) = min(sqrt(x.^2 + y.^2));
        
%         predictor(nn,16) = atan2(y(end)-y0,x(end)-x0);
        
        response(nn,1) = rot_arr(ii);
        response(nn,2) = variable_arr(jj);
    end
end

%%
hold on;
c_arr = colormap(plasma(size(predictor,2)));
for kk = 1:size(predictor,2)
    subplot(4,4,kk);
    plot(predictor(:,kk),'*','color',c_arr(kk,:));
    title(txt_arr{kk},'color',c_arr(kk,:));
end

%% save
save nn_findpeaks_attributes_2D predictor response txt_arr readme;