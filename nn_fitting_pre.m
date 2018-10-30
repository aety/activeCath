clear; clc; ca;
load catheter_simulator_findApex;

TGL_norm = 1;
TGL_shuffle = 1;

%%
readme = 'Varying bending angles and varying rotation angles';

pdt_txt_arr = {
    '|mean(d_{odd}) - mean(d_{even})|_{normal.}',... % average distance difference between odd and even
    '|mean(\alpha_{odd}) - mean(\alpha_{even})|',... % average slope difference between odd and even
    '[max(d_{lateral}) - min(d_{lateral})]_{normal.}',... % lateral distance, max - min
    'max(\alpha_{lateral})-min(\alpha_{lateral})',... % lateral slope, max - min
    'std(\alpha_{lateral})',... % lateral slope, std
    'std(d_{lateral})',... % lateral distance, std
    'd_{0,axial}',... % longitudinal distance of the first peak from the base of helix
    'mean(\Delta\alpha_{lateral})',... % average lateral slope change
    };

rsp_txt_arr = {'\theta_{rot}','\theta_{bend}'};

predictor = nan(length(pdt_txt_arr),size(X_ARR,1)*size(X_ARR,2));
response = nan(length(rsp_txt_arr),size(X_ARR,1)*size(X_ARR,2));

% find a first [x,y] point for reference
first_x = X_ARR{1,1}(end); 
first_y = Y_ARR{1,1}(end); 

c_arr = colormap(parula(1845));

for ii = 1:size(X_ARR,1)
    for jj = 1:size(X_ARR,2)
        
        % counter
        nn = ii + (jj-1)*size(X_ARR,1);
        
        % extrinsic properties
        x = X_PKS_ARR{ii,jj}; y = Y_PKS_ARR{ii,jj}; % (n)
        x_odd = x(1:2:end); y_odd = y(1:2:end); % (n_odd)
        x_even = x(2:2:end); y_even = y(2:2:end); % (n_even)
        
        alpha = atan2(diff(y),diff(x)); alpha(alpha<0) = alpha(alpha<0)+2*pi; % all slopes (n-1)
        alpha_odd = atan2(diff(y_odd),diff(x_odd)); alpha_odd(alpha_odd<0) = alpha_odd(alpha_odd<0)+2*pi; % odd slopes (n_odd-1)
        alpha_even = atan2(diff(y_even),diff(x_even)); alpha_even(alpha_even<0) = alpha_even(alpha_even<0)+2*pi; % even slopes (n_even-1)
        alpha_lat = [alpha_odd,alpha_even]; % odd and even slopes combined (n-2)
                
        
        
        % intrinsic properties
        d = sqrt(diff(x).^2 + diff(y).^2); % (n-1)
        d_odd = sqrt(diff(x_odd).^2 + diff(y_odd).^2); % odd distance (n_odd-1)
        d_even = sqrt(diff(x_even).^2 + diff(y_even).^2); % even distacene (n_even-1)
        d_lat = [d_odd,d_even]; % odd and even distances combined (lateral distances) (n-2)
        
        dalpha = diff(alpha); % (n-2)
        dalpha_odd = dalpha(1:2:end); % take slopes first and then separate odd/even (n_odd-1)
        dalpha_even = dalpha(2:2:end); % take slopes first and then separate odd/even (n_even-1)
        d_alphaodd = diff(alpha_odd); % separate odd/even first and than take slopes (n_odd-2)
        d_alphaeven = diff(alpha_even); % separate odd/even first and than take slopes (n_even-2)
        d_alpha_lat = [d_alphaodd,d_alphaeven]; % combined (n-4)
        
        %% calculate the longitudinal distance of the first peak from the first node of the helix
        % Here, to simulate how far the most proximal tracked peak is 
        % offset longitudinally from the most proximal end of the catheter,
        % we find the two points that forms a critical line. The line
        % passes through the first point of the helix, is perpendicular to
        % the catheter, and has a length of 2*a_helix. We than simply
        % calculate the distances from the tracked peak of interest to
        % these two points, respectively, and choose the lesser.         
        xh = XH_ARR{ii,jj}; yh = YH_ARR{ii,jj}; % find helix shape
        x = X_ARR{ii,jj}; y = Y_ARR{ii,jj}; % find catheter curve
        [xxx,yyy] = func_find_helix_start_pair(xh(end),yh(end),x,y,a_helix); 
        d0 = sqrt((x(end)-xxx).^2 + (y(end)-yyy).^2); % the most proximal point is with the last index 
        d0 = min(d0);
        
        %% list predictors (summarize into single parameters)
        predictor(:,nn) = [...
            (abs(mean(d_odd) - mean(d_even)))/mean(d_lat),... % average distance difference between odd and even
            abs(mean(alpha_odd) - mean(alpha_even)),... % average slope difference between odd and even
            range(d_lat)/mean(d_lat),... % NORMALIZED lateral distance, max - min
            range(alpha_lat),... % lateral slope, max - min
            std(alpha_lat),... % lateral slope, std
            std(d_lat),... % lateral distance, std
            d0,... % first node displacement 
            mean(d_alpha_lat),... % average lateral slope change
            ];              
        
        % list responses
        response(:,nn) = [rot_arr(ii);
            variable_arr(jj)];
    end
end

%%
n_col_plt = 4;
hold on;
c_arr = colormap(plasma(size(predictor,1)));
for kk = 1:size(predictor,1)
    subplot(n_col_plt,ceil(size(predictor,1)/n_col_plt),kk);
    plot(predictor(kk,:),'.','color',c_arr(kk,:));
    axis tight;
    title(pdt_txt_arr{kk},'color',c_arr(kk,:));
end

%%
if TGL_norm
    % Normalize predictors and responses for neural network
    [PDT,PDT_MX,PDT_mn] = nn_normalize_Mm(predictor);
    [RSP,RSP_MX,RSP_mn] = nn_normalize_Mm(response);
end

% randomly shuffle columns
if TGL_shuffle
    temp = [PDT;RSP];
    temp = temp(:,randperm(size(temp,2)));
    PDT = temp(1:size(PDT,1),:);  % save original predictor array
    RSP = temp(size(PDT,1)+1:end,:);    % save original response array
end

%% save
save nn_fitting_pre *_txt_arr readme PDT* RSP* TGL_*