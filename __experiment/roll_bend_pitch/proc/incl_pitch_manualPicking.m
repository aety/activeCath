clear;ca;clc;

load incl_pitch_pre *_arr ref_pt X Y

npt = 15; % number of points on each side

pr = 70; % plot range (x and y direction) (pixels)
c_arr = {'m','b'};
t_txt = {'left','right'};

PKS = cell(length(I_arr),1);
% TGL = PKS;

for ff = 1:length(I_arr)
    
    I = I_arr{ff};
    
    imshow(imsharpen(I,'radius',0.5,'amount',1)); hold on;
    plot(ref_pt(1),ref_pt(2),'ow','linewidth',2);
    
    set(gcf,'position',[700,200,1000,1000]);
    title('pick center of zoom-in view');
    
    xx = []; yy = []; 
    nn = 0;
    
    for bb = 1:2
        
        x = ref_pt(1); y = ref_pt(2) - 20;
        xlim(x + [-1,1]*pr/2);
        ylim(y + [-1,1]*pr/2);
        
        for ii = 1:npt
            
            nn = nn + 1;
            
            title({['frame ' num2str(ff) ', peak number ' num2str(nn)];...
                t_txt{bb}});
            
            [x,y,b] = ginput(1);
            
            xlim(x + [-1,1]*pr/2);
            ylim(y + [-1,1]*pr/2);
            
            plot(x,y,'x','color',c_arr{bb},'linewidth',2);
            
            xx = [xx,x];
            yy = [yy,y];
        end
    end
    
    tgl = [zeros(1,npt),ones(1,npt)];
    
    PKS{ff} = [xx;yy;tgl];    
%     TGL{ff} = tgl;
    close;
    save incl_pitch_manualPicking_temp X Y ff % TGL 
end

save proc_incl_pitch_manualPicking *_arr ref_pt X Y ff % TGL