clear; clc; ca;
%%
fsz = 7; % major fontsize

nn_arr = 1:3; % 12; % subscripts of files to load
n_lab = 1; % number of predictor sets to label by text

vidflag = 0;
savflag = 1;

if vidflag
    opengl('software');
    anim = VideoWriter(datestr(datetime('now'),'yyyy-mm-dd-HHMMss'),'Motion JPEG AVI');
    anim.FrameRate = 1;
    open(anim);
end

for nn = nn_arr
    
    load(['nn_fitting_test_predictors_' num2str(nn)]);
    
    figure;
    c_arr = colormap(lines(2));
    hold on;
    
    % ---------- label the predictors with highest correlations ----------
    
    if n_lab < size(R_arr,1)
        
        % find N sets of best predictors
        [B,I] = sort(sum(R_arr'.^2),'descend');
        
        text(0,90,'Best predictors:','fontsize',fsz-2);
        for mm = 1:n_lab
            n = I(mm);
            txt_temp = strcat(pdt_txt_arr{ind_arr(n,:)});
            text(5,85,txt_temp,'fontsize',fsz-2);
        end
        
    end
    % ----------------------------------------------------------------
    n = I(1);
    net = N_arr{n};
    response_nn = net(predictor_org(ind_arr(I(1),:),:));
    
    % regression
    [r,m,b] = regression(response_org,response_nn);
    
    % performance
    pfm = perform(net,response_org,response_nn);
    text(0,80,'Performance:','fontsize',fsz-2);
    text(5,75,num2str(pfm,3),'fontsize',fsz-2);
    
    for pp = 1:2
        a = scatter(response_org(pp,:),response_nn(pp,:),20,c_arr(pp,:),'*');
        text(95,90-10*pp,['R = ' num2str(r(pp),3)],'color',c_arr(pp,:),'fontsize',fsz);
    end
    
    box off;
    
    axis equal
    axis([-5,95,-5,95]);
    
    legend('\theta_{rot}','\theta_{bend}','location','southeast');
    xlabel('actual (\circ)');
    ylabel('predicted (\circ)');
    title(['n\circ of predictors per sample = ' num2str(size(ind_arr,2))],'fontweight','normal');
    
    set(gca,'fontsize',fsz);
    set(gcf,'position',[100,150,600,400]);
    set(gcf,'color','w');
    
    if vidflag
        frame = getframe(figure(1));
        writeVideo(anim,frame);
        clf;
    else
        if savflag
            set(gcf,'paperposition',[0,0,3,2.5],'unit','inches');
            print('-dtiff','-r300',['nn_fitting_test_predictors_best_xy_' num2str(nn)]);
            close;
        end
    end
end

if vidflag
    close(anim);
    close;
end