clear; clc; ca;
load incl_pitch_pre
load incl_pitch_manualPicking

vidflag = 1;
vidrate = 5;
c_arr = lines(6); c_lab_y = c_arr(2,:); c_lab_b = c_arr(6,:); % marker color label

if vidflag
    opengl('software');
    anim = VideoWriter('incl_pitch_manualPicking_','Motion JPEG AVI');
    anim.FrameRate = vidrate;
    open(anim);
end


for ii = 1:ff
    
    I = I_arr{ii};
    imshow(I); hold on;
    title(ii);
    
    tempx = X{ii};
    tempy = Y{ii};
    tempt = logical(TGL{ii});
    
    scatter(tempx(tempt),tempy(tempt),10,c_lab_b,'filled');
    scatter(tempx(~tempt),tempy(~tempt),10,c_lab_y,'filled');
    plot(ref_pt(1),ref_pt(2),'.w','markersize',10);
    
    text(10,600,'manual extraction');
    text(10,80,{['\theta_{roll} = ' num2str(r_arr(ii))];...
                ['\theta_{pitch} = ' num2str(p_arr(ii))];...
                ['\theta_{bend} = ' num2str(b_arr(ii))]});
    
    wd = 550;
    ht = wd*size(I,1)/size(I,2);
    set(gcf,'position',[500,500,wd,ht]);
    set(gca','position',[0,0,1,1]);
    
    if vidflag
        frame = getframe(gcf);
        writeVideo(anim,frame);
        clf;
    else
        pause;
        clf;
    end
    
end

if vidflag
    close(anim);
    close;
end