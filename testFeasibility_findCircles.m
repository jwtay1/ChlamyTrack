clearvars
clc

filepath = 'D:\Work\Projects\cameron-chlamy\data\2022.5.7_chlamycc125_1.9pcrgb_bf_cy5_0000.nd2';
reader = BioformatsImage(filepath);

I = getPlane(reader, 1, 'Cy5', 501);

%% Find circles to mark cells

[centers,radii] = imfindcircles(I,[30 50],"ObjectPolarity","bright", ...
          "Sensitivity",0.9,"Method","twostage");

mask = false(size(I));

xx = 1:size(mask, 2);
yy = 1:size(mask, 1);
[xx, yy] = meshgrid(xx, yy);

for idx = 1:size(centers, 1)

    mask(((xx - centers(idx, 1)).^2 + (yy - centers(idx, 2)).^2) <= (radii(idx) - 3)^2) = true;

end

imshowpair(I, mask)

% imshow(I, [])
% viscircles(centers,radii);

%%
dd = -bwdist(~mask);
dd = imhmin(dd, 25);
L = watershed(dd);

finalMask = mask;
finalMask(L == 0) = 0;

imshowpair(I, finalMask)

%% Get marker locations

markData = regionprops(finalMask, 'Centroid');
markMask = false(size(finalMask));

markLocs = round(cat(1, markData.Centroid));

for ii = 1:size(markLocs, 1)
    markMask(markLocs(ii, 2), markLocs(ii, 1)) = true;
end

imshowpair(I, imdilate(markMask, strel('disk', 3)))


%%

Ifilt = imgaussfilt(I, 2);

intMask = imbinarize(Ifilt, 'adaptive', ...
    'Sensitivity', 0.7);

intMask = imclearborder(intMask);
intMask = imopen(intMask, strel('disk', 10));

dd = -bwdist(~intMask);

dd = imimposemin(dd, ~intMask | markMask);

%dd(~intMask) = -Inf;

% dd = imhmin(dd, 1);

%dd = imimposemin(dd, markMask);

L = watershed(dd);

finalMask = intMask;
finalMask(L == 0) = 0;

imshowpair(I, label2rgb(L))







