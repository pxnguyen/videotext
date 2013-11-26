function [hard_negative_patches,no_detection,isFull]=mine_negative(model,indeces,limit,nothing_list)
configs = configsgen;
char_dims = model.char_dims; isFull = false;
files = dir(fullfile(configs.RandomFlickr,'*.jpg'));
hard_negative_patches = zeros(char_dims(1),char_dims(2),3,limit);
no_detection = zeros(600,1);
count = 1;
ticId = ticStatus('Mining negatives...');
for i=1:length(indeces)
  tocStatus( ticId, i/length(indeces) );
  current_index = indeces(i);
  filepath = fullfile(configs.RandomFlickr,files(current_index).name);
  I = imread(filepath);
  bbs = detect(I,{model},0);
  if size(bbs,1) < 1
      continue
  end
  [patches,~] = bbApply('crop',I,bbs);

  for j=1:length(patches)
      image = patches{j};
      image = imResample(image,char_dims);
      if count <= limit
          hard_negative_patches(:,:,:,count) = image;
          count = count + 1;
      else
          isFull = true;
          fprintf('Full, exiting\n');
          return
      end
  end
end

hard_negative_patches = hard_negative_patches(:,:,:,1:count-1);
if count > limit/2
    isFull = true;
end
fprintf('Not full\n');
end