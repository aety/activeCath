%% clustering
% % clear; clc; ca;
% % load pre_nn_20SDF_H_30_short
% %
% % n_pt = size(PKS1,1);
% % n_fr = size(PKS1,3);
% % n_bd = size(PKS1,4);
% %
% % P_arr = {PKS1,PKS2};
% % n_cl_arr = [16,15];
% %
% % M_node = nan(n_pt*n_fr,n_bd);
% % M_fr = M_node;
% % M_pk = nan(n_pt*n_fr,2,2,n_bd);
% % M_idx = nan(n_pt*n_fr,2,n_bd);
% %
% % for dd = 1:n_bd % only good between 1 and 3
% %
% %     lab_node = repmat(1:n_pt,n_fr,1)';
% %     lab_fr = repmat(1:n_fr,n_pt,1);
% %
% %     for pp = 1:2
% %         pk = permute(P_arr{pp}(:,:,:,dd),[1,3,2]);
% %         n_cl = n_cl_arr(pp);
% %
% %         B_node = reshape(lab_node,n_pt*n_fr,1); % reshape
% %         B_fr = reshape(lab_fr,n_pt*n_fr,1);     % reshape
% %
% %         B_pk = reshape(pk,n_pt*n_fr,2);         % reshape
% %
% %         temp = [nanmin(B_pk(:,2)),nanmax(B_pk(:,2))];   % save original scale
% %         B_pk(:,2) = rescale(B_pk(:,2),0,1000000);    % scale to y-dimension to help clustering
% %         [idx,C,sumd,D] = kmeans(B_pk,n_cl,'replicate',10,'Display','final','start','plus','EmptyAction','error','Distance','sqeuclidean'); % cluster
% %         B_pk(:,2) = rescale(B_pk(:,2),temp(1),temp(2));   % scale back to original y-dimension
% %
% %         M_pk(:,:,pp,dd) = B_pk;
% %         M_idx(:,pp,dd) = idx;
% %
% %     end
% %
% %     M_node(:,dd) = B_node;
% %     M_fr(:,dd) = B_fr;
% %
% % end
% %
% % save test_interp_btw_fr M_* n_*

%% diagnose clustering
% % % plt = 1;
% % % if plt
% % %     for dd = 1:n_bd
% % %         for pp = 1:2
% % %
% % %             B_pk = M_pk(:,:,pp,dd);
% % %             idx = M_idx(:,pp,dd);
% % %             n_cl = n_cl_arr(pp);
% % %
% % %             figure;
% % %             cmap = colormap(lines(n_cl));
% % %             hold on;
% % %
% % %             for cc = 1:n_cl
% % %                 tgl = idx==cc;
% % %                 c = 'r';     % diagnositc
% % %                 % c = cmap(cc,:);
% % %                 h = scatter(B_pk(tgl,1),B_pk(tgl,2),10,c,'filled');
% % %                 title(cc);
% % %                 pause; h.CData = [0,0,0]; % diagnositc
% % %             end
% % %         end
% % %     end
% % % end

%% manually correct false cluster
% % % clear; clc; ca;
% % % load test_interp_btw_fr
% % %
% % % test = M_pk(:,1,1,5)> - 61 & M_pk(:,2,1,5)>288;
% % % M_idx(test,1,5) = 4;
% % %
% % % save test_interp_btw_fr_correct M_* n_*

%% rearrange clusters by average y
load test_interp_btw_fr_correct
M_idx_sort = nan(size(M_idx));

for dd = 1:n_bd
    for pp = 1:2
        
        B_pk = M_pk(:,:,pp,dd);
        idx = M_idx(:,pp,dd);
        n_cl = n_cl_arr(pp);
        
        y_avg = nan(1,n_cl);
        for cc = 1:n_cl
            tgl = idx==cc;
            y_avg(cc) = nanmean(B_pk(tgl,2));
        end
        
        [~,y_sorted] = sort(y_avg);
        
        for cc = 1:n_cl
            tgl = idx==y_sorted(cc);
            idx(tgl) = cc + 100;
        end
        idx = idx - 100;
        
        M_idx_sort(:,pp,dd) = idx;
    end
end

M_idx = M_idx_sort;

save test_interp_btw_fr_sort M_* n_*

%% curve fitting
clear; clc; ca;
load test_interp_btw_fr_sort
n_order = 2; % order of polyfit

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
        
        cmap = colormap(parula(n_cl));
        
        for cc = 1:n_cl
            tgl = idx==cc;
            
            p1 = polyfit(B_pk(tgl,1),B_pk(tgl,2),n_order);
            x = B_pk(tgl,1);
            y = polyval(p1,x);
                        
            c = cmap(cc,:);
            h = scatter(B_pk(tgl,1),B_pk(tgl,2),2,c,'filled');
            alpha(h,0.2);            
            plot(x,y,'color','k','linewidth',0.1);
            %             text(-10+x(end),y(end),num2str(cc));
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
    print('-dtiff','-r300',['test_interp_byNode_fit_' num2str(dd)]);
    close;
end

%% interpolate
