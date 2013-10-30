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

new_temp_folder = fullfile('temp','hms',vidobject.Name);
if ~exist(new_temp_folder,'dir')
    mkdir(new_temp_folder)
end
saveFrame = @(sf,hms) save(sf,'hms');
parfor frame_index=1:nFrames
    fprintf('Working on frame %d...',frame_index);
    sf = fullfile(new_temp_folder,sprintf('%d.mat',frame_index));
    if exist(sf,'file') > 0
        fprintf('Skipped\n')
        continue
    end
    tic;
    I = read(vidobject,frame_index);
    [hms,scales] = get_filter_responses(I,models,configs);
    toc;
    saveFrame(sf,hms);
    scales'
end
end

function bbs=getbbs(vidobject,models)
% Return the bbs from the previously collected hms

configs = configsgen;
nFrames = vidobject.NumberOfFrames;
new_temp_folder = fullfile('temp','bbs',vidobject.Name);
if ~exist(new_temp_folder,'dir')
    mkdir(new_temp_folder)
end
savebbs = @(sf,bbs) save(sf,'bbs');
parfor frame_index=1:nFrames
    fprintf('Working on frame %d...',frame_index);
    
    hms_path = fullfile('temp','hms',vidobject.Name);
    % load the hms
    lstruct = load(fullfile(hms_path,sprintf('%d.mat',frame_index)));
    hms = lstruct.hms;
    sf = fullfile(new_temp_folder,sprintf('%d.mat',frame_index));
    if exist(sf,'file') > 0; fprintf('Skipped\n'); continue; end;
    tic; bbs = getbbsHelper(models,hms,configs); toc;
    
    % Save the bbs
    savebbs(sf,bbs);
end
bbs = [];
end

function bbs=getbbsHelper(models,hms,configs)
initthres = configs.initThres;
total_bbs = zeros(1e6,6);
total = 0;

%TODO: need to fix this
scales = [0.1487;
    0.1768;
    0.2102;
    0.2500;
    0.2973;
    0.3536;
    0.4204;
    0.5000;
    0.5946;
    0.7071;
    0.8409;
    1.0000;
    1.1892;
    1.4142;
    1.6818;
    2.0000;
    2.3784;
    2.8284;
    3.3636;
    ];
nScales = size(scales);
for level=1:nScales
    hms_scale = hms{level};
    if isempty(hms_scale); continue; end;
    current_scale = scales(level);
    for model_index = 1:length(models)
        char_dims = models{model_index}.char_dims;
        hm = hms_scale{model_index} + models{model_index}.bias;
        
        ind = find(hm > initthres); % Get the locations of the response
        [y,x] = ind2sub(size(hm),ind);
        if (isempty(x)); continue; end;
        
        scores = hm(ind);
        if (size(x,2) > 1); x = x'; y = y'; scores = scores'; end
        %assert(length(x)==length(scores));

        %Correct the position
        x = x * configs.bin_size/current_scale;
        y = y * configs.bin_size/current_scale;
        width = floor(char_dims(2)/current_scale);
        height = floor(char_dims(1)/current_scale);

        bbType = ones(length(x),1)*models{model_index}.char_index;
        bbs = [x,y,repmat(width,length(x),1),repmat(height,...
               length(x),1),scores,bbType];

        current_count = size(bbs,1);
        if current_count > 0
            total_bbs(total+1:total+current_count,:) = bbs;
            total = total + current_count;
        end
    end
end

bbs=total_bbs(1:total,:);
end