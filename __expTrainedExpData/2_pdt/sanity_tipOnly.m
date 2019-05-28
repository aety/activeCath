cd C:\Users\yang\ownCloud\MATLAB\__expTrainedExpData\2_pdt

clearvars
ca;
clc;

%% load NN results
fname = 'expTrainedExpData';
load(['nn_' fname],'Y');
rsp_nn = Y(1:2,:); % NN response

%% compile TIPx and TIPy for NN
load(['..\pre_nn_' fname],'TIP*','RSP*');
PDT = [TIPx;TIPy];
RSP = RSP(1:2,:); RSP_txt = RSP_txt(1:2);
PDT_txt = {'x_{tip}','y_{tip}'};

fname = [fname '_tipOnly'];
save(['..\pre_nn_' fname],'PDT*','RSP*');
rsp_o = RSP; % save original response

%% train NN with TIPx and TIPy
n_pdt = 2;
nn_training;

%% evaluate new NN reuslts
ind_n = find(p_arr==min(p_arr));
rsp_xy = y_arr{ind_n};
ind_te = TR.testInd;

%% plot results
b_arr = {rsp_nn,rsp_xy};
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
        h(bb) = scatter(a,b,20,c_arr(bb,:),'filled');
        alpha(h(bb),0.5);
        R(bb) = regression(a,b);
    end
    legend(h,['markers, R = ' num2str(R(1),3)],['tip-only, R = ' num2str(R(2),3)],'location','northoutside');
    xlabel(['actual ' RSP_txt{ii}]);
    ylabel(['predicted ' RSP_txt{ii}]);
    axis equal;
    axis tight;
    
    set(gca,'fontsize',12);
    set(gcf,'paperposition',[0,0,4,3.5],'unit','inches');
    print('-dtiff','-r300',['sanity_tipOnly_' num2str(ii)]);
    close;
    
end