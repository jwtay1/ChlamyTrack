clearvars
clc

filepath = 'D:\Work\Projects\cameron-chlamy\data\2022.5.7_chlamycc125_1.9pcrgb_bf_cy5_0000.nd2';
outputDir = 'D:\Work\Projects\cameron-chlamy\processed\20230622_test';

CT = CyTracker;
CT.FrameRange = 527:670;
CT.ChannelToSegment = 'Cy5';
CT.SegMode = 'chlFindCircles';
CT.LinkedBy = 'Centroid';
CT.LinkCalculation = 'Euclidean';
CT.LinkingScoreRange = [0 500];

process(CT, filepath, outputDir)
