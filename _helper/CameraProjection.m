function [xo,yo] = CameraProjection(X,th,c,e)

if size(X,1)~=3
    X = X';
    if size(X,1)~=3
        error('Input X must be a 3 by N matrix');
    end
end
if size(c,1)~=3
    c = c';
    if size(c,1)~=3
        error('Input c must be a 3 by 1 matrix');
    end
end
if size(e,1)~=3
    e = e';
    if size(e,1)~=3
        error('Input e must be a 3 by 1 matrix');
    end
end

xi = X(1,:); yi = X(2,:); zi = X(3,:);

% define camera and image plane
% c = [0;0;0]; % camera location
% e = [0;0;-2.5]; % image plane "relative to camera" (negagive: behind the camera)

ROT = getRX(th(1))*getRY(th(2))*getRZ(th(3));

a = [xi; yi; zi]; % 3 camera rotation angles

b = nan(2,length(xi)); % preallocate
d_arr = nan(3,length(xi)); % preallocate

for nn = 1:length(xi)
    
    d = ROT*(a(:,nn)-c);
    b(:,nn) = (e(3)/d(3))*d(1:2) + e(1:2);
    d_arr(:,nn) = d;
    
end

xo = d_arr(1,:);
yo = d_arr(2,:);