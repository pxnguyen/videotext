function plex_icdar_video
% this script is to run kai system out of the box on the icdar video system
configs=configsgen;
vidpath = fullfile(configs.icdar_video,'test','videos','mp4');
res_folder = fullfile(configs.icdar_video,'test','res');
lexicon_path = fullfile(configs.icdar_video,'test','lex');
vidps = dir(fullfile(vidpath,'*.mp4'));
saveRes=@(f,words,bbs)save(f,'words','bbs');

% Loading the character models
% Ferns + synthesis
clfPath=fullfile('data','fern_synth.mat');
fModel=load(clfPath);

svmPath=fullfile('data','svm_svt.mat');
model=load(svmPath); wordSvm=model.pNms1; wordSvm.thr=-1;
for vidindex = 1:length(vidps)
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
  if exist(fullfile(res_folder,name),'dir') == 0
    mkdir(fullfile(res_folder,name));
  end
  
  % read in the lexicons
  lexpath = fullfile(lexicon_path,[name '.xml.lex']);
  fid=fopen(lexpath,'r'); lexS=textscan(fid,'%s'); lexS=lexS{1}';
  allframes = read(vidobject);
  nFrame = size(allframes,4);
  for f_ind = 1:nFrame
    fprintf('%s: frame %d\n',name,f_ind);
    sf = fullfile(res_folder,name,sprintf('%d.mat',f_ind));
    if exist(sf,'file') > 0, continue; end;
    
    I = allframes(:,:,:,f_ind);
    
    % things that takes the most time
    [words,~,~,bbs]=wordSpot(I,lexS,fModel,wordSvm,[],{'minH',.04});
    
    % constructing the save path and save the final detections as well as
    % the bbs
    saveRes(sf,words,bbs);
  end
  
    
end
end