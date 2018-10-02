clear; clc; ca;

nn_arr = 1:12;

R_score_1 = zeros(12,length(nn_arr));
R_score_2 = R_score_1;
n_psblt = nan(1,length(nn_arr));

for nn = 1:length(nn_arr)
    
    load(['nn_neural_fitting_2D_test_predictors_' num2str(nn)]);
    
    for rr = 1:size(R_arr,1)
        
        ind = ind_arr(rr,:);
        R_score_1(ind,nn) = R_score_1(ind,nn) + R_arr(rr,1); % rotation
        R_score_2(ind,nn) = R_score_2(ind,nn) + R_arr(rr,2); % bending
        
    end
    
    n_psblt(nn) = size(R_arr,1);
end

save nn_neural_fitting_2D_test_predictors_findBest_all

%%

load nn_neural_fitting_2D_test_predictors_findBest_all

% reformat text array for labeling
for tt = 1:length(txt_arr)
    txt_arr{tt} = regexprep(txt_arr{tt}, ' ', '_{');
    txt_arr{tt} = [txt_arr{tt} '}'];
end

c_arr = colormap(plasma(length(nn_arr)));
rsp_arr = {'\theta_{rot}','\theta_{bend}'};
plot_arr = {R_score_1,R_score_2};

for ii = 1:2
    
    figure(ii);
    
    for nn = 1:length(nn_arr)
        
        plt = plot_arr{ii}(:,nn); % load data
        plt = plt/n_psblt(nn); % normalize values by number of predictor set
        %     plt = plt - min(plt); % normalize values to [0,1]
        %     plt = plt/max(plt); % normalize values to [0,1]
        
        subplot(3,4,nn);
        hold on;
        plot(plt,'-*','color',c_arr(nn,:));
        
        axis tight;
        set(gca,'xtick',1:length(txt_arr),'xticklabel',txt_arr);
        title([num2str(nn_arr(nn)) ' predictors'],'fontweight','normal');
        xlabel('');
        ylabel('\Sigma R (sum of corr. coef.)');
        box off;
        set(gca,'fontsize',5);
    end
    
    text(5,0.5,rsp_arr{ii},'fontsize',10);
    
    set(gcf,'paperposition',[0,0,11,5],'unit','inches');
    print('-dtiff','-r300',['nn_neural_fitting_2D_test_predictors_findBest_all_' num2str(ii)]);
    close;
    
end