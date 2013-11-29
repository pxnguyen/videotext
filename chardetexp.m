% Given that you have mixtures of models, this script is to run and output
% the performance on the ICDAR dataset
configs=configsgen;
dataset_path = fullfile(configs.icdar,'test');
imagesPath = fullfile(dataset_path,'images');
modelPath = 'mixture_models';

%% load the models
models = loadMixtureModels(modelPath);

%% get the image list
imgLst = dir(fullfile(imagesPath,'*.jpg'));
nImg = length(imgLst);

%% Get the heatmap
savehms = @(sf,hms,scales) save(sf,'hms','scales');
for i=1:nImg
  i
  imgPath = fullfile(imagesPath,imgLst(i).name);
  I = imread(imgPath);
  [hms,scales] = charDetMixtures('gethm',I,models);
  % save the hms and the scales
end

%% size(models,1)Get the bbs