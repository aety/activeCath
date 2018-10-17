clear; clc; ca;
load circular_approx_curVar_wSine_3D_rotate_findApex;

%%
readme = 'Varying bending angles and varying rotation angles';

pdt_txt_arr = {'x_{mean}','y_{mean}','d_{mean}',...
    'x_{mean,odd}','y_{mean,odd}','d_{mean,odd}',...
    'x_{mean,even}','y_{mean,even}','d_{mean,even}',...
    'x_{mean,o-e}','y_{mean,o-e}','d_{mean,o-e}',...
    'x_{std}','y_{std}','d_{std}',...
    'x_{std,odd}','y_{std,odd}','d_{std,odd}',...
    'x_{std,even}','y_{std,even}','d_{std,even}',...
    'x_{std,o-e}','y_{std,o-e}','d_{std,o-e}',...
    '\alpha_{mean}','\alpha_{std}',...
    '\Delta\alpha_{mean}','\Delta\alpha_{std}',...
    };

rsp_txt_arr = {'\theta_{rot}','\theta_{bend}'};

predictor = nan(length(pdt_txt_arr),size(X_ARR,1));
response = nan(length(rsp_txt_arr),size(X_ARR,1));

for ii = 1:size(X_ARR,1)
    for jj = 1:size(X_ARR,2)
        
        % counter
        nn = ii + (jj-1)*size(X_ARR,1);
        
        % extract peaks in each frame
        x = X_PKS_ARR{ii,jj};   % helix peaks x
        y = Y_PKS_ARR{ii,jj};   % helix peaks y
        d = sqrt(x.^2 + y.^2);  % helix peaks distance from origin
        
        % separate odd and even indices
        x_odd = x(1:2:end);     % helix peaks x odd
        y_odd = y(1:2:end);     % helix peaks y odd
        d_odd = d(1:2:end);     % helix peaks d odd
        x_even = x(2:2:end);    % helix peaks x even
        y_even = y(2:2:end);    % helix peaks x even
        d_even = d(2:2:end);    % helix peaks d even
        
        % slope change
        alpha= atan2(diff(y),diff(x));  % arctangent of local slopes (length = N-1)
        dalpha = diff(alpha);           % change of the arctangent of local slopes (length = N-2)
        
        % list predictors
        predictor(:,nn) = [mean(x);
            mean(y);
            mean(d);
            mean(x_odd);
            mean(y_odd);
            mean(d_odd);
            mean(x_even);
            mean(y_even);
            mean(d_even);
            mean(x_odd) - mean(x_even);
            mean(y_odd) - mean(y_even);
            mean(d_odd) - mean(d_even);
            std(x);
            std(y);
            std(d);
            std(x_odd);
            std(y_odd);
            std(d_odd);
            std(x_even);
            std(y_even);
            std(d_even);
            std(x_odd) - std(x_even);
            std(y_odd) - std(y_even);
            std(d_odd) - std(d_even);
            mean(alpha);
            std(alpha);
            mean(dalpha);
            std(dalpha)];
        
        % list responses
        response(:,nn) = [rot_arr(ii);
            variable_arr(jj)];
    end
end

%%
n_col_plt = 3;
hold on;
c_arr = colormap(plasma(size(predictor,1)));
for kk = 1:size(predictor,1)
    subplot(n_col_plt,ceil(size(predictor,1)/n_col_plt),kk);
    plot(predictor(kk,:),'.','color',c_arr(kk,:));
    axis tight;
    title(pdt_txt_arr{kk},'color',c_arr(kk,:));
end

%% save
save nnu_fitting_2D_pre predictor response *_txt_arr readme;