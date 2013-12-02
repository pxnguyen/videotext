function varargout=charDetVideo(action,varargin)
% Detect the initial detections for characters
%
% USAGE:
%   hms = charDetVideo('gethm',videos,models)
%   bbs = charDetVideo('getbbs',hms,models)
%
% INPUTS
%   frames: [4-D] array containing the frames in order
%
% Outputs:
%   bbs_videos: matrix of bounding box output
%

varargout = cell(1,max(1,nargout));
[varargout{:}] = feval(action,varargin{:});
end

% This function returns the heatmap of the videos
function isGood=gethm(vidobject,models)
configs = configsgen; nFrames = vidobject.NumberOfFrames;

newTempFolder = fullfile('temp','hms',vidobject.Name);
if ~exist(newTempFolder,'dir'); mkdir(newTempFolder); end
saveFrame = @(sf,hms,scales) save(sf,'hms','scales');
parfor iFrame=1:nFrames
  iFrame
  fprintf('Working on frame %d...\n',iFrame);
  sf = fullfile(newTempFolder,sprintf('%d.mat',iFrame));
  if exist(sf,'file') > 0; fprintf('Skipped\n'); continue; end
  I = read(vidobject,iFrame);
  tic; [hms,scales] = get_filter_responses(I,models,configs); toc;
  saveFrame(sf,hms,scales);
end
isGood=true;
end

function isGood=getbbs(vidobject,models)
% Return the bbs from the previously collected hms
configs = configsgen;
nFrames = vidobject.NumberOfFrames;
new_temp_folder = fullfile('temp','bbs',vidobject.Name);
if ~exist(new_temp_folder,'dir'); mkdir(new_temp_folder); end
savebbs = @(sf,bbs) save(sf,'bbs');
parfor iFrame=1:nFrames
  iFrame
  fprintf('Working on frame %d...\n',iFrame);
  hms_path = fullfile('temp','hms',vidobject.Name);
  % load the hms
  lstruct = load(fullfile(hms_path,sprintf('%d.mat',iFrame)));
  hms = lstruct.hms;
  sf = fullfile(new_temp_folder,sprintf('%d.mat',iFrame));
  if exist(sf,'file') > 0; fprintf('Skipped\n'); continue; end;
  tic; bbs = getbbsHelper(models,hms,configs); toc;
  
  % Save the bbs
  savebbs(sf,bbs);
end
isGood=true;
end

function bbs=getbbsHelper(models,hms,scales,configs)
initthres = configs.initThres;
total_bbs = zeros(1e6,6);
total = 0;

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
