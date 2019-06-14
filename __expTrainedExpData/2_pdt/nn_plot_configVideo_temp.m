%% load data
clear; clc; close all;
% fname = 'findApex_3DoF';
% fname = 'incl_pitch_manualPicking';
% fname = '20SDF_H_30_short';
% fname = 'interp_btw_fr_res';

load C:\Users\yang\ownCloud\MATLAB\__experiment\roll_bend\pre_nn\positive\_pre_nn_positive_interp\interp_btw_fr_res
cd C:\Users\yang\ownCloud\MATLAB\__expTrainedExpData\2_pdt
fname = 'expTrainedExpData';
load(['nn_' fname]);
load(['..\pre_nn_' fname],'PDT');
PDT_txt{2} = 'd_{i,mean}';
PDT_txt{5} = '\alpha_{dist}';
uni = {'px','deg'};

%%
pos_img1 = [0,0.5,0.25,0.45];
pos_img2 = [0,0,0.25,0.45];
pos_pdt = [0.25,0.6,0.1,0.3];
pos_3d = [0.4,0,0.6,1];
pos_rsp = [0.25,0.1,0.1,0.3];
fsz = 20;
msz = 20;

%% sort results
tr = TR;
y = Y;
best_pdt = PDT_best;
ind = tr.testInd;

%% plot combined
carr = [66,206,227
    31,120,180
    178,223,138
    51,160,44
    251,154,153
    227,26,28
    253,191,111
    255,127,0]/255;
cmap = carr([4,6,7,1],:);

ind_list = randperm(length(ind));
bar_ylim = max(max(abs(RSP(ind)-y(ind))));

ro_arr = unique(RSP(1,:));
bd_arr = unique(RSP(2,:));
bd_fn = 'proc_auto_data_20SDR-H_30_00';
bd_fn_arr = {'03','21','67','83','99'};

for ii = 102%ind_list
    
    disp(ii);
    subplot('position',pos_3d);
    hold on;
    
    rsp_compare = [RSP(:,ind(ii)),y(:,ind(ii))];
    
    for mm = 1:2
        
        %% get catheter
        [X,Y,Z,xh,yh,zh,M] = GetSingleCatheter(rsp_compare(:,mm));
%         ht = plot3(X(end),Y(end),Z(end),'.','color',cmap(mm,:),'markersize',30);
        hc(mm) = scatter3(X,Y,Z,80,cmap(mm,:),'filled');
        alpha(hc(mm),0.5);
        plot3(xh,yh,zh,'color',cmap(mm,:),'linewidth',2);
        
        %% plot coordinate frame
        f = 20; M = f*M;
        xq = X(end)*ones(1,3); yq = Y(end)*ones(1,3); zq = Z(end)*ones(1,3);
        u = M(1,:); v = M(2,:); w = M(3,:);
        hq = quiver3(xq,yq,zq,u,v,w,'filled','color',cmap(mm,:),'linewidth',1,'maxheadsize',1);
        
    end
    legend(hc,'ground truth','NN output','location','northwest','orientation','horizontal','fontsize',fsz);
    axis equal;
    axis tight;
    view([-37.5+90,15]);
    grid on;
    xlabel('x (mm)'); ylabel('y (mm)'); zlabel('z (mm)');
    axis([-2,100,-2,65,-2,40]);
%     set(gca,'xticklabel',[],'yticklabel',[],'zticklabel',[]);
    set(gca,'fontsize',fsz);
    
    %% predictors
    subplot('position',pos_pdt);
    %     plot(PDT(1,ind(ii)),PDT(2,ind(ii)),'ok','markerfacecolor','k');
    %     xlim([min(PDT(1,:)),max(PDT(1,:))]);
    %     ylim([min(PDT(2,:)),max(PDT(2,:))]);
    %     xlabel(PDT_txt(best_pdt(1)),'fontsize',fsz);
    %     ylabel(PDT_txt(best_pdt(2)),'fontsize',fsz);
    for tt = 1:2
        text(0,tt,[PDT_txt{best_pdt(tt)} ' = ' num2str(PDT(tt,ind(ii)),4) ' (' uni{tt} ')'],'fontsize',fsz);
    end
    ylim([0,3]);
    xlim([0.5,2]);
    axis off;
    title('input','fontsize',fsz);
    
    %% rsp
    subplot('position',pos_rsp);
    colormap(cmap([1,2],:));
    b = bar([1,2],rsp_compare(1:2,:),0.4,'edgecolor','none','facecolor','flat');
    for k = 1:2
        b(k).CData = k;
        b(k).FaceAlpha = 0.5;
    end
    xlim([.5,2.5]);
    ylim([0,max(max(RSP(:,ind)))]);
    set(gca,'xtick',[1,2],'xticklabel',RSP_txt(1:2));
    set(gca,'fontsize',fsz);
    title('output','fontsize',fsz);
    
    %% image display
    select_bd = bd_arr==RSP(2,ind(ii));
    load(['C:\Users\yang\ownCloud\MATLAB_largefiles\__experiment\roll_bend\proc\' bd_fn bd_fn_arr{select_bd} '_wImage'],'I_disp_arr','REF');
    ref = unique(REF);
    
    select_ro = ro_arr==RSP(1,ind(ii));
    I = imrotate(I_disp_arr{select_ro},0);
    clear I_disp_arr;
    subplot('position',pos_img1);
    imshow(I);
    ylim([150,550]);
    %     title('original','fontsize',fsz);
    camroll(-90);
    subplot('position',pos_img2);
    imshow(I);
    ylim([150,550]);
    hold on;
    pk1 = PKS1(:,:,select_ro,select_bd);
    pk2 = PKS2(:,:,select_ro,select_bd);
    h1 = plot(pk1(:,1)+ref(1),-pk1(:,2)+ref(2),'.','color',cmap(3,:),'markersize',msz);
    h2 = plot(pk2(:,1)+ref(1),-pk2(:,2)+ref(2),'.','color',cmap(4,:),'markersize',msz);
    plot(ref(1),ref(2),'.','color','w','markersize',msz);
    camroll(-90);
    %     title('processed','fontsize',fsz);
    legend([h1,h2],'concave','convex','fontsize',fsz,'location','north');
    
    %%
    set(gcf,'paperposition',[0,0,17,8],'unit','inches');
    print('-dtiff','-r300','nn_plot_configVideo_temp');
    close;
    
end