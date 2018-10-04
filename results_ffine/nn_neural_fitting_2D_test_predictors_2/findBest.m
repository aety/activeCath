nn_arr = 1:24; % subscripts of files to load 
n_best = 4; % number of best predictors to find
n_pred = 12; % number of predictors in total

best_I_arr = nan(length(nn_arr),n_best);
c_arr = colormap(plasma(length(nn_arr)));

for nn = nn_arr
    
    load(['nn_neural_fitting_2D_test_predictors_' num2str(nn)]);
    
    hold on;
    
    % ---------- label the predictors with highest correlations ----------
    
    if n_best < size(R_arr,1)
        
        % find N sets of best predictors
        [B,I] = sort(sum(R_arr'.^2),'descend');
        best_I_arr(nn,:) = I(1:n_best); % save best predictor indices
        
    end
    % ----------------------------------------------------------------
    
    a = scatter(R_arr(:,1),R_arr(:,2),80,c_arr(nn,:),'filled');
    alpha(a,0.2);
    
end

box off;
axis equal
axis([0,1,0,1]);

xlabel('R (\theta_{rot})');
ylabel('R (\theta_{bend})');
title(['n\circ of predictors per sample = ' num2str(nn)],'fontweight','normal');

set(gca,'fontsize',10);
%     set(gca,'position',[0.11,0.15,0.78,0.78]);
set(gcf,'position',[100,200,600,400]);
set(gcf,'paperposition',[0,0,4,4]);
set(gcf,'color','w');
print('-dtiff','-r300','findBest');
close;

save('findBest','best_I_arr','txt_arr','ind_arr','n_best');

%%
load findBest

temp = unique(best_I_arr); % find unique predictor sets
temp = ind_arr(temp,:); % find their respective indices
test = unique(temp);
for tt = 1:length(test) % sort indices by counts
    test(tt,2) = sum(sum(temp==test(tt))); % sort indices by counts
end % sort indices by counts
temp = sortrows(test,2,'descend'); % sort indices by counts
best_indices= temp(:,1); % sort indices by counts
counts = temp(:,2);

for tt = 1:length(txt_arr)
    txt_arr{tt} = regexprep(txt_arr{tt}, ' ', '_{');
    txt_arr{tt} = [txt_arr{tt} '}'];
end

disp([txt_arr{best_indices}])