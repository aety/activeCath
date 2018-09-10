%% define parameters
L = 50; % catheter length (mm)
L_res = 0.1; % catheter node points resolution (mm)

pct_mark = 20; % length of catheter with marker (mm)
amp_mark = 1; % amplitude of the helix (mm)
fre_mark = 0.5; % spatial frequency of the helix (count)

%% calculate geometry
X = 0:L_res:L; % catheter X
Y = zeros(length(X),1); % catheter Y

x_mark = 0:L_res:len_mark; 
y_mark = amp_mark*sin(2*pi*fre_mark*x_mark); % helix Y);
x_mark = x_mark + (L - len_mark); % helix X

%% visualize
plot(X,Y,'.-');
hold on;
plot(x_mark,y_mark,'.-');
axis equal