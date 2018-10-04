nn_arr = 1:24; % subscripts of files to load 
n_lab = 4; % number of predictors to label by text

vidflag = 1;

if vidflag
    opengl('software');
    anim = VideoWriter(datestr(datetime('now'),'yyyy-mm-dd-HHMMss'),'Motion JPEG AVI');
    anim.FrameRate = 2;
    open(anim);
end

for nn = nn_arr
    
    load(['nn_neural_fitting_2D_test_predictors_' num2str(nn)]);
    
    hold on;
    
    % ---------- label the predictors with highest correlations ----------
    
    if n_lab < size(R_arr,1)
        % reformat text array for labeling
        for tt = 1:length(txt_arr)
            txt_arr{tt} = regexprep(txt_arr{tt}, ' ', '_{');
            txt_arr{tt} = [txt_arr{tt} '}'];
        end
        
        % find N sets of best predictors
        [B,I] = sort(sum(R_arr'.^2),'descend');
        
        text(0,(n_lab+1)*0.1,'Best predictors:','fontsize',10);
        for mm = 1:n_lab
            n = I(mm);
            txt_temp = strcat(txt_arr{ind_arr(n,:)});
            text(0,0+mm*0.1,txt_temp,'fontsize',10);
        end
        
    end
    % ----------------------------------------------------------------
    
    
    a = scatter(R_arr(:,1),R_arr(:,2),80,'k','filled');
    alpha(a,0.3);
    
    box off;
    axis equal
    axis([0,1,0,1]);
    
    xlabel('R (\theta_{rot})');
    ylabel('R (\theta_{bend})');
    title(['n\circ of predictors per sample = ' num2str(nn)],'fontweight','normal');
    
    set(gca,'fontsize',14);
    %     set(gca,'position',[0.11,0.15,0.78,0.78]);
    set(gcf,'position',[100,200,600,400]);
    %     set(gcf,'paperposition',[0,0,4,4]);
    set(gcf,'color','w');
    
    if vidflag
        frame = getframe(figure(1));
        writeVideo(anim,frame);
        clf;
    end
end

if vidflag
    close(anim);
    close;
end