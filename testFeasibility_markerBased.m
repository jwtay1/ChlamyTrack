clearvars
clc

filepath = 'D:\Work\Projects\cameron-chlamy\data\2022.5.7_chlamycc125_1.9pcrgb_bf_cy5_0000.nd2';
reader = BioformatsImage(filepath);

%%
I = getPlane(reader, 1, 'Cy5', 501);

gmag = imgradient(I);
% imshow(gmag,[])
% title("Gradient Magnitude")

L = watershed(gmag);
Lrgb = label2rgb(L);
% imshow(Lrgb)
% title("Watershed Transform of Gradient Magnitude")

se = strel("disk",20);
Io = imopen(I,se);
% imshow(Io)
% title("Opening")

Ie = imerode(I,se);
Iobr = imreconstruct(Ie,I);
% imshow(Iobr)
% title("Opening-by-Reconstruction")

Ioc = imclose(Io,se);
% imshow(Ioc)
% title("Opening-Closing")

Iobrd = imdilate(Iobr,se);
Iobrcbr = imreconstruct(imcomplement(Iobrd),imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);
% imshow(Iobrcbr)
% title("Opening-Closing by Reconstruction")

fgm = imregionalmax(Iobrcbr);
% imshow(fgm)
% title("Regional Maxima of Opening-Closing by Reconstruction")

I2 = labeloverlay(I,fgm);
% imshow(I2)
% title("Regional Maxima Superimposed on Original Image")

se2 = strel(ones(5,5));
fgm2 = imclose(fgm,se2);
fgm3 = imerode(fgm2,se2);

fgm4 = bwareaopen(fgm3,20);
I3 = labeloverlay(I,fgm4);
% imshow(I3)
% title("Modified Regional Maxima Superimposed on Original Image")

bw = imbinarize(Iobrcbr);
% imshow(bw)
% title("Thresholded Opening-Closing by Reconstruction")

D = bwdist(bw);
DL = watershed(D);
bgm = DL == 0;
% imshow(bgm)
% title("Watershed Ridge Lines")

gmag2 = imimposemin(gmag, bgm | fgm4);

L = watershed(gmag2);

%%
mask = L > 1;
mask = imclearborder(mask);
% mask_tooLarge = bwareaopen(mask, 10000);
% mask(mask_tooLarge) = 0;
imshow(mask)

% 
% labels = imdilate(L==0,ones(3,3)) + 2*bgm + 3*fgm4;
% I4 = labeloverlay(I,labels);
% imshow(I4)
% title("Markers and Object Boundaries Superimposed on Original Image")
