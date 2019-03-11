
%% plot by frame
% % for dd = 1%1:size(PKS1,4)
% %
% %     hold on;
% %
% %     for xx = 1:size(PKS1,1)
% %
% %         pk1 = permute(PKS1(xx,:,:,dd),[3,2,1]);
% %         pk2 = permute(PKS2(xx,:,:,dd),[3,2,1]);
% %
% %         scatter(pk1(:,1),pk1(:,2),10,1:size(PKS1,3),'filled');
% %         scatter(pk2(:,1),pk2(:,2),10,1:size(PKS1,3),'filled');
% %     end
% %     axis equal
% %     axis tight
% % end

%% plot by node
% for dd = 1%:size(PKS1,4)
%
%     hold on;
%
%     for ii = 1:size(PKS1,3)
%
%         pk1 = PKS1(:,:,ii,dd);
%         pk2 = PKS2(:,:,ii,dd);
%
%         scatter(pk1(:,1),pk1(:,2),10,1:size(PKS1,1),'filled');
%         scatter(pk2(:,1),pk2(:,2),10,1:size(PKS1,1),'filled');
%     end
% end
% % %     axis equal
% %     axis tight


%% plot by node with mean and std
% % % cmap = colormap(lines(size(PKS1,1)));
% % %
% % % for dd = 1:size(PKS1,4)
% % %
% % %     for xx = 1:size(PKS1,1)
% % %
% % %         pk1 = permute(PKS1(xx,:,:,dd),[3,2,1]);
% % %         pk2 = permute(PKS2(xx,:,:,dd),[3,2,1]);
% % %
% % %         %         scatter(pk1(:,1),pk1(:,2),10,xx*ones(1,size(PKS1,3)),'filled');
% % %         %         scatter(pk2(:,1),pk2(:,2),10,xx*ones(1,size(PKS1,3)),'filled');
% % %
% % %         hold on;
% % %         plot(pk1(:,1),pk1(:,2),'.','color',cmap(xx,:),'markersize',10); % plot peaks
% % %   
% % %         %         pkm = nanmean(pk1); pkstd = nanstd(pk1);
% % %         %         plot(pkm(1),pkm(2),'*','color',cmap(xx,:)); % plot mean
% % %         %         plot(pkm(1)*ones(1,3),pkm(2)+[-pkstd(2),0,pkstd(2)],'*-','color',cmap(xx,:)); % plot mean and std
% % %
% % %         %         tgl = abs(pk1(:,2)-pkm(2)) < pkstd(2); % remove outliers
% % %         %         plot(pk1(tgl,1),pk1(tgl,2),'o','color',cmap(xx,:)); % plot peaks without outliers
% % %         %         title(xx); pause; clf;
% % %
% % %     end
% % %     %     axis equal
% % %     %     axis tight
% % %
% % %     ylim([0,450]);
% % %     set(gca,'fontsize',8);
% % %     set(gcf,'paperposition',[0,0,3,3],'unit','inches');
% % %     print('-dtiff','-r300',['test_interp_byNode_' num2str(dd)]);
% % %     close;
% % % end

%% clustering
clear; clc; ca;
load pre_nn_20SDF_H_30_short

n_pt = size(PKS1,1);
n_fr = size(PKS1,3);
n_bd = size(PKS1,4);

P_arr = {PKS1,PKS2};
n_cl_arr = [16,15];

M_node = nan(n_pt*n_fr,n_bd);
M_fr = M_node;
M_pk = nan(n_pt*n_fr,2,2,n_bd);
M_idx = nan(n_pt*n_fr,2,n_bd);

for dd = 1:n_bd % only good between 1 and 3
    
    lab_node = repmat(1:n_pt,n_fr,1)';
    lab_fr = repmat(1:n_fr,n_pt,1);
    
    for pp = 1:2
        pk = permute(P_arr{pp}(:,:,:,dd),[1,3,2]);
        n_cl = n_cl_arr(pp);
        
        B_node = reshape(lab_node,n_pt*n_fr,1); % reshape
        B_fr = reshape(lab_fr,n_pt*n_fr,1);     % reshape
        
        B_pk = reshape(pk,n_pt*n_fr,2);         % reshape
        
        temp = [nanmin(B_pk(:,2)),nanmax(B_pk(:,2))];   % save original scale
        B_pk(:,2) = rescale(B_pk(:,2),0,1000000);    % scale to y-dimension to help clustering
        [idx,C,sumd,D] = kmeans(B_pk,n_cl,'replicate',10,'Display','final','start','plus','EmptyAction','error','Distance','sqeuclidean'); % cluster
        B_pk(:,2) = rescale(B_pk(:,2),temp(1),temp(2));   % scale back to original y-dimension
        
        M_pk(:,:,pp,dd) = B_pk;
        M_idx(:,pp,dd) = idx;
        
    end
    
    M_node(:,dd) = B_node;
    M_fr(:,dd) = B_fr;
    
end

save test_interp_btw_fr M_* n_*

%% plot clustering
plt = 1;
if plt
    for dd = 1:n_bd
        for pp = 1:2
            
            B_pk = M_pk(:,:,pp,dd);
            idx = M_idx(:,pp,dd);
            n_cl = n_cl_arr(pp);
            
            figure;
            cmap = colormap(lines(n_cl));
            hold on;
            
            for cc = 1:n_cl
                tgl = idx==cc;
                %                                 c = 'r';     % diagnositc
                c = cmap(cc,:);
                h = scatter(B_pk(tgl,1),B_pk(tgl,2),10,c,'filled');
                title(cc);
                %                                 pause; h.CData = [0,0,0]; % diagnositc
            end
        end
    end
end

%% smoothing 
clear; clc; ca;
load test_interp_btw_fr
n_order = 2; % order of polyfit

% -----------------------------------------------------------
% manually correct false cluster
test = M_pk(:,1,1,5)> - 61 & M_pk(:,2,1,5)>288;
M_idx(test,1,5) = 4;
% -----------------------------------------------------------
tt_txt = {'concave','concave'};

for dd = 1:n_bd
    figure;
    for pp = 1:2
        
        hold on;
        
        n_cl = n_cl_arr(pp);
        
        B_pk = M_pk(:,:,pp,dd);
        idx = M_idx(:,pp,dd);
        
        B_node = M_node(:,dd);
        B_fr = M_fr(:,dd);
        
        cmap = colormap(lines(n_cl));
        
        for cc = 1:n_cl
            tgl = idx==cc;
            
            p1 = polyfit(B_pk(tgl,1),B_pk(tgl,2),n_order);
            x = B_pk(tgl,1);
            y = polyval(p1,x);
            
            c = cmap(cc,:);
            h = scatter(B_pk(tgl,1),B_pk(tgl,2),2,c,'filled');
            alpha(h,0.1);
            plot(x,y,'color',c);
            % text(-10+x(end),y(end),num2str(cc));
        end
        % title(tt_txt{pp},'fontweight','normal');
        
    end
    set(gca,'position',[0,0,1,1]);
    set(gca,'fontsize',6);    
    axis tight;
    axis equal;    
    ylim([0,450]);
    axis off
    
    temp = [get(gca,'xlim');get(gca,'ylim')];
    temp = range(temp');
    ht = 3;
    set(gcf,'paperposition',[0,0,ht*temp(1)/temp(2),ht],'unit','inches');
    print('-dtiff','-r300',['test_interp_byNode_smooth_' num2str(dd)]);
    close;    
end


%% alternative clustering
%     GMModel = fitgmdist(B_pk1,16,'Options',statset('MaxIter',500),'CovarianceType','diagonal','SharedCovariance',true,'RegularizationValue',0.01);
%     idx = cluster(GMModel,B_pk1);

%     [~, idx, ~] = dbscan(B_pk1', 1, 1);

%     [centers,U] = fcm(B_pk1,16);
%     maxU = max(U);
%     tgl = U(cc,:) == maxU;