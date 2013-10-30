function video = readVideoFromFrames(video_folder_path)
% This function returns the videos read in from a frame folder
frm_paths = dir(fullfile(video_folder_path,'*.jpg'));
nFrame = length(frm_paths);

% Read the first frame to initiate the structure
I = imread(fullfile(video_folder_path,frm_paths(1).name));
[rows,cols,~] = size(I);
video = zeros(rows,cols,3,nFrame);
for frame_index = 1:length(frm_paths)
    video(:,:,:,frame_index) = uint8(imread(fullfile(video_folder_path,...
        frm_paths(frame_index).name)));
end
end