clearvars
clc

filepath = 'D:\Work\Projects\cameron-chlamy\data\2022.5.7_chlamycc125_1.9pcrgb_bf_cy5_0000.nd2';
reader = BioformatsImage(filepath);

%%
cellImage = getPlane(reader, 1, 'Cy5', 500);
mask = cellImage > 2600;

% %Get user to mark image
% roiMask = false(size(mask));
% roiList = [];
% 
% xx = 1:size(mask, 2);
% yy = 1:size(mask, 1);
% [xx, yy] = meshgrid(xx, yy);
% 
% currInput = 0;
% while ~isempty(currInput)
% 
%     imshowpair(cellImage, roiMask);
%     currInput = ginput(1);
% 
%     if ~isempty(currInput)
%         %Make a small circle at each ROI
%         roiMask(((xx - currInput(1, 1)).^2 + (yy - currInput(1, 2)).^2) <= 5^2) = true;
% 
%         roiList = [roiList; currInput];
%     end
% end

%%Alternative test
load rois.mat

%Get user to mark image
roiMask = false(size(mask));

xx = 1:size(mask, 2);
yy = 1:size(mask, 1);
[xx, yy] = meshgrid(xx, yy);

for idx = 1:size(roiList, 1)
    %Make a small circle at each ROI
    roiMask(((xx - roiList(idx, 1)).^2 + (yy - roiList(idx, 2)).^2) <= 5^2) = true;
end

mask = imopen(mask, strel('disk', 3));

dd = -bwdist(~mask);
dd(~mask) = -Inf;
dd = imhmin(dd, 2);

dd = imimposemin(dd, roiMask);
%dd(roiMask) = min(dd(dd > -Inf), [], 'all');

LL = watershed(dd);

finalMask = mask;
finalMask(LL == 0) = false;

finalMask = bwareaopen(finalMask, 800);

imshowpair(cellImage, finalMask);

