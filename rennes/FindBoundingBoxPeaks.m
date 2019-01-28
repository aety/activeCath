function P = FindBoundingBoxPeaks(BoundingBox,Centroid,MajorAxisLength,MinorAxisLength,Orientation,x,y)
% clear; clc; ca;
% load test_find_BoundingBoxPeaks BoundingBox Centroid MajorAxisLength MinorAxisLength Orientation x y

tgl_plt = 0;
el_npt = 50; % number of points of ellipses

bb_n = length(BoundingBox);
P = nan(bb_n,2);

for ii = 1:length(BoundingBox)
    
    %% boundingbox
%     bb_pixels = BoundingBox(ii,1:2); % bottom-left corner of bounding boxes
%     bb_x = nan(BoundingBox(ii,3),BoundingBox(ii,4)); bb_y = bb_x; % preallocate
%     for aa = 1:BoundingBox(ii,3)
%         for bb = 1:BoundingBox(ii,4)
%             bb_x(aa,bb) = bb_pixels(1) + (aa-1); % contruct a 2D array describing pixel locations
%             bb_y(aa,bb) = bb_pixels(2) + (bb-1); % contruct a 2D array describing pixel locations
%         end
%     end
%     bb_x(~FilledImage{ii}) = nan; % remove empty pixels
%     bb_y(~FilledImage{ii}) = nan; % remove empty pixels
    
    %% ellipse
    t = linspace(0,2*pi,el_npt);    % array of angular variations
    a = MajorAxisLength(ii)/2;      % major axis
    b = MinorAxisLength(ii)/2;      % minor axis
    Xc = Centroid(ii,1);            % ellipse centroid x
    Yc = Centroid(ii,2);            % ellipse centroid y
    phi = deg2rad(-Orientation(ii));                    % orientation
    xe = Xc + a*cos(t)*cos(phi) - b*sin(t)*sin(phi);    % x-coordinate of the ellipse
    ye = Yc + a*cos(t)*sin(phi) + b*sin(t)*cos(phi);    % x-coordinate of the ellipse
    
    %% centroid to curve distance
    XI = Centroid(ii,:);    % subject point (the centroid of the ellipse in this case )
    X = [y;x]';             % object points (catheter full length in this case)
    T = delaunayn(X);       % calculate Delaunay Triangulation
    k1 = dsearchn(X,T,XI);  % search for the point on the catheter closest to the centroid
    
    XI = [y(k1);x(k1)]';            % subject point (the nearest point on the catheter from the centroid)
    X = [xe;ye]'; X(end,:) = [];    % object points (ellipse) (eliminating the last row to avoid repetitions)
    T = delaunayn(X,{'Qt','Qbb','Qz'}); % calculate Delaunay Triangulation (changed last option too 'Qz' to resolve co-circular problem)
    k2 = dsearchn(X,T,XI);              % search for the point on the ellipse closest to the catheter
    k2 = k2 + el_npt/2;                 % Search for the point on the ellipse furthest to the catheter (opposite to the previous point)
    k2(k2>el_npt) = k2(k2>el_npt) - el_npt; % round the index down if over the number of elements
    
    %% plot
    if tgl_plt
        axis equal
        hold on;
        
        plot(Xc,Yc,'.m'); % centroid of bounding boxes
        plot(y(k1),x(k1),'*k'); % nearest point on catheter
%         plot(bb_x,bb_y,'.b') % pixels in bounding boxes
        plot(xe,ye,'m') % ellipses                        
        plot(xe(k2),ye(k2),'*r'); % furthest point on the ellipse
    end
    P(ii,:) = [xe(k2),ye(k2)];
end

if tgl_plt
    plot(y,x,'k');
end