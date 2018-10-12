clear; clc; ca;
load circular_approx_curVar_wSine_3D_rotate_findApex;

%%
readme = 'Varying bending angles and varying rotation angles';

pdt_arr = {'x_{mean}','y_{mean}','xy_{mean}',...
    'x_{std}','y_{std}','xy_{std}',...
    'x_{max}','y_{max}','xy_{max}',...
    'x_{min}','y_{min}','xy_{min}'};

rsp_arr = {'\theta_{rot}','\theta_{bend}'};

predictor = nan(size(X_ARR,1),15);
response = nan(size(X_ARR,1),2);

for ii = 1:size(X_ARR,1)
    for jj = 1:size(X_ARR,2)
        
        x = X_PKS_ARR{ii,jj};
        y = Y_PKS_ARR{ii,jj};
        
        nn = ii + (jj-1)*size(X_ARR,1);
        
        x_odd = x(1:2:end);
        x_even = x(2:2:end);
        y_odd = y(2:2:end);
        y_even = y(2:2:end);
        
        predictor(nn,1) = mean(x);
        predictor(nn,2) = mean(y);
        predictor(nn,3) = mean(sqrt(x.^2 + y.^2));
        
        predictor(nn,4) = std(x);
        predictor(nn,5) = std(y);
        predictor(nn,6) = std(sqrt(x.^2 + y.^2));
        
        predictor(nn,7) = max(x);
        predictor(nn,8) = max(y);
        predictor(nn,9) = max(sqrt(x.^2 + y.^2));
        
        predictor(nn,10) = min(x);
        predictor(nn,11) = min(y);
        predictor(nn,12) = min(sqrt(x.^2 + y.^2));
        
        % slope change
        % different sides of the catheter 
        
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
save nn_neural_fitting_2D_pre predictor response txt_arr readme;