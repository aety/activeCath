clear; clc; ca;
%%
nn_arr = 1:12; % subscripts of files to load
n_lab = 1; % number of predictors to label by text

load C:\Users\Yang\Documents\catheter\MATLAB\results_ffine\nn_neural_fitting_2D_pre response
vidflag = 1;

if vidflag
    opengl('software');
    anim = VideoWriter(datestr(datetime('now'),'yyyy-mm-dd-HHMMss'),'Motion JPEG AVI');
    anim.FrameRate = 1;
    open(anim);
end

c_arr = colormap(lines(2));

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
        
        text(0,90,'Best predictors:','fontsize',10);
        for mm = 1:n_lab
            n = I(mm);
            txt_temp = strcat(txt_arr{ind_arr(n,:)});
            text(5,85,txt_temp,'fontsize',10);
        end
        
    end
    % ----------------------------------------------------------------
    n = I(1);
    net = N_arr{n};
    response_nn = net(predictor_original(:,ind_arr(I(1),:))');
    response_nn = response_nn';
    
    % regression
    [r,m,b] = regression(response',response_nn');
    
    % performance
    pfm = perform(net,response,response_nn);
    text(0,80,'Performance:');
    text(5,75,num2str(pfm,3));
    
    for pp = 1:2
        a = scatter(response(:,pp),response_nn(:,pp),20,c_arr(pp,:),'*');
        text(90,90-10*pp,['R = ' num2str(r(pp),3)],'color',c_arr(pp,:));
        %         alpha(a,0.5);
    end
    
    box off;
   
    axis equal
    axis([-5,95,-5,95]);
    
    legend('\theta_{rot}','\theta_{bend}','location','southeast');
    xlabel('actual (\circ)');
    ylabel('neural net predicted (\circ)');
    title(['n\circ of predictors per sample = ' num2str(size(ind_arr,2))],'fontweight','normal');
    
    set(gca,'fontsize',14);
    set(gcf,'position',[100,150,600,400]);
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