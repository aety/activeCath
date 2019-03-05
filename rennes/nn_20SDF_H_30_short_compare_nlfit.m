
%% nn results
load nn_20SDF_H_30_short;
[ind_a,ind_b] = find(P_ARR==min(min(P_ARR)));

tr = TR_ARR{ind_a}{ind_b};  % struct from nn results
y = Y_ARR{ind_a}{ind_b};    % output response from NN

ind_te = tr.testInd;        % testing indices
ind_tr = tr.trainInd;       % training indices

pdt = PDT([1,ind_a],:);     % best predictors
rsp_o = t;                  % original response
rsp_nn = y;                 % NN response

%% non-linear fit
rsp_nl = nan(2,length(pdt));
for ii = 1:2    
    [fitresult, ~] = createFit(pdt(1,ind_tr), pdt(2,ind_tr), rsp_o(ii,ind_tr));
    rsp_nl(ii,:) = fitresult(pdt(1,:),pdt(2,:));    
end

% plot results
b_arr = {rsp_nn,rsp_nl};
c_arr = colormap(lines(2));

for ii = 1:2
    
    R = nan(1,2);
    figure(ii);
    hold on;
    temp = [0,max(rsp_o(ii,:))];
    plot(temp,temp,'color',0.5*[1,1,1]);
    
    for bb = 1:length(b_arr)
        a = rsp_o(ii,ind_te);
        b = b_arr{bb}(ii,ind_te);
        h(bb) = scatter(a,b,10,c_arr(bb,:),'filled');
        alpha(h(bb),0.5);
        R(bb) = regression(a,b);
    end
    legend(h,['NN, R = ' num2str(R(1),3)],['NL reg., R = ' num2str(R(2),3)],'location','northoutside');
    xlabel(['actual ' RSP_txt{ii}]);
    ylabel(['predicted ' RSP_txt{ii}]);
    axis equal;
    axis tight;    
    
    set(gca,'fontsize',8);
    set(gcf,'paperposition',[0,0,3,3.5],'unit','inches');
    print('-dtiff','-r300',['compare_nlfit_' num2str(ii)]);
    close;
    
end