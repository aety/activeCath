%% load data
clear; clc; close all;
load C:\Users\yang\ownCloud\MATLAB\__experiment\roll_bend\pre_nn\positive\_pre_nn_positive_interp\interp_btw_fr_res
cd C:\Users\yang\ownCloud\MATLAB\__expTrainedExpData\2_pdt
fname = 'expTrainedExpData';
load(['nn_' fname]);
load(['..\pre_nn_' fname],'PDT');

fsz = 16;
msz = 25;

%% sort results
tr = TR;
y = Y;
best_pdt = PDT_best;
ind = tr.testInd;

%% plot combined
ii = 102;
ro_arr = unique(RSP(1,:));
bd_arr = unique(RSP(2,:));
select_bd = bd_arr==RSP(2,ind(ii));
select_ro = ro_arr==RSP(1,ind(ii));
load(['illustrate_PDT_' num2str(ii)]);

yl = [350,550]; % axis limit
xl = [300,400]; % axis limit

%% plot peaks on top of image
inc = [0,max(max(I))];

for ii = 1:2
    
    carr = colormap(lines);
    Ip = I + inc(ii);
    imshow(Ip); hold on;
    ylim(yl);
    xlim(xl);
    
    pk1 = PKS1(:,:,select_ro,select_bd);
    pk2 = PKS2(:,:,select_ro,select_bd);
    h1 = plot(pk1(:,1)+ref(1),-pk1(:,2)+ref(2),'ok','markerfacecolor',carr(3,:),'markersize',msz/3,'linewidth',1);
    h2 = plot(pk2(:,1)+ref(1),-pk2(:,2)+ref(2),'ok','markerfacecolor',carr(6,:),'markersize',msz/3,'linewidth',1);
    hr = plot(ref(1),ref(2),'ok','markerfacecolor',0.95*[1,1,1],'markersize',msz/3,'linewidth',1);
    camroll(-90);
    
    set(gca,'position',[0,0,1,1]);
    wd = 900;
    set(gcf,'position',[500,300,wd,wd*range(xl)/range(yl)]);
    wd = 6;
    set(gcf,'paperposition',[0,0,wd,wd*range(xl)/range(yl)]);
    cd C:\Users\yang\ownCloud\MATLAB
    print('-dtiff','-r300',['illustrate_PDT' num2str(ii)]);
    close;
    
end