% Given that you have mixtures of models, this script is to run and output
% the performance on the ICDAR dataset
configs=configsgen;
[dPath,ch,ch1,chC,chClfNm,dfNP]=globals;
dataset_path = fullfile(configs.icdar,'test');
imagesPath = fullfile(dataset_path,'images');
modelPath = 'mixture_models';

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
dtDirMix = fullfile(configs.icdar,'test','det_results_mix');
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
gtDir = fullfile(dPath,'icdar','test','charAnn');
dtDir = fullfile(dPath,'icdar','test','det_results');
fscores = zeros(20,2);
ticId = ticStatus('Collecting Fscore',1,30,1);
for iChar = 1
  iChar
  currentChar = ch(iChar);
  tocStatus(ticId,iChar/(length(ch)-1));
  [gt0,~] = bbGt('loadAll',gtDir,[],{'lbls',currentChar});
  gt0 = gt0(1:15);
  dtmix = loadBB(dtDirMix,iChar);
  dtsynth = loadBB(dtDir,iChar);
  for i=1:length(dtsynth)
    bbs = dtsynth{i};
    dtsynth{i} = bbNms(bbs,'type','max','overlap',.5,'separate',1);
  end
  
  % Computing score for mix
  [gtm,dtm] = bbGt( 'evalRes', gt0, dtmix);
  [xsm,ysm,~]=bbGt('compRoc', gtm, dtm, 0);
  fs = Fscore(xsm,ysm);
  fscores(iChar,1) = fs;
  
  % Computing score for synth
  dtsynth = dtsynth(1:15);
  [gts,dts] = bbGt( 'evalRes', gt0, dtsynth);
  [xss,yss,~]=bbGt('compRoc', gts, dts, 0);
  fs = Fscore(xss,yss);
  fscores(iChar,2) = fs;
  fscores
end