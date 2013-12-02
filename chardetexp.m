% Given that you have mixtures of models, this script is to run and output
% the performance on the ICDAR dataset
configs=configsgen;
dataset_path = fullfile(configs.icdar,'test');
imagesPath = fullfile(dataset_path,'images');
modelPath = 'mixture_models';
gtDir = fullfile(configs.icdar,'test','charAnn');
dtDirMix = fullfile(configs.icdar,'test','det_results_mix');
dtDirReal = fullfile(configs.icdar,'test','det_results_real');

%% load the models
models = loadMixtureModels(modelPath);

%% get the image list
imgLst = dir(fullfile(imagesPath,'*.jpg'));
nImg = length(imgLst);
hmsPath = fullfile('hms');
if ~exist(hmsPath,'dir'); mkdir(hmsPath); end

%% Get the heatmap
savehms = @(sf,hms,scales) save(sf,'hms','scales');
parfor i=1:nImg
  i
  savePath = fullfile(hmsPath,sprintf('%s.mat',imgLst(i).name))
  if exist(savePath,'file'); continue; end;
  imgPath = fullfile(imagesPath,imgLst(i).name);
  I = imread(imgPath);
  tic; [hms,scales] = charDetMixtures('gethm',I,models); toc;
  savehms(savePath,hms,scales);
end

%% Get the bbs
savebbs = @(sf,bbs) save(sf,'bbs');
parfor i=1:nImg
  i
  imgPath = fullfile(imagesPath,imgLst(i).name);
  I = imread(imgPath);
  currentHmsPath = fullfile(hmsPath,sprintf('%s.mat',imgLst(i).name));
  bbs = charDetMixtures('getbbs',I,models,currentHmsPath);
  bbs = bbNms(bbs,'type','max','overlap',.5,'separate',1);
  savePath = fullfile(dtDirMix,sprintf('%s.mat',imgLst(i).name));
  savebbs(savePath,bbs);
end

%% Get the f-score
fscores = zeros(length(configs.alphabets),2);
%%
beta = 2;
for iChar = 1:length(configs.alphabets)
  try
    iChar
    currentChar = configs.alphabets(iChar);
    [gt0,~] = bbGt('loadAll',gtDir,[],{'lbls',currentChar});

    fprintf('Load synth\n');
    dtsynth = loadBB(dtDir,iChar);
    fprintf('Load real\n');
    dtreal = loadBB(dtDirReal,iChar);

    % Computing score for synth
    [gts,dts] = bbGt( 'evalRes', gt0, dtsynth);
    [xss,yss,~]=bbGt('compRoc', gts, dts, 0);
    fs = fscore2(xss,yss,beta);
    fscores(iChar,1) = fs;

    % Computing score for real
    [gtr,dtr] = bbGt( 'evalRes', gt0, dtreal);
    [xsr,ysr,~]=bbGt('compRoc', gtr, dtr, 0);
    fs = fscore2(xsr,ysr,beta);
    fscores(iChar,2) = fs;
    fscores
  catch e
    e
    continue
  end
end