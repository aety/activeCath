clear; ca; clc;

load pre_nn_20SDF_H_30_short
n_tr = 5;

pdt_arr = 1:10; % possible predictors
n_pdt_arr = 1:6; % number of predictors to include each time

best_p = nan(1,length(n_pdt_arr));
best_e = best_p;
best_pdt = cell(1,length(n_pdt_arr));
best_tr = best_pdt;
best_y = best_pdt;
all_p = best_pdt;


for zz = 1:length(n_pdt_arr)
    
    %% load predictors
    n_pdt = n_pdt_arr(zz);
    C = nchoosek(pdt_arr,n_pdt);
    
    P_ARR = nan(size(C,1),n_tr);
    E_ARR = P_ARR;
    TR_ARR = cell(length(pdt_arr),1);
    Y_ARR = TR_ARR;
    
    for ii = 1:size(C,1)
        
        disp([num2str(zz) ',' num2str(ii) '/' num2str(size(C,1)) ', [' ,num2str(C(ii,:)) ']']);
        
        pp = C(ii,:); % select predictors
        predictor = PDT(pp,:); [predictor,PS_pdt] = mapminmax(predictor); % normalization
        response = RSP; [response,PS_rsp] = mapminmax(response);         % normalization
        
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
            net.divideParam.trainRatio = 70/100;
            net.divideParam.valRatio = 15/100;
            net.divideParam.testRatio = 15/100;
            
            
            % Train the Network
            [net,tr] = train(net,x,t);
            
            % Test the Network
            y = net(x);
            e = gsubtract(t,y);
            p = perform(net,t,y);
            
            y = mapminmax('reverse',y,PS_rsp); % reverse normalization
            
            p_arr(nn) = p;
            e_arr(nn) = norm(e);
            tr_arr{nn} = tr;
            y_arr{nn} = y;
            
            clear net
            
        end
        
        P_ARR(ii,:) = p_arr;
        E_ARR(ii,:) = e_arr;
        TR_ARR{ii} = tr_arr;
        Y_ARR{ii} = y_arr;
        
    end
    
    [ind_a,ind_b] = find(P_ARR==min(min(P_ARR)));
    best_p(zz) = P_ARR(ind_a,ind_b);
    best_e(zz) = E_ARR(ind_a,ind_b);
    best_tr{zz} = TR_ARR{ind_a}{ind_b};
    best_y{zz} = Y_ARR{ind_a}{ind_b};
    
    best_pdt{zz} = C(ind_a,:);
    all_p{zz} = P_ARR;
    
end

save nn_20SDF_H_30_short_test_Npdt best_* ind_* all_p RSP n_pdt_arr *_txt

%%
clear;clc;ca;
load nn_20SDF_H_30_short_test_Npdt
plt = best_p/max(best_p);
disp(diff(plt)*100);
plot(plt,'o-k','markerfacecolor','k');
xlabel('number of predictors');
ylabel('normalized error');
box off;
set(gca,'fontsize',10);
set(gcf,'paperposition',[0,0,4,2],'unit','inches');
print('-dtiff','-r300','test_Npdt_p');
close;

%%
load nn_20SDF_H_30_short_test_Npdt
n = length(n_pdt_arr);
figure(1);
cmap = colormap(lines(n));
hold on;
plot([0,75],[0,75],'k');

figure(2);
hold on;
plot([0,75],[0,75],'k');

for zz = 1:n
    
    ind = best_tr{zz}.testInd;
    
    for ff = 1:2
        x = RSP(ff,ind);
        y = best_y{zz}(ff,ind);
        
        figure(ff);
        h(ff) = scatter(x,y,10,cmap(zz,:),'filled');
                alpha(h(ff),0.5);
        r = regression(x,y);
        text(5,80-5*zz,['n = ' num2str(zz) ', R = ' num2str(r,3)],'color',cmap(zz,:),'fontsize',6);
    end
end

for ff = 1:2
    figure(ff);
    set(gca,'fontsize',10);
    xlabel('actual');
    ylabel('predicted');
    title(RSP_txt{ff},'fontweight','normal');
    axis equal
    axis tight
    temp = [get(gca,'xlim');get(gca,'ylim')];
    temp = [min(temp(:,1)),max(temp(:,2))];
    axis([temp,temp]);
    set(gcf,'paperposition',[0,0,3,3],'unit','inches');
    print('-dtiff','-r300',['test_Npdt_' num2str(ff)]);
    close;
end