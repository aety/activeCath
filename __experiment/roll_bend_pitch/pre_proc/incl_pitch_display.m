clear; clc; ca;

bd_arr = [1.6564, 20.2525, 35.3308, 52.8649, 65.4128, 64.4128];
fn_arr = {37:51,52:66,68:82,84:98,100:114,115:134}; % 15 frames for each bending angle. The last 20 frames are with a phantom;
alim = [201,850,251,800];
ii = 1;

vidflag = 1; % save video
vidrate = 3; % video frame rate

%%
if vidflag
    opengl('software');
    anim = VideoWriter('incl_pitch_display','Motion JPEG AVI');
    anim.FrameRate = vidrate;
    open(anim);
end

cd C:\Users\yang\ownCloud\rennes_experiment\18_12_11-09_47_11-STD_18_12_11-09_47_11-STD-160410\__20181211_095212_765000

for bb = 1:length(bd_arr)
    
    fn = fn_arr{bb};
    bd = bb;
    
    for ff = 1:length(fn)
        %% load image and data
        dname = ['DSA_2_0' num2str(fn(ff),'%03.f')];        
        cd(dname);        
        fname = dir('*.ima');
        filename = fname.name;
        
        info = dicominfo(filename);
        [X0,cmap,alpha,overlays] = dicomread(filename);        
        roll = info.PositionerPrimaryAngle;
        pitch = info.PositionerSecondaryAngle;        
        cd ..
        
        %% sizing, contrast stretch, and sharpening
        X3 = permute(X0,[1,2,4,3]);
        X3 = X3(alim(1):alim(2),alim(3):alim(4),ii);
        I_str = imadjust(X3);
        I_shp = imsharpen(I_str);
                
        %% display
        imshow(I_shp);
        set(gca,'position',[0,0,1,1]);
        text(0,100,{['\theta_{bend} = ' num2str(bd_arr(bd))];['\theta_{roll} = ' num2str(roll)];['\theta_{pitch} = ' num2str(pitch)]});
        if vidflag
            frame = getframe(gcf);
            writeVideo(anim,frame);
            clf;
        end
                
    end
end
%%

if vidflag
    close(anim);
    close;
end
cd C:\Users\yang\ownCloud\MATLAB\rennes