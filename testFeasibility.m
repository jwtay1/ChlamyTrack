clearvars
clc

filepath = 'D:\Work\Projects\cameron-chlamy\data\2022.5.7_chlamycc125_1.9pcrgb_bf_cy5_0000.nd2';
reader = BioformatsImage(filepath);

%%
cellAreaLim = [0 Inf];
cellImage = getPlane(reader, 1, 'Cy5', 500);

mask = cellImage > 1500;

mask = imopen(mask,strel('disk',3));
mask = imclearborder(mask);

mask = bwareaopen(mask,100);
mask = imopen(mask,strel('disk',2));
mask = ~bwmorph(~mask, 'clean');

dd = -bwdist(~mask);
dd(~mask) = -Inf;

dd = imhmin(dd, 2);

tmpLabels = watershed(dd);

mask(tmpLabels == 0) = 0;
%%
%Try to mark the image
markerImg = medfilt2(cellImage,[20 20]);

markerImg = imregionalmax(markerImg,8);
markerImg(~mask) = 0;
markerImg = imdilate(markerImg,strel('disk', 6));
markerImg = imerode(markerImg,strel('disk', 3));

imshowpair(I, markerImg)

%%
%Remove regions which are too dark
rptemp = regionprops(markerImg, cellImage,'MeanIntensity','PixelIdxList');
markerTh = median([rptemp.MeanIntensity]) - 0.2 * median([rptemp.MeanIntensity]);

idxToDelete = 1:numel(rptemp);
idxToDelete([rptemp.MeanIntensity] > markerTh) = [];

for ii = idxToDelete
    markerImg(rptemp(ii).PixelIdxList) = 0;
end

dd = imcomplement(medfilt2(cellImage,[4 4]));
dd = imimposemin(dd, ~mask | markerImg);

cellLabels = watershed(dd);
cellLabels = imclearborder(cellLabels);
cellLabels = imopen(cellLabels, strel('disk',6));

%Redraw the masks using cylinders
rpCells = regionprops(cellLabels,{'Area','PixelIdxList'});

%Remove cells which are too small or too large
rpCells(([rpCells.Area] < min(cellAreaLim)) | ([rpCells.Area] > max(cellAreaLim))) = [];

cellLabels = zeros(size(cellLabels));
for ii = 1:numel(rpCells)
    cellLabels(rpCells(ii).PixelIdxList) = ii;
end

LL = cellLabels;


imshowpair(cellImage, LL == 0);