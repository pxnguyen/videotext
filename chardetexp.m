% Given that you have mixtures of models, this script is to run and output
% the performance on the ICDAR dataset
configs=configsgen;
dataset_path = fullfile(configs.icdar,'test');
images_path = fullfile(dataset_path,'images');
models_path = 'mixture_models';

%% get the image list
imglst = dir(fullfile(images_path,'*.jpg'));

%% Get the heatmap
savehms = @(sf,hms,scales) save(sf,'hms','scales');
for i=1:length(imglst)
  imgpath = fullfile(images_path,imglst(i).name);
  I = imread(imgpath);
  [hms,scales] = charDetMixtures('gethm',I,models);
  % save the hms and the scales
end

%% Get the bbs