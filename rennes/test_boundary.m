load I_str


I = imbinarize(I_str);
test = find(I==0);
[a,b] = ind2sub(size(I),test);
k = boundary([a,b]);
hold on;
scatter(a,b,'.');
plot(a(k),b(k),'linewidth',2);