load C:\Users\Yang\Documents\catheter\MATLAB\results_ffine\nn_neural_fitting_2D_pre response
fname = '0';
load(['nn_neural_fitting_2D_test_predictors_' fname]);

for tt = 1:length(txt_arr)
            txt_arr{tt} = regexprep(txt_arr{tt}, ' ', '_{');
            txt_arr{tt} = [txt_arr{tt} '}'];
end
%% find the index with best R's
% 1) judge by error
% % % for nn = 1:length(e_arr)
% % %     enorm(nn) = norm(e_arr{nn});
% % % end
% % % ii = find(enorm==min(enorm));

% 2) judge by performance
ii = find(P_arr==min(P_arr));

% % % 3) judge by R values
% % % temp = sum(R_arr'.^2);
% % % ii = find(temp==max(temp));

%% run neural net to predict
predictor = predictor_original(:,ind_arr(ii,:));
net = N_arr{ii};
nn_response = net(predictor');
[r,m,b] = regression(response',nn_response);

%% plot
c_arr = colormap(lines(2));
temp = max(max(response));
hold on;
for pp = 1:2
    plot(response(:,pp),nn_response(pp,:)','*','color',c_arr(pp,:),'markersize',2);
    text(temp,temp-10*pp,['R = ' num2str(r(pp),3)],'color',c_arr(pp,:));
end
legend('\theta_{rot}','\theta_{bend}','location','southeast');
xlabel('simulated (\circ)');
ylabel('neural net (\circ)');
title(strcat(txt_arr{ind_arr(ii,:)}));

axis equal;
box off;

set(gca,'fontsize',10);
set(gcf,'paperposition',[0,0,4,3],'unit','inches');

print('-dtiff','-r300',['nn_plot_correlatcion_' fname '_' num2str(ii)]);
close;