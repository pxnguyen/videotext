function models=loadMixtureModels(path)
% this function load the entire mixtures models
%
% INPUTS
%   path: the folder where all the models are stored
%
% OUTPUTS
%   models - format models{charind}{clusterind}

configs=configsgen;
%modelPaths = dir(fullfile(path,'*.mat'));
models = cell(length(configs.alphabets),configs.nMixtures);
for iChar=1:length(configs.alphabets)
  for iMixture=1:configs.nMixtures
    toload = fullfile(path,sprintf('%s_%d.mat',configs.alphabets(iChar),iMixture));
    if ~exist(toload,'file'); continue; end
    lstruct= load(toload);
    models{iChar}{iMixture} = lstruct.model;
  end
end