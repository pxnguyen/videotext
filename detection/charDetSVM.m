function bbs=charDetSVM(I,models,varargin)
% Multi-scale sliding window character detection using Ferns
%
% USAGE
%  bbs = charDet( I, fModel, varargin)
%
% INPUTS
%  I           - image
%  fModel      - fern object
%  varargin    - additional params
%   .ss        - [2^(1/4)] scale step
%   .minH      - [.04] min sliding window size ratio
%   .maxH      - [1] max sliding window size ratio
%   .thr       - [-75] character detection threshold
%
% OUTPUTS
%  bbs         - matrix of bounding box output: location, scale, score
%
% CREDITS
%  Written and maintained by Kai Wang and Boris Babenko
%  Copyright notice: license.txt
%  Changelog: changelog.txt
%  Please email kaw006@cs.ucsd.edu if you have questions.
bbs=zeros(1e6,6); 
configs = configsgen;
total_bbs = zeros(1e6,6);
total = 0;
[hms,scales]=get_filter_responses(I,models);
initial_thresholds = -2;
for level=1:length(scales)
    hms_scale = hms{level};
    if isempty(hms_scale)
        continue;
    end
    current_scale = scales(level);
    for model_index = 1:length(models)
        char_dims = models{model_index}.char_dims;
        hm = hms_scale{model_index} + models{model_index}.bias;

        [y,x] = find(hm > initial_thresholds); % Get the locations of the response
        if (isempty(x)); continue; end;
        scores = hm(hm > initial_thresholds);
        
        assert(length(x)==length(scores));

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