function varargout=charDetVideo(action,varargin)
% Detect the initial detections for characters
% Inputs
%   frames: [4-D] array containing the frames in order
% Outputs:
%   bbs_videos: matrix of bounding box output
% Usage
%   hms = charDetVideo('gethm',videos,models)
%   bbs = charDetVideo('getbbs',hms,models)

varargout = cell(1,max(1,nargout));
[varargout{:}] = feval(action,varargin{:});
end

% This function returns the heatmap of the videos
function hmresponses=gethm(vidobject,models)
% Inputs:
% Outputs:
configs = configsgen;
nFrames = vidobject.NumberOfFrames;
hmresponses = cell(nFrames,1);
parfor frame_index=1:nFrames
    fprintf('Working on frame %d\n',frame_index);
    tic;
    I = read(vidobject,frame_index);
    hms = get_filter_responses(I,models,configs);
    
    % save the hms in a temp folder
    hmresponses{frame_index} = hms;
    toc;
end

%frame_responses_smoothed = temporal_smoothing(frame_responses);

% bbs_videos = cell(nFrames,1);
% for frame_index=1:nFrames
%     frame_response = frame_responses_smoothed{frame_index};
%     bbs_videos{frame_index} = get_bbs(frame_response);
% end

end