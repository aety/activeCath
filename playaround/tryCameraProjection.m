mks = 2; % markersize

% define camera rotation axis
rot_ax = 3; % 1-->x, 2-->y, 3-->z % camera rotation axis 
rot_ax_n = 'z'; % name of camera rotation axis

% define camera rotation amount
rot_arr = [-30,0,30]; % camera rotation angle array 

% vary object location along y-axis
y_offset = 0:5; 

% generate object to project (object is above the camera along the z-axis)
ang = linspace(0,2*pi,100);
x = cos(ang); y = sin(ang); z = 5*ones(1,length(ang));

% define camera and image plane
c = [0;0;0]; % camera location 
e = [0;0;-2.5]; % image plane "relative to camera" (negagive: behind the camera)


for rr = 1:length(rot_arr)
    
    figure;
    
    th = [0;0;0];
    th(rot_ax) = rot_arr(rr);
    th = th*pi/180;
    
    ROT = getRX(th(1))*getRY(th(2))*getRZ(th(3));
    
    c_arr = colormap(parula(length(y_offset)));
    hold on;
    b_arr = nan(2,length(ang),length(y_offset));
    
    for tt = 1:length(y_offset)
        
        a = [x; y+y_offset(tt); z]; % 3 camera rotation angles
        
        b = nan(2,length(ang)); % preallocate 
        d_arr = nan(3,length(ang)); % preallocate 
        for nn = 1:length(ang)
            
            d = ROT*(a(:,nn)-c);
            b(:,nn) = (e(3)/d(3))*d(1:2) + e(1:2);
            d_arr(:,nn) = d;
        end
        b_arr(:,:,tt) = b;
        
        subplot(1,3,1);
        hold on;
        plot3(a(1,:),a(2,:),a(3,:),'.','markersize',mks,'color',c_arr(tt,:));
        
        subplot(1,3,2);
        hold on;
        plot3(d_arr(1,:),d_arr(2,:),d_arr(3,:),'.','color',c_arr(tt,:),'markersize',mks);
        
        subplot(1,3,3);
        hold on;
        plot3(b(1,:),b(2,:),(c(3)-e(3))*ones(1,length(ang)),'.','color',c_arr(tt,:),'markersize',mks);
        %
        
    end
    subplot(1,3,1);
    plotCamera('Location',c,'Orientation',ROT,'Color','k','Size',1);
    
    subplot(1,3,2);
    plotCamera('Location',[0,0,0],'Color','k','Size',1);
    
    v_arr = [3,3,2];
    for pp = 1:3
        subplot(1,3,pp);
        axis tight;
        axis equal;
        xlabel('x');
        ylabel('y');
        zlabel('z');
        view(v_arr(pp));
        grid on;
        set(gca,'fontsize',8);
    end
    title(['\theta_{cam, ' rot_ax_n '} = ' num2str(rot_arr(rr))]);
    
    set(gcf,'position',[1700,450,1200,400]);
    set(gcf,'paperposition',[0,0,4,2]);
    print('-dtiff','-r300',['tryCameraProjection_' rot_ax_n '_' num2str(rot_arr(rr))]);
    close;
end