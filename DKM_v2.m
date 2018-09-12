clear; close all; clc;

%% define parameters
L = 50; % catheter length (mm)
L_res = 1; % catheter node points resolution (mm)

pct_bend = 50; % percent of catheter length to bend (%)
th_bend = 10; % rotation of each link w.r.t. previous (deg)

%%

% % % % for nnn = 10%1:30

%% calculate geometry

X = [0, 0.01*pct_bend*L:L_res:L]; % catheter X

% npt_org = round(0.01*(100 - pct_bend)*length(X)); % number of nodes unbent (node index from which bending begins)
% npt_bend = (length(X) - npt_org); % number of nodes bent
npt_bend = length(X);

th = th_bend/npt_bend; % bending angle for each segment (evenly divided)
th_arr = [0,th*ones(1,npt_bend)]; % full array of bending angles for each segment)
% th_arr = [zeros(1,nnn),0.1*ones(1,length(X)-nnn)]; % diagnostics
% th_arr = [0.1*ones(1,length(X)-nnn),zeros(1,nnn)]; % diagnostics


n = nan(4,length(X));
n(:,1) = [0;0;1;1];

L_arr = [0,0.01*pct_bend*L,L_res*ones(1,npt_bend)];

% % MM = eye(4);

for ii = 2:length(X)
% %     MM = M_DH(0,th_arr(ii)*pi/180,L_res,0)*MM;
    n(:,ii) = M_DH(0,th_arr(ii)*pi/180,L_arr(ii),0)*n(:,ii-1); 
% %     n2(:,ii) = MM*n(:,1); 
end

X = n(1,:);
Y = n(2,:);

%% visualize
% % % figure(1);
plot(X,Y,'*-');
% % % hold on;
% % % plot(x_mark,y_mark,'.-');
% % axis equal
% % set(gcf,'position',[-1919, -226, 1920, 963]);

%% diagnostics
% % % for ii = 2:length(X)
% % %     test(ii) = atand( ( Y(ii) - Y(ii-1) ) / ( X(ii) - X(ii-1) ));
% % % end
% % % hold on
% % % % plot(test,'*-');
% % % % xlabel('node number');
% % % % ylabel('local bending angle (appox. by slope)');

%%
% % % % end