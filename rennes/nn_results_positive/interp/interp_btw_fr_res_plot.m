clear;
clc;
ca;

load interp_btw_fr_res PKS1 PKS2
load pre_nn_interp_btw_fr_res th_roll_act_arr th_bend_act_arr
arr_fr = 13:154;    % define number of frames (temporal), default: 1:size(PKS1,3)
n_cl = 14;          % define number of nodes (spatial) (default: size(PKS1,1)
n_bd = size(PKS1,4);% define number of bending angle, default: size(PKS1,4)

r_range = th_roll_act_arr(arr_fr([end,1])); cmap1 = PuBu; cmap2 = YlOrBr; % for "positive"
x_lim = [0,400]; % figure y-limin (pixels)

%% plot
mks = 5; 
for dd = 1:n_bd
    for cc = 1:n_cl
        
        hold on;
        
        yyaxis left;
        plt = permute(PKS1(cc,:,arr_fr,dd),[3,2,1]);
        scatter(plt(:,2),-plt(:,1),mks,arr_fr,'filled');
        fig = gcf;
        fig.Colormap = cmap1;
        
        yyaxis right;
        plt = permute(PKS2(cc,:,arr_fr,dd),[3,2,1]);
        scatter(plt(:,2),-plt(:,1),mks,arr_fr,'filled');
        b = gca;
        b.Colormap = cmap2;
    end
    
    yyaxis left; axis tight;
    axl = axis;
    yyaxis right; axis tight;
    axr = axis;
    
    temp = [x_lim,min([axl(3),axr(3)]),max([axl(4),axr(4)])];
    if temp(4) < 40
        temp(4) = 45;
    end
    yyaxis left; axis(temp); yyaxis right; axis (temp);
    axis off;
    
    text(10,temp(4)-15,['\theta_{bend} = ' num2str(th_bend_act_arr(dd),3) '^\circ'],'fontsize',10);
    
    w_ratio = diff(temp(3:4))/diff(temp(1:2));
    wd = 800;
    set(gcf,'position',[1000,100,wd,wd*w_ratio]);
    wd = 3.5;
    set(gcf,'paperposition',[1000,100,wd,wd*w_ratio],'unit','inches');
    set(gca,'position',[0.05,0.05,0.90,0.90]);
    
    print('-dtiff','-r300',['interp_btw_fr_res_plot_' num2str(dd)]);
    close;
end

%%
txt_arr = {'convex','concave'};

carr = {cmap1,cmap2};
for cc = 1:2
    figure;
    colormap(carr{cc});
    axis off;
    cb = colorbar('southoutside'); % horizontal
    cb.Box = 'off';
    cb.Position = [0.1, 0.5, 0.8, 0.1]; % horizontal
    ylabel(cb,['\theta_{roll} ' txt_arr{cc}],'fontsize',10);
    th1 = arr_fr(end); the = arr_fr(1);
    cb.Ticks = 0:0.2:1;
    temp = interp1([0,1],[th1,the],cb.Ticks);
    cb.TickLabels = round(temp);
    set(gcf,'paperposition',[0,0,3.5,1]); % horizontal
    print('-dtiff','-r300',['interp_btw_fr_res_plot_cb_' num2str(cc)]);
    close;
end