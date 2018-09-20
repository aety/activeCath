%% define parameters
L = 100; % catheter length (mm)
L_res = 1; % catheter node points resolution (mm)

% % pct_mark = 20; % length of catheter with marker (mm)
% % amp_mark = 1; % amplitude of the helix (mm)
% % per_mark = 2; % spatial period of the helix (mm)

pct_bend = 100; % percent of catheter length to bend (%)
th_bend = 30; % rotation of each link w.r.t. previous (deg)
%% calculate geometry

X = 0:L_res:L; % catheter X

n = nan(3,length(X));
n(:,1) = [0;0;1];

npt_org = round(0.01*(100 - pct_bend)*length(X)); % number of nodes unbent (node index from which bending begins)
npt_bend = (length(X) - npt_org); % number of nodes bent

th = th_bend/npt_bend; % bending angle for each segment (evenly divided)
th_arr = [zeros(1,npt_org),th*ones(1,npt_bend)]; % full array of bending angles for each segment)

hold on;
for ii = 2:length(X)
    n(:,ii) = M_rotate(th_arr(ii)*pi/180)*M_transl(L_res)*n(:,ii-1); 
end

X = n(1,:);
Y = n(2,:);

%% identify apexes projected onto the wire

% x_mark = 0:L_res:len_mark; 
% y_mark = amp_mark*sin(2*pi*fre_mark*x_mark); % helix Y);
% x_mark = x_mark + (L - len_mark); % helix X

%% visualize
figure(1);
plot(X,Y,'.-');
hold on;
% plot(x_mark,y_mark,'.-');
axis equal
set(gcf,'position',[-1919, -226, 1920, 963]);