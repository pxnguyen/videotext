function demoYoutube
% Demo of PLEX running on Youtube image
%
% USAGE
%  demoYoutube
%
% CREDITS
%  Written and maintained by Kai Wang and Boris Babenko
%  Copyright notice: license.txt
%  Changelog: changelog.txt
%  Please email kaw006@cs.ucsd.edu if you have questions.

I = imread('sandbox/0.jpg');
lexS={'Parlophone','Records','Present','Mark','Trade','WINE','COFFEE','fight',...
    'Party','Idea','romantic','texting','cnn','movie','candy','record','action','generic'};

im(I); drawnow;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load classifiers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% word threshold
wordThr=-1;
% character fern
clfPath=fullfile('data','fern_synth.mat');
if(~exist(clfPath,'file')), error('FERN DOES NOT EXIST?!\n'); end
fModel=load(clfPath);
% word svm
svmPath=fullfile('data','svm_svt.mat');
if(~exist(svmPath,'file')), error('SVM MODEL DOES NOT EXIST?!\n'); end
model=load(svmPath); wordSvm=model.pNms1; wordSvm.thr=wordThr;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run word recognition (PLEX)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic; words=wordSpot(I,lexS,fModel,wordSvm,[],{'minH',.04}); toc
wordDetDraw( words, 1, 1, 1, [0 1 0] );

