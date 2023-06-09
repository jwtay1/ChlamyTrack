function finalMask = chlFindCircles(cellImage, ~)

[centers,radii] = imfindcircles(cellImage,[30 70],"ObjectPolarity","bright", ...
          "Sensitivity",0.9,"Method","twostage");

mask = false(size(cellImage));

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

end