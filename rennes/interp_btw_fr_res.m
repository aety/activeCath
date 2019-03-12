%% interpolate
clear; clc; ca;
load interp_btw_fr_proc

PKS = cell(1,2);
PKS{1} = nan(max(n_cl_arr),2,n_fr,n_bd); % 16 (pks) x 2 (dim) x 188 (frame) x 5 (bend)
PKS{2} = PKS{1};

for dd = 1:n_bd
    
    for pp = 1:2 % concave / convex
        
        figure;
        hold on;
        
        n_cl = n_cl_arr(pp);
        
        B_pk = M_pk(:,:,pp,dd);
        idx = M_idx(:,pp,dd);
        B_node = M_node(:,dd);
        B_fr = M_fr(:,dd);
        
        cmap = colormap(lines(n_cl));
        
        for cc = 1:n_cl
            
            tgl = idx==cc;          % select one cluster
            lab = find(idx==cc);    % label points in selected cluster
            
            old_pks = [B_pk(tgl,1),B_pk(tgl,2)];
            new_pks_arr = cell(1,2);
            
            c = cmap(cc,:);
            %             plot(old_pks(:,1),old_pks(:,2),'*','color',c);
            
            for jj = 1:size(old_pks,2) % x and y
                
                temp_x = B_fr(lab)';     % pre-interp X (frame number)
                temp_y = old_pks(:,jj)';   % pre-interp Y (x-coordinate)
                
                
                lab_itp = find(diff(temp_x)>1); % identify places where peaks are missing
                
                for ii = 1:length(lab_itp) % loop through missed peaks
                    
                    ind = lab_itp(ii) + [0,1];                      % indices to interpolate between
                    itp_x = temp_x(ind(1)): temp_x(ind(2));         % interpolated X
                    itp_y = interp1(temp_x(ind),temp_y(ind),itp_x);	% interpolated Y
                    
                    temp_x = [temp_x(1:lab_itp(ii)),itp_x(2:end-1),temp_x(lab_itp(ii)+1:end)];
                    temp_y = [temp_y(1:lab_itp(ii)),itp_y(2:end-1),temp_y(lab_itp(ii)+1:end)];
                    lab_itp(ii:end) = lab_itp(ii:end) + length(itp_x) - 2;
                    
                end
                new_pks_arr{jj} = temp_y;
            end
            new_pks = cell2mat(new_pks_arr')';
            plot(new_pks(:,1),new_pks(:,2),'.-','color',c);
            text(20+new_pks(1,1),new_pks(1,2),num2str(min(temp_x)),'color',c,'fontsize',8);
            text(-50+new_pks(end,1),new_pks(end,2),num2str(max(temp_x)),'color',c,'fontsize',8);
            
            PKS{pp}(cc,:,temp_x,dd) = new_pks';
        end
        
        axis equal; axis tight;
        ylim([0,450]); axis off;
        set(gca,'fontsize',6);
        temp = [get(gca,'xlim');get(gca,'ylim')];
        temp(1) = temp(1)-100; temp(2) = temp(2) + 30;
        temp = range(temp');
        ht = 3;
        set(gca,'position',[0,0,1,1]);
        set(gcf,'paperposition',[0,0,ht*temp(1)/temp(2),ht],'unit','inches');
        print('-dtiff','-r300',['interp_btw_fr_res_' num2str(dd) '_' num2str(pp)]);
        close;
    end
end

PKS1 = PKS{1};
PKS2 = PKS{2};

save interp_btw_fr_res PKS1 PKS2