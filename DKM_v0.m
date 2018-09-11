%% define parameters
L = 50; % catheter length (mm)
L_res = 0.1; % catheter node points resolution (mm)

pct_mark = 20; % length of catheter with marker (mm)
amp_mark = 0.5; % amplitude of the helix (mm)
per_mark = 3; % spatial period of the helix (mm)

%% calculate geometr
X = 0:L_res:L; % catheter X
Y = zeros(length(X),1); % catheter Y

len_mark = 0.01*pct_mark*L;
x_mark = 0:L_res:len_mark; 
y_mark = amp_mark*sin(2*pi*x_mark/per_mark);
x_mark = x_mark + (L - len_mark); % helix X

%% visualize
plot(X,Y,'.-');
hold on;
plot(x_mark,y_mark,'.-');
axis equal