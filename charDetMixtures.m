function varargout=charDetMixtures(action,varargin)
% Detect characters using multiple mixtures of a model
%
% INPUTS
%   frames: [4-D] array containing the frames in order
%
% OUTPUTS:
%   bbs_videos: matrix of bounding box output
% Usage
%   hms = charDetVideo('gethm',videos,models)
%   bbs = charDetVideo('getbbs',hms,models)

varargout = cell(1,max(1,nargout));
[varargout{:}] = feval(action,varargin{:});
end

% This function returns the heatmap of the videos
function [hms,scales]=gethm(I,models)
% INPUTS:
%   I - image
%   models - two layers cell-array, models{charindex}{mixtureindex}
%       
% OUTPUTS:
%   hms - one layer cell-array, hms{charindex} the heatmap response is
%     combined through taking the max of all the response.
%   scales - the scales used for detections
configs = configsgen;
[hms,scales] = getHeatmapMixtures(I,models,configs);
end

function bbs=getbbs(I,models,hmsPath)
% Return the bbs from the previously collected hms
%
% INPUTS:
%   I - image
%   models - two layers cell-array, models{charindex,mixtureindex}
%       
% OUTPUTS:
%   hms - one layer cell-array, hms{charindex} the heatmap response is
%     combined through taking the max of all the response.
%   scales - the scales used for detections
configs = configsgen;
% load the hms
lstruct = load(hmsPath);
hms = lstruct.hms;
scales = lstruct.scales;
bbs = getbbsHelper(models,hms,scales,configs);
end

function bbs=getbbsHelper(models,hms,scales,configs)
initthres = configs.initThres;
total_bbs = zeros(1e6,6);
total = 0;
nScales = length(scales);
for iLevel=1:nScales
    hmsAtCurrentScale = hms{iLevel};
    if isempty(hmsAtCurrentScale); continue; end;
    current_scale = scales(iLevel);
    for iModel = 1:size(models,1)
        currentModel = models{iModel,1};
        charDims = currentModel.char_dims;
        hm = hmsAtCurrentScale{iModel} + currentModel.bias;
        
        ind = find(hm > initthres); % Get the locations of the response
        [y,x] = ind2sub(size(hm),ind);
        if (isempty(x)); continue; end;
        
        scores = hm(ind);
        if (size(x,2) > 1); x = x'; y = y'; scores = scores'; end
        %assert(length(x)==length(scores));

        %Correct the position
        x = x * configs.bin_size/current_scale;
        y = y * configs.bin_size/current_scale;
        width = floor(charDims(2)/current_scale);
        height = floor(charDims(1)/current_scale);
        
        ind = strfind(configs.alphabets,currentModel.char_index);
        bbType = ones(length(x),1)*ind;
        bbs = [x,y,repmat(width,length(x),1),repmat(height,...
               length(x),1),scores,bbType];

        currentCount = size(bbs,1);
        if currentCount > 0
            total_bbs(total+1:total+currentCount,:) = bbs;
            total = total + currentCount;
        end
    end
end

bbs=total_bbs(1:total,:);
end