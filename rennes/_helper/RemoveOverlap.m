function tgl_near = RemoveOverlap(PXY,m_dist)

PXY_sch = PXY; % presearch original array 
tgl_near = true(1,length(PXY)); % preallocate

for pp = 1:length(PXY_sch)
    
    X = PXY_sch; X(pp,:) = nan; % original array minus the point of interest 
    Y = PXY_sch(pp,:); % point of interest
    Idx = knnsearch(X,Y); % index of the nearest point to the point of interest
    dist = Y - X(Idx,:); % difference between the two points
    dist = sqrt(sum(dist.^2)); % distance between the two points 
    
    if  dist < m_dist        
%         plot(PXY_sch(Idx,1),PXY_sch(Idx,2),'xk','linewidth',2); hold on;
        PXY_sch(Idx,:) = nan; % remove the other point (to avoid duplication)
        tgl_near(Idx) = 0; % turn the toggle off
    end
end
% plot(PXY(tgl_near,1),PXY(tgl_near,2),'or');