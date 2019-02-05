clear; ca; clc;

load pre_nn_20SDF_H_30_short
cmap = {flipud(parula),RdYlGn};
n_tr = 10;

%% load predictors
pdt_arr = 2:7;

P_ARR = nan(length(pdt_arr),n_tr);
E_ARR = P_ARR;
TR_ARR = cell(length(pdt_arr),1);
Y_ARR = TR_ARR;

for ii = 1:length(pdt_arr)
    
    pp = [1,pdt_arr(ii)];
    predictor = PDT(pp,:);
    response = RSP;
    
    %% Solve an Input-Output Fitting problem with a Neural Network
    % Script generated by Neural Fitting app
    % Created 28-Sep-2018 17:13:57
    
    x = predictor;
    t = response;
    
    % Choose a Training Function
    % For a list of all training functions type: help nntrain
    % 'trainlm' is usually fastest.
    % 'trainbr' takes longer but may be better for challenging problems. %%%%%% SUPPORTS REGULARIZATION %%%%%%
    % 'trainscg' uses less memory. Suitable in low memory situations.
    trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.    
    
    %% repeatedly train the network and find the best
    p_arr = nan(1,n_tr);
    e_arr = p_arr;
    tr_arr = cell(1,n_tr);
    y_arr = tr_arr;
    
    for nn = 1:n_tr
        
        % Create a Fitting Network
        hiddenLayerSize = 10;
        net = fitnet(hiddenLayerSize,trainFcn);
        
        % Setup Division of Data for Training, Validation, Testing
        net.divideParam.trainRatio = 50/100;
        net.divideParam.valRatio = 20/100;
        net.divideParam.testRatio = 30/100;
        
        
        % Train the Network
        [net,tr] = train(net,x,t);
        
        % Test the Network
        y = net(x);
        e = gsubtract(t,y);
        p = perform(net,t,y);
        %     [r,~,~] = regression(t,y);
        
        p_arr(nn) = p;
        e_arr(nn) = norm(e);
        tr_arr{nn} = tr;
        y_arr{nn} = y;
    end
    
    P_ARR(ii,:) = p_arr;
    E_ARR(ii,:) = e_arr;
    TR_ARR{ii} = tr_arr;
    Y_ARR{ii} = y_arr;
    
end

save nn_20SDF_H_30_short

%% plot
load nn_20SDF_H_30_short;
[a,b] = find(P_ARR==min(min(P_ARR)));

tr = TR_ARR{a}{b};
y = Y_ARR{a}{b};

ind = tr.testInd;
c_plt = [2,1];

for rr = 1:size(pp,2)
    figure;
    hold on;    
    
    temp2 = max([max(max(t(rr,:))),max(max(y(rr,:)))]);
    temp1 = min([min(min(t(rr,:))),min(min(t(rr,:)))]);
    axis([temp1,temp2,temp1,temp2]);
    plot([temp1,temp2],[temp1,temp2],'color',0.75*[1,1,1],'linewidth',2);
    
    
    colormap(cmap{rr});
    h = scatter(t(rr,ind),y(rr,ind),10,RSP(c_plt(rr),ind),'filled');
    alpha(h,0.5);
    
    [r,m,b] = regression(t(rr,ind),y(rr,ind));    
    
    title(['Predictors: ' PDT_txt{1} ', ' PDT_txt{pp(size(pp,2))} ', R = ' num2str(r)],'fontweight','normal');
    xlabel(['actual ' RSP_txt{rr}]);
    ylabel(['predicted ' RSP_txt{rr}]);
    
    axis equal
    
    c = colorbar;
    c.Label.String = RSP_txt{c_plt(rr)};
    c.Box = 'off';
    
    set(gca,'fontsize',8);
    set(gcf,'paperposition',[0,0,4,3]);
    print('-dtiff','-r300',['nn_20SDR_H_30_short_' num2str(rr)]);
end