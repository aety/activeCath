%% load data
clear; clc; close all;
load C:\Users\yang\ownCloud\MATLAB\__experiment\roll_bend\pre_nn\positive\_pre_nn_positive_interp\interp_btw_fr_res
cd C:\Users\yang\ownCloud\MATLAB\__expTrainedExpData\2_pdt
fname = 'expTrainedExpData';
load(['nn_' fname]);
load(['..\pre_nn_' fname],'PDT');

fsz = 16;
msz = 20;

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

%% image display
carr = colormap(lines);
imshow(I);
ylim([250,550]);
xlim([250,400]);
hold on;

%% plot peaks
pk1 = PKS1(:,:,select_ro,select_bd);
pk2 = PKS2(:,:,select_ro,select_bd);
h1 = plot(pk1(:,1)+ref(1),-pk1(:,2)+ref(2),'.','color',carr(3,:),'markersize',msz);
h2 = plot(pk2(:,1)+ref(1),-pk2(:,2)+ref(2),'.','color',carr(7,:),'markersize',msz);
hr = plot(ref(1),ref(2),'.','color','w','markersize',msz);
camroll(-90);

set(gca,'position',[0,0,1,1]);
set(gcf,'position',[500,300,900,450]);