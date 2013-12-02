function models=loadModels(path)
% this function loa the trained models given the path
%
% INPUTS
%   path: the folder where all the models are stored
%
% OUTPUTS
%   models - format models{charind}{clusterind}

configs=configsgen;
models = cell(64,1);
count = 1;
for iChar=1:length(configs.alphabets)
  toload = fullfile(path,sprintf('%s.mat',configs.alphabets(iChar)));
  if ~exist(toload,'file'); continue; end
  lstruct= load(toload);
  models{count} = lstruct.model;
  count = count + 1;
end
models = models(1:count-1);
end
