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

% function bbs=getbbs(I,models)
% % Return the bbs from the previously collected hms
% configs = configsgen;
% nFrames = vidobject.NumberOfFrames;
% new_temp_folder = fullfile('temp','bbs',vidobject.Name);
% if ~exist(new_temp_folder,'dir')
%     mkdir(new_temp_folder)
% end
% savebbs = @(sf,bbs) save(sf,'bbs');
% parfor frame_index=1:nFrames
%     fprintf('Working on frame %d...',frame_index);
%     
%     hms_path = fullfile('temp','hms',vidobject.Name);
%     % load the hms
%     lstruct = load(fullfile(hms_path,sprintf('%d.mat',frame_index)));
%     hms = lstruct.hms;
%     scales = lstruct.scales;
%     sf = fullfile(new_temp_folder,sprintf('%d.mat',frame_index));
%     if exist(sf,'file') > 0; fprintf('Skipped\n'); continue; end;
%     tic; bbs = getbbsHelper(models,hms,configs); toc;
%     
%     % Save the bbs
%     savebbs(sf,bbs);
% end
% bbs = [];
% end
% 
% function bbs=getbbsHelper(models,hms,configs)
% initthres = configs.initThres;
% total_bbs = zeros(1e6,6);
% total = 0;
% 
% %TODO: need to fix this
% nScales = size(scales);
% for level=1:nScales
%     hms_scale = hms{level};
%     if isempty(hms_scale); continue; end;
%     current_scale = scales(level);
%     for model_index = 1:length(models)
%         char_dims = models{model_index}.char_dims;
%         hm = hms_scale{model_index} + models{model_index}.bias;
%         
%         ind = find(hm > initthres); % Get the locations of the response
%         [y,x] = ind2sub(size(hm),ind);
%         if (isempty(x)); continue; end;
%         
%         scores = hm(ind);
%         if (size(x,2) > 1); x = x'; y = y'; scores = scores'; end
%         %assert(length(x)==length(scores));
% 
%         %Correct the position
%         x = x * configs.bin_size/current_scale;
%         y = y * configs.bin_size/current_scale;
%         width = floor(char_dims(2)/current_scale);
%         height = floor(char_dims(1)/current_scale);
% 
%         bbType = ones(length(x),1)*models{model_index}.char_index;
%         bbs = [x,y,repmat(width,length(x),1),repmat(height,...
%                length(x),1),scores,bbType];
% 
%         current_count = size(bbs,1);
%         if current_count > 0
%             total_bbs(total+1:total+current_count,:) = bbs;
%             total = total + current_count;
%         end
%     end
% end
% 
% bbs=total_bbs(1:total,:);
% end