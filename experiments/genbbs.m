% This script is called from the yt_experiments
% It is generating the bounding boxes for the frames
configs=configsgen;
lstruct = load('data/models_real_nomixture');
models = lstruct.models;
avi_path = fullfile(configs.YVT_path,'videos','avi');
vidpaths = dir(fullfile(avi_path,'*.avi'));

%% Getting the hms first
for vidindex = 1%:length(vidpaths)
    vpath = fullfile(avi_path,vidpaths(vidindex).name);
    fprintf('Working on %s\n',vpath);
    vidobject = VideoReader(vpath);
    charDetVideo('gethm',vidobject,models);
end

%% Visualizing to check if the hms working correctly

%% Smoothing the bbs

%% Then get the bbs
for vidindex = 1%:length(vidpaths)
    vpath = fullfile(avi_path,vidpaths(vidindex).name);
    fprintf('Working on %s\n',vpath);
    vidobject = VideoReader(vpath);
    charDetVideo('getbbs',vidobject,models);
end