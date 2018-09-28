function [y1] = myNeuralNetworkFunction_1D(x1)
%MYNEURALNETWORKFUNCTION neural network simulation function.
%
% Generated by Neural Network Toolbox function genFunction, 28-Sep-2018 16:29:39.
%
% [y1] = myNeuralNetworkFunction(x1) takes these arguments:
%   x = Qx16 matrix, input #1
% and returns:
%   y = Qx1 matrix, output #1
% where Q is the number of samples.

%#ok<*RPMT0>

% ===== NEURAL NETWORK CONSTANTS =====

% Input 1
x1_step1.xoffset = [1108.54885627414;17.5218509306948;1108.83381566802;73.9032570849428;1.16812339537966;73.9222543778681;9.89558061268741;1.33634024912722;10.0170509650106;88.6744823923658;3.61713386909063;88.7723495444995;57.5719232240956;-0.83517586129496;57.5821831636548;-2.98089089770168];
x1_step1.gain = [0.138108273943199;0.0233746952333756;0.0974948940941366;2.07162410914798;0.350620428500634;1.46242341141204;13.7191755799448;0.538590315433722;6.25549868669255;6.96774968594772;0.153357900992953;1.15245176636162;1.88741190167626;2.10117025796962;1.86403897500744;0.670940355966075];
x1_step1.ymin = -1;

% Layer 1
b1 = [-1.5954979366454462575;-1.1093926563346325764;-1.4433430809162370867;-0.91612995499949134715;-0.15263189367321972068;0.15650400703256292512;0.60638171391955120182;0.90938727285640663656;1.2749046266223291735;1.3597124532463960023];
IW1_1 = [0.2390222099430963365 -0.087656259686562459921 0.05976465456002836435 -0.05838411177468644242 -0.24425596767618384941 -0.40190135597583193094 -0.10887005452854719989 0.52616289727785325869 0.816235620337064538 0.21501628978698011929 -0.48930956406243147905 -0.51555337258296107805 0.31522334261251316878 -0.26344523185859708425 -0.60267781920564966747 -0.25441406811524663878;0.19995958013731521263 0.57249729321355857792 -0.21661204396910857528 -0.33932115621828634611 0.46258008663974881092 -0.43472182532253755838 -0.81650644248841452999 0.2718148883459573506 -0.83346389184251690185 0.15313490553074943223 0.6297089909393257523 -0.6068579446698948443 1.003253468291328776 0.50991655175548888934 0.11929955694255356402 0.68633341337208120247;0.22067899693038584008 -0.03991642900803021865 0.18971491428577968996 0.5934547012283766243 -0.61925536428814342838 0.7379227810349163752 -0.42143364198139737775 0.058087079665762826608 0.11884477934076209671 -0.70364326051417325214 -0.29808283792197920459 0.94938693238535398766 0.19492853425906850329 -0.32492074534996606694 -0.11478597998813028225 -0.11146840286174689028;-0.12075427261269169876 0.10512123201055208199 0.29385244958756839839 -0.38043528370151963314 -0.10340095319581102395 -0.12404579220455412558 0.76938957071130775756 0.1444975373664455498 0.084104015680614263584 -0.34555257279632811684 -0.014594921712290339841 -0.62112424130974497327 0.53849876120435336002 -0.28487352697826356929 0.43778582183012598739 -0.75028064650625458931;0.21296064241763670855 0.28104179118549543759 0.23891975026691256168 0.32360810989962013329 -0.6730858983073076951 0.58806855208153985259 0.53565542105946495344 0.36960113814751688333 0.17566609876939470736 -0.27930249594937067714 0.46573847318570421594 -0.57544775710976836525 0.41749035782757293322 -0.46758011656149889301 0.56120988682685124527 0.61418448942839531934;0.70253696140371568735 0.20650530601375627349 0.20705595171970059276 0.061671476290684021371 0.37100406734362112449 -0.55493041887223815145 0.25081186939169297645 0.3391804387294832801 0.022109256811523807229 -0.57621190783754272502 0.4825218071955874044 -0.16316162185618543479 -0.63820587971757891665 0.19163179833916821337 -0.2785782706617975224 0.41094638602295630037;0.18396370697840910835 -0.44491560740179963984 -0.56572971833681651166 0.33468986081562446255 -0.49819990450020645856 -0.12780568982283560531 -0.64083618848937085044 0.28805065732669610234 0.096730649857250980417 -0.39101716539172004516 -0.48307226001249586878 0.53259386326268087775 -0.037651464943726890844 0.33935629995586996666 -0.66386047070406084547 0.11339104664555386959;-0.0013019938959051343547 -0.56116216710456878758 -0.27277546550171233308 0.43262658283780724977 -0.45333269124149233598 -0.092720961363754947349 0.16904915153373792358 -0.22893698920668892338 -0.12287997235741764113 0.15434258928314451009 0.20079553498696608993 0.29051261408188977509 -0.37507698719815751875 -0.023125991721130369216 -0.50408027039578517936 0.7764851393578406924;0.40386836836621442526 -0.39879137669518588405 -0.14077243687128282446 -0.11721310107343577145 -0.52227162716108543883 -0.061026505539421897761 -0.61071632421620336562 0.025824429026530211495 0.074038896126291650623 -0.8711921608499046954 0.49371241543033789201 -0.83413617616767310459 0.32235719997475864584 0.18645596660609470296 -0.30587478976177162604 -0.56151105718430771585;-0.13086294758420441431 0.49915034968641697199 -0.30936362041218729013 0.28230729321083436467 0.28017161185776917609 0.24838005384951300503 0.1286075679887569434 -0.35642915777337458305 -0.36245623535640281165 0.59408652716199172872 0.64812020703078787598 0.07386849126753003425 0.40941697249777303513 0.64607890512203791644 0.28696515123565602412 0.57110670823140685659];

% Layer 2
b2 = -0.099616093060901911294;
LW2_1 = [0.8521134540374313282 0.018175766265458699611 -0.70357113662431514101 -0.0049989772476455550387 0.33712197176486113914 -0.25896503260119546619 0.42586130497148255714 0.25874615384408627961 0.56049358421691319876 -0.070835957870317475815];

% Output 1
y1_step1.ymin = -1;
y1_step1.gain = 0.025;
y1_step1.xoffset = 0;

% ===== SIMULATION ========

% Dimensions
Q = size(x1,1); % samples

% Input 1
x1 = x1';
xp1 = mapminmax_apply(x1,x1_step1);

% Layer 1
a1 = tansig_apply(repmat(b1,1,Q) + IW1_1*xp1);

% Layer 2
a2 = repmat(b2,1,Q) + LW2_1*a1;

% Output 1
y1 = mapminmax_reverse(a2,y1_step1);
y1 = y1';
end

% ===== MODULE FUNCTIONS ========

% Map Minimum and Maximum Input Processing Function
function y = mapminmax_apply(x,settings)
y = bsxfun(@minus,x,settings.xoffset);
y = bsxfun(@times,y,settings.gain);
y = bsxfun(@plus,y,settings.ymin);
end

% Sigmoid Symmetric Transfer Function
function a = tansig_apply(n,~)
a = 2 ./ (1 + exp(-2*n)) - 1;
end

% Map Minimum and Maximum Output Reverse-Processing Function
function x = mapminmax_reverse(y,settings)
x = bsxfun(@minus,y,settings.ymin);
x = bsxfun(@rdivide,x,settings.gain);
x = bsxfun(@plus,x,settings.xoffset);
end
