function hard_negative_patches=mine_negative(model,indeces,limit)
% Mining negatives for svm training
%
% INPUTS:
%   model: the trained model
%   indeces: the indeces determine which of the images in the Flickr
%     dataset to use
%   limit: the upper limit of how many negatives to take
%
% OUTPUTS
configs = configsgen;
char_dims = model.char_dims;
files = dir(fullfile(configs.RandomFlickr,'*.jpg'));
hard_negative_patches = zeros(char_dims(1),char_dims(2),3,limit);
count = 1;
for i=1:length(indeces)
  fprintf('working on %d out of %d - count: %d\n',i,length(indeces),count);
  current_index = indeces(i);
  filepath = fullfile(configs.RandomFlickr,files(current_index).name);
  I = imread(filepath); bbs = detect(I,{model},-0.01);
  if size(bbs,1) < 1; continue; end
  [patches,~] = bbApply('crop',I,bbs);

  for j=1:length(patches)
    image = imResample(patches{j},char_dims);
    if count <= limit
      hard_negative_patches(:,:,:,count) = image;
      count = count + 1;
    else
      fprintf('Full, exiting\n');
      return
    end
  end
end

hard_negative_patches = hard_negative_patches(:,:,:,1:count-1);
end
