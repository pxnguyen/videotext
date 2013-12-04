function bbs=detect(I,models,threshold)
% Detect letters in image I
%
% INPUT
%   I - input image
%   models - cells of model
%   threshold - cutoff for detection
%
% OUTPUT
%   bbs - the bounding boxes results
configs = configsgen;
total_bbs = zeros(1e4,6);
total = 0;
[hms,scales]=get_filter_responses(I,models,configs);
nScales = length(scales);
for level=1:nScales
  hms_scale = hms{level};
  if isempty(hms_scale); continue; end;
  current_scale = scales(level);
  for model_index = 1:length(models)
    char_dims = models{model_index}.char_dims;
    hm = hms_scale{model_index} + models{model_index}.bias;
    
    ind = find(hm > threshold); % Get the locations of the response
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

    if models{model_index}.char_index > 60
      ind = strfind(configs.alphabets,currentModel.char_index);
    else
      ind = models{model_index}.char_index;
    end
    bbType = ones(length(x),1)*ind;
    bbs = [x,y,repmat(width,length(x),1),repmat(height,...
           length(x),1),scores,bbType];

    current_count = size(bbs,1);
    if current_count > 0
      total_bbs(total+1:total+current_count,:) = bbs;
      total = total + current_count;
    end
  end
end
total_bbs = total_bbs(1:total,:);
% if more than a 1000 take the top 1000;
if total > 1000
  [~,sort_order] = sort(total_bbs(:,5),'descend');
  total_bbs = total_bbs(sort_order(1:1000),:);
end
bbs = total_bbs;
bbs = bbNms(total_bbs,'type','max','overlap',.5,'separate',1);
end
