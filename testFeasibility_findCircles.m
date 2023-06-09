clearvars
clc

filepath = 'D:\Work\Projects\cameron-chlamy\data\2022.5.7_chlamycc125_1.9pcrgb_bf_cy5_0000.nd2';
reader = BioformatsImage(filepath);

I = getPlane(reader, 1, 'Cy5', 501);

[centers,radii] = imfindcircles(I,[30 70],"ObjectPolarity","bright", ...
          "Sensitivity",0.9,"Method","twostage");

% imshow(I, [])
% viscircles(centers,radii);

mask = false(size(I));

xx = 1:size(mask, 2);
yy = 1:size(mask, 1);
[xx, yy] = meshgrid(xx, yy);

for idx = 1:size(centers, 1)

    mask(((xx - centers(idx, 1)).^2 + (yy - centers(idx, 2)).^2) <= (radii(idx) - 3)^2) = true;

end

%%
dd = -bwdist(~mask);
dd = imhmin(dd, 5);
L = watershed(dd);

finalMask = mask;
finalMask(L == 0) = 0;

imshowpair(I, bwperim(finalMask))


