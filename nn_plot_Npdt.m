clear; ca; clc;

% cd C:\Users\yang\ownCloud\MATLAB\__simulation\varHelixN\3_vars\pitch_0_50\varHelixN_16
% fname = 'nn_findApex_3DoF_varHelixN';

cd C:\Users\yang\ownCloud\MATLAB\__expTrainedExpData
fname = 'nn_expTrainedExpData';

n_pdt_arr = 1:9;
n_pdt = length(n_pdt_arr);

%% error
merr = nan(1,n_pdt);
sterr = merr; minerr = merr;

hold on;
for nn = 1:n_pdt

    cd([num2str(n_pdt_arr(nn)) '_pdt']);
    load(fname);
        
    err = mean(E_ARR,2);
    merr(nn) = mean(err);
    sterr(nn) = std(err);
    minerr(nn) = min(err);
        
    h = scatter(nn*ones(1,size(E_ARR,1)),err,20,0.5*[1,1,1],'filled');    
    alpha(h,0.5);
    
    cd ..   
end

h1 = plot(n_pdt_arr,merr,'k');
h2 = plot(n_pdt_arr,minerr,'--','color','k');

legend([h1,h2],'avg.','min.');
xlabel('no. of predictors');
ylabel('(deg)');
title('mean error','fontweight','normal');
    
    
set(gca,'fontsize',10);
set(gcf,'paperposition',[0,0,5,2.5]);
print('-dtiff','-r300','nn_plot_Npdt');
close;

%% R (adjusted) = 1 - (1 - R^2) * ( (n - 1) / (n - p - 1) ) % n: sample size / p: variables
r2_adj = nan(2,n_pdt);

for nn = 1:n_pdt

    cd([num2str(n_pdt_arr(nn)) '_pdt']);
    load(fname);
    
    a = RSP(1:2,TR.testInd);
    b = Y(1:2,TR.testInd);
    
    [r,~,~] = regression(a,b);
    
    n = length(TR.testInd);
    p = nn;
    r2_adj(:,nn) = 1 - (1 - r.^2) * ( (n - 1) / (n - p - 1) );
    
    cd ..
end

mkr = ['o','v'];
hold on;
for pp = 1:2
    plot(1:n_pdt,r2_adj(pp,:),[mkr(pp) '-k'],'markersize',6);
end
legend(RSP_txt{1:2});

xlabel('no. of predictors');
title('adjusted R^2','fontweight','normal');
    
box off    
set(gca,'fontsize',10);
set(gcf,'paperposition',[0,0,5,2.5]);
print('-dtiff','-r300','nn_plot_Npdt_adjR2');
close;