configs=configsgen;

% Add piotr toolbox
addpath(genpath(configs.piotr_toolbox))
addpath(genpath(configs.libsvm));

% Add path ihog
%addpath(genpath(configs.ihog))

% Add local libraries
addpath(genpath('.'));

% Open all the matlab works