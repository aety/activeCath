%% define parameters
L = 50; % catheter length (mm)
L_res = 1; % catheter node points resolution (mm)

pct_mark = 20; % length of catheter with marker (mm)
amp_mark = 1; % amplitude of the helix (mm)
per_mark = 2; % spatial period of the helix (mm)

th_end = 30; % rotation of each link w.r.t. previous (deg)
%% calculate geometry

X = 0:L_res:L; % catheter X

n = nan(3,length(X));
n(:,1) = [0;0;1];

th = th_end/length(X);

for ii = 2:length(X)
    n(:,ii) = M_rotate(th*pi/180)*M_transl(L_res)*n(:,ii-1); 
end

X = n(1,:);
Y = n(2,:);

%% identify apexes projected onto the wire

% x_mark = 0:L_res:len_mark; 
% y_mark = amp_mark*sin(2*pi*fre_mark*x_mark); % helix Y);
% x_mark = x_mark + (L - len_mark); % helix X

%% visualize
plot(X,Y,'.-');
hold on;
% plot(x_mark,y_mark,'.-');
axis equal