n_pdt_arr = 1:9;
n_pdt = length(n_pdt_arr);

hold on;

merr = nan(1,n_pdt);
sterr = merr; minerr = merr;

for nn = 1:n_pdt

    cd([num2str(n_pdt_arr(nn)) '_pdt']);
    load nn_findApex_3DoF_varHelixN
        
    err = mean(E_ARR,2);
    merr(nn) = mean(err);
    sterr(nn) = std(err);
    minerr(nn) = min(err);
        
    h = scatter(nn*ones(1,size(E_ARR,1)),err,20,0.5*[1,1,1],'filled');    
    alpha(h,0.5);
    
    cd ..
end

h1 = plot(n_pdt_arr,merr);
h2 = plot(n_pdt_arr,minerr);

legend([h1,h2],'avg.','min.');
xlabel('no. of predictors');
ylabel('mean error (deg)');
    
    
set(gca,'fontsize',10);
set(gcf,'paperposition',[0,0,5,2.5]);
print('-dtiff','-r300','plot_Npdt');
close;