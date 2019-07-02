function [a_mean,b_mean] = FindHelixBaseXY(H,ref_range,dbgflag)

sch_rm_pxl = 3; % (pixels) threshold for removing small object during helix base identification process
sch_d = 15; % (pixels) minimum number of pixels for two horizontally aligned points to be considered the helix base

fr = stretchlim(H); % default: [0.01,0.99] % calculate stretch imits
I_str_temp = imadjust(H,fr); % stretch image (contract adjusting)
I_ref_sch = edge(I_str_temp); % identify edges
I_ref_sch = bwareaopen(I_ref_sch,sch_rm_pxl); % remove small objects (smaller than 3 pixels)

I_ref_sch = I_ref_sch(ref_range(1):ref_range(2),ref_range(3):ref_range(4)); % focus on the "reference" area of interest
I_ref_sch = double(I_ref_sch); % convert into doubles

[a_base,b_base] = FindLowestHelix(ref_range,I_ref_sch,sch_d); % identify the lowest pair of horizontal pixels that are at least "d" pixels apart
a_base = a_base + ref_range(1); b_base = b_base + ref_range(3); % offset critical pixels to the gloabl area of interest
a_mean = mean(a_base); b_mean = mean(b_base); % average critical pixels


if dbgflag
    hold on;
    imshow(I_str_temp); % show original "gloabl" area
    plot(b_base,a_base,'.r'); % plot critical points
    plot(b_mean,a_mean,'.w','markersize',msize,'linewidth',lwd); % plot calculated helix base        
end