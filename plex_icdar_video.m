function plex_icdar_video(indeces)
% this script is to run kai system out of the box on the icdar video system
configs=configsgen;
vidpath = fullfile(configs.icdar_video,'test','videos','mp4');
resFolder = fullfile(configs.icdar_video,'test','res');
lexicon_path = fullfile(configs.icdar_video,'test','lex');
vidps = dir(fullfile(vidpath,'*.mp4'));
saveRes=@(f,words,bbs)save(f,'words','bbs');

% Loading the character models
% Ferns + synthesis
clfPath=fullfile('data','fern_synth.mat'); fModel=load(clfPath);
svmPath=fullfile('data','svm_svt.mat'); model=load(svmPath);
wordSvm=model.pNms1; wordSvm.thr=-1;

if ~exist('indeces','var'); indeces=1:length(vidps); end;
for vidindex = indeces
  vpath = fullfile(vidpath,vidps(vidindex).name);
  fprintf('Working on %s\n',vpath);

  % Get the video
  done = false;
  while ~done
    vidobject = VideoReader(vpath);
    if vidobject.NumberOfFrames > 0
      done = true;
    end
  end
  
  % Parse the name
  [~,name,~] = fileparts(vidps(vidindex).name);
  [~,name,~] = fileparts(name);
  
  %create the folder
  if exist(fullfile(resFolder,name),'dir') == 0
    mkdir(fullfile(resFolder,name));
  end
  
  % read in the lexicons
  lexpath = fullfile(lexicon_path,[name '.xml.lex']);
  fid=fopen(lexpath,'r'); lexS=textscan(fid,'%s'); lexS=lexS{1}'; fclose(fid);
  allframes = read(vidobject);
  nFrame = size(allframes,4);
  nDone = length(dir(fullfile(resFolder,name,'*,mat')));
  if nFrame == nDone; continue; end
  
  clear allframes;
  parfor iFrame = 1:nFrame
    fprintf('%s: frame %d\n',name,iFrame);
    sf = fullfile(resFolder,name,sprintf('%d.mat',iFrame));
    if exist(sf,'file') > 0; fprintf('Skipped\n'); continue; end;
    
    try
      I = read(vidobject,iFrame);
      tic; [words,~,~,bbs]=wordSpot(I,lexS,fModel,wordSvm,[],{'minH',.04});
      toc;
      saveRes(sf,words,bbs);
    catch e
      e
    end
  end
end
end