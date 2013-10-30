% Youtube experiments without lexicons
% experiments parameters
withLex = 0;
% reading in the video
configs=configsgen;
video_folder = configs.YVT_path;
temporal_data_folder = 'temp';

%% Read videos
% Can't, not enough memory
%videos = readVideoFromFrames(fullfile(video_folder,'frames'));

%% play the videos
%matlabpool

%%
% Run the character detection on every videos
frames_path = fullfile(configs.YVT_path,'frames');
matfiles_path = fullfile(configs.YVT_path,'matfiles');
vidpaths = dir(frames_path);
vidpaths = vidpaths(3:end);

% save function
saveVideo = @(sF,vid) save(sF,'vid','-v7.3');
for vidindex = 1:length(vidpaths)
    vidpath = fullfile(frames_path,vidpaths(vidindex).name);
    matpath = fullfile(matfiles_path,[vidpaths(vidindex).name '.mat']);
    fprintf('Working on %s\n',vidpath);
    if exist(matpath,'file') > 0
        fprintf('%s existed.\n',matpath);
        continue
    end
    vid=readVideoFromFrames(vidpath);
    saveVideo(matpath,vid);
    clear vid
    %bbs_videos = charDetVideo(curVid.frames,models);
    %saveVideo(fullfile('bbs_videos',curVid.name),bbs_videos);
end

%% Generating the bounding boxes for the frames
lstruct = load('data/models_real_nomixture');
models = lstruct.models;
videos_path = fullfile(configs.YVT_path,'videos');
vidpaths = dir(fullfile(videos_path,'*.mp4'));
for vidindex = 1:length(vidpaths)
    vpath = fullfile(videos_path,vidpaths(vidindex).name);
    fprintf('Working on %s\n',vpath);
    vidobject = VideoReader(vpath);
    bbs_videos=charDetVideo(vidobject,models);
end

%% Forming words from the character detections
words_videos = cell(length(videos),1);
for video_index = 1:length(videos)
    curVid = videos{video_index};
    path_to_vid = fullfile('bbs_videos',curVid.name);
    lstruct = load(path_to_vid); detections = lstruct.bbs_videos;
    % load the bbs_videos from the previous sections
    if withLex
        words = wordSpotLex(detections,params); % not yet implemented
    else
        words = wordSpotNoLex(detections,params); % not yet implemented
    end
    
    words_videos{video_index} = words;
end

%% Visualization
visVideo(video,detections);
%% Performance evaluation