kword_arr = {'20SDR','CLICH','DSA'};
%kword = '20SDR';
% kword = 'CLICH';
% kword = 'DSA';
for kk = 3%1:3
    
    cd C:\Users\yang\ownCloud\rennes_experiment\18_12_11-09_47_11-STD_18_12_11-09_47_11-STD-160410\__20181211_095212_765000
    
    kword = kword_arr{kk};
    
    dirname = dir(['*' kword '*']);
    
    th_1 = nan(1,length(dirname));
    th_2 = th_1;
    d_s_p = th_1; d_s_d = th_1;
    table_pos = nan(3,length(dirname));
    
    for ii = 1:length(dirname)
        
        disp(['Loading ' num2str(ii) ' out of ' num2str(length(dirname))]);
        cd(dirname(ii).name);
        fname = dir('*_*');
        
        info = dicominfo(fname.name);
        th_1(ii) = info.PositionerPrimaryAngle;
        th_2(ii) = info.PositionerSecondaryAngle;
        
        d_s_p(ii) = info.DistanceSourceToPatient;
        d_s_d(ii) = info.DistanceSourceToDetector; % should be constant
        
        table_pos(:,ii) = double(info.Private_0021_1057);
       
        cd ..
    end
    
    %% plot primary and secondary rotation angles
    hold on;
    plot(th_1);
    plot(th_2);
    
    title(kword);
    xlabel('file');
    ylabel('\circ');
    legend('\theta_{primary}','\theta_{secondary}','location','southoutside','orientation','horizontal');
    
    set(gca,'fontsize',8);
    set(gcf,'paperposition',[0,0,3,2],'unit','inches');
    cd ..
%     print('-dtiff','-r300',['sortdata_' kword]);
    close;
    
end

%% plot source-to-patient distance as a function of both rotation angles
plot3(th_1,th_2,d_s_p,'*k');
xlabel('\theta_1 (roll)');
ylabel('\theta_2 (elev.)');
zlabel('source to patient distance');
axis equal;
axis tight;

%% plot source-to-patient distance when both rotation angles are zero
tgl = th_1==0&th_2==0;
plot(d_s_p(tgl));

%% plot table positions when both rotations are zero (because I realized source-to-patient distance varies)
plot3(table_pos(1,tgl),table_pos(2,tgl),table_pos(3,tgl),'*');

%% plot correlation between s-to-p distance and table position at zero rotations
hold on;
% plot(d_s_p(tgl),table_pos(1,tgl),'*');
% plot(d_s_p(tgl),table_pos(2,tgl),'*');
plot(d_s_p(tgl),table_pos(3,tgl),'*'); % z-position -- especially relevant

% the two seem correlated, but not sure why or how
% perhaps the table moves slightly after each 3D rotation?

% !!!!!!!!!!!!!!! Ok, so we need to be able to calibrate that for each frame!!!!!!!!!!!!!!!!!!!!
% (at least the z-distance would vary slightly, which means the scale of
%  the image would change?)
