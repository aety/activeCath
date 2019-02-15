function p = PeaksInterp(plt)

d_typ = 25; % typical distance between the first peaks (in case the first distance is too big)
thrs = d_typ/2; % threshold for adding points
flg_plt = 0; % toggle for plotting

p = plt;
p(isnan(p(:,1)),:) = [];

d_org = rssq(diff(p)');
d = d_org;
ind = [];
if d(1) > 2*d_typ
    d(1) = d(1)/round(d(1)/d_typ);
    ind = 1;
end
indi = find(diff(d)>thrs);
while ~isempty(indi)    
    ind = [ind,indi(1)];
    d(indi(1)+1) = d(indi(1)+1)/ceil(d(indi(1)+1)/d(indi(1)));    
    indi = find(diff(d)>thrs);    
end

if flg_plt
    hold on;
    plot(p(:,1),p(:,2),'*');
    axis equal
end

x = cell(1,length(ind)); y = x;

if ~isempty(ind)
    
    for tt = 1:length(ind)
        
        k = ind(tt)+1;
        
        n = round(d_org(k)/d(k-1));
        x1 = p(k,1); y1 = p(k,2);
        x2 = p(k+1,1); y2 = p(k+1,2);
        
        xx = linspace(x1,x2,n+1); xx(1) = []; xx(end) = [];
        yy = linspace(y1,y2,n+1); yy(1) = []; yy(end) = [];
        
        if flg_plt
            plot(xx,yy,'*k');
        end
        
        p = [p;[xx',yy']];
        
    end
    
    p = sortrows(p,2);
    
end