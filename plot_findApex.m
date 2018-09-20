clear; clc; ca;
load circular_approx_curVar_wSine_3D_rotate_findApex_fine
color_arr = colormap(viridis(length(variable_arr)));
xminortick_size = diff(variable_arr(1:2))/(length(rot_arr)+1);

%% set up video maker
vidflag = 1;

if vidflag
    opengl('software');
    anim = VideoWriter(datestr(datetime('now'),'yyyy-mm-dd-HHMMss'),'Motion JPEG AVI');
    anim.FrameRate = 2;
    open(anim);
end

%% loop for rotation
view_arr = [-37.5+90,30; 0,90; 0,90; 0,90; 0,90];
xlab_arr = {'x (mm)','x (mm)','x_{apex} (mm)','\theta_{bend} (\circ)','\theta_{bend} (\circ)'};
ylab_arr = {'y (mm)','y (mm)','y_{apex} (mm)','x_{apex} (mm)','y_{apex} (mm)'};
% xlim_arr = {[60,100],[60,100],[70,95],[variable_arr(1),variable_arr(end) + xminortick_size*length(rot_arr)],[variable_arr(1),variable_arr(end) + xminortick_size*length(rot_arr)]};
xlim_arr = {[60,100],[60,100],[70,95],[variable_arr(1),variable_arr(end)],[variable_arr(1),variable_arr(end)]};
ylim_arr = {[0,L/2],[0,L/2],[0,40],[70,95],[0,40]};

for aa = 1:length(rot_arr)
    
    %% loop for bending the catheter
    for rr = 1:length(variable_arr)
        
        X = X_ARR{aa,rr}; Y = Y_ARR{aa,rr}; Z = Z_ARR{aa,rr};
        xh = XH_ARR{aa,rr}; yh = YH_ARR{aa,rr}; zh = ZH_ARR{aa,rr};
        X_PKS = X_PKS_ARR{aa,rr};
        Y_PKS = Y_PKS_ARR{aa,rr};
        
        for ff = 1:2
            subplot(1,5,ff);
            hold on
            plot3(X,Y,Z,'-','color',color_arr(rr,:),'linewidth',0.1); % plot catheter
            plot3(xh,yh,zh,'color',color_arr(rr,:),'linewidth',1); % plot helix
            text(X(end),Y(end),Z(end),num2str(variable_arr(rr)),'color',color_arr(rr,:),'fontsize',12);
        end
        plot(X_PKS,Y_PKS,'+','color',color_arr(rr,:),'markersize',3,'linewidth',3);
        
        subplot(1,5,3);
        hold on;
        plot(X_PKS,Y_PKS,'.','color',color_arr(rr,:),'markersize',8);
        
        subplot(1,5,4);
        hold on;
        %         plot(variable_arr(rr) + aa*xminortick_size, X_PKS,'.','color',color_arr(rr,:),'markersize',8);
        plot(variable_arr(rr), X_PKS,'.','color',color_arr(rr,:),'markersize',8);
        
        
        subplot(1,5,5);
        hold on;
        %         plot(variable_arr(rr) + aa*xminortick_size, Y_PKS,'.','color',color_arr(rr,:),'markersize',8);
        plot(variable_arr(rr), Y_PKS,'.','color',color_arr(rr,:),'markersize',8);
        
        
    end
    
    
    for ff = 1:3
        subplot(1,5,ff);
        axis equal;
    end
    
    ttl_arr = {'','x-y view','tracked apexes',['\theta_{rot} = ' num2str(rot_arr(aa)) '\circ'],['\theta_{rot} = ' num2str(rot_arr(aa)) '\circ']};
    
    for ff = 1:5
        
        subplot(1,5,ff);
        
        xlim(xlim_arr{ff});
        ylim(ylim_arr{ff});
        zlim([0,L/2]);
        view(view_arr(ff,:));
        
        % labels
        xlabel(xlab_arr{ff});
        ylabel(ylab_arr{ff});
        title(ttl_arr{ff},'fontweight','normal');
        set(gca,'fontsize',12);
    end
    
    
    % label catheter configuration
    subplot(1,5,1);
    grid on
    %         text(L/5,0,L/3,{[con_name ', L_{helix} = ' num2str(p1_helix) '~' num2str(p2_helix) ' %'];...
    %             [num2str(n_helix) ' sines at ' num2str(a_helix) ' mm']},'fontweight','normal');
    
    set(gcf,'position',[100,100,1500,300]);
    set(gcf,'color','w');
    
    if vidflag
        frame = getframe(figure(1));
        writeVideo(anim,frame);
    end
    
    for ff = 1:5
        subplot(1,5,ff);
        cla;
    end
    
end

if vidflag
    close(anim);
    close;
end