%% load data
clear; clc; close all;
% fname = 'findApex_3DoF';
% fname = 'incl_pitch_manualPicking';
% fname = '20SDF_H_30_short';
% fname = 'interp_btw_fr_res';

load C:\Users\yang\ownCloud\MATLAB\__experiment\roll_bend\pre_nn\positive\_pre_nn_positive_interp\interp_btw_fr_res
cd C:\Users\yang\ownCloud\MATLAB\__expTrainedExpData\3_pdt
fname = 'expTrainedExpData';
load(['nn_' fname]);

%% 
pos_img = [0,0,0.4,0.9];
pos_3d = [0.5,0.3,0.4,0.7];
pos_err = [0.7,0.1,0.2,0.2];
fsz = 10;

%% sort results
tr = TR;
y = Y;
best_pdt = PDT_best;
ind = tr.testInd;

%% initialize video
vidflag = 1; % save video
vidrate = 2; % video frame rate

if vidflag
    opengl('software');
    anim = VideoWriter(['nn_plot_ConfigVideo_' fname],'Motion JPEG AVI');
    anim.FrameRate = vidrate;
    open(anim);
end

%% plot combined
cmap = [33,113,181;
    217,72,1]/255;
cmapl = [158,202,225;
    253,174,107]/255; % light
carr = colormap(lines);

ind_list = randperm(length(ind));
bar_ylim = max(max(abs(RSP(ind)-y(ind))));

ro_arr = unique(RSP(1,:));
bd_arr = unique(RSP(2,:));
bd_fn = 'proc_auto_data_20SDR-H_30_00';
bd_fn_arr = {'03','21','67','83','99'};

for ii = ind_list
    
    disp(ii);
    subplot('position',pos_3d);
    hold on;
    
    rsp_compare = [RSP(:,ind(ii)),y(:,ind(ii))];
    
    for mm = 1:2
        
        %% get catheter
        [X,Y,Z,xh,yh,zh,M] = GetSingleCatheter(rsp_compare(:,mm));
        ht = plot3(X(end),Y(end),Z(end),'.','color',cmap(mm,:),'markersize',20);
        %         ha = scatter3(X,Y,Z,10,cmapl(mm,:),'filled');
        %         alpha(ha,0.75);
        hc = plot3(X,Y,Z,'color',cmapl(mm,:),'linewidth',5);
        %         hb = scatter3(xh,yh,zh,5,cmapl(mm,:),'filled');
        %         alpha(hb,0.75);
        plot3(xh,yh,zh,'color',cmapl(mm,:));
        
        %% plot coordinate frame
        f = 20; M = f*M;
        xq = [0,0,0]; yq = xq; zq = xq;
        u = -M(1,:); v = M(2,:); w = M(3,:);
        hq = quiver3(xq,yq,zq,u,v,w,'filled','color',cmap(mm,:),'linewidth',1,'maxheadsize',0.2);
    end
    legend([ht,hq,hc],'catheter tip','catheter frame','catheter','location','northwest');
    axis equal;
    axis tight;
    view([-37.5+180,30]);
    grid on;
    axis([-10,110,-10,50,0,50]);
    set(gca,'xticklabel',[],'yticklabel',[],'zticklabel',[]);
    set(gca,'fontsize',fsz);
    
    subplot('position',pos_err);
    err = abs(diff(rsp_compare'));
    bar([1,2],err(1:2),0.4,'k');
    ylim([0,bar_ylim]);
    set(gca,'xtick',[1,2],'xticklabel',RSP_txt(1:2));
    ylabel('error (deg)')
    set(gca,'fontsize',fsz);
    box off;
    
    %% image display
    select_bd = bd_arr==RSP(2,ind(ii));
    load(['C:\Users\yang\ownCloud\MATLAB_largefiles\__experiment\roll_bend\proc\' bd_fn bd_fn_arr{select_bd} '_wImage'],'I_disp_arr','REF');
    ref = unique(REF);
    
    select_ro = ro_arr==RSP(1,ind(ii));
    I = I_disp_arr{select_ro};
    clear I_disp_arr;
    subplot('position',pos_img);
    imshow(I);
    hold on;
    pk1 = PKS1(:,:,select_ro,select_bd);
    pk2 = PKS2(:,:,select_ro,select_bd);
    plot(pk1(:,1)+ref(1),-pk1(:,2)+ref(2),'.','color',carr(5,:),'markersize',15);
    plot(pk2(:,1)+ref(1),-pk2(:,2)+ref(2),'.','color',carr(6,:),'markersize',15);
    
    %%
    set(gcf,'position',[500,100,900,600]);
    if vidflag
        removeToolbarExplorationButtons;
        frame = getframe(gcf);
        writeVideo(anim,frame);
        clf;
    end
    
end

if vidflag
    close(anim);
    close;
end

cd C:\Users\Yang\Documents\MATLAB