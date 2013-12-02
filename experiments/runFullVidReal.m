function runFullVidReal(indeces)
% It is generating the bounding boxes for the frames
configs=configsgen;
models = loadModels('models');
vidPath = fullfile(configs.icdar_video,'test','videos','mp4');
vidps = dir(fullfile(vidPath,'*.mp4'));

if ~exist('indeces','var'); indeces=1:length(vidps); end

% Getting the hms first
for iVid = indeces
  vpath = fullfile(vidPath,vidps(iVid).name);
  fprintf('Extracting hms from %s\n',vpath);
  done = false;
  while ~done;
    vidobject = VideoReader(vpath);
    if vidobject.NumberOfFrames > 0; done = true; end
  end
  charDetVideo('gethm',vidobject,models);
end

% Then get the bbs
for iVid = indeces
  vpath = fullfile(vidPath,vidps(iVid).name);
  fprintf('Getting bbs on %s\n',vpath);
  while ~done;
    vidobject = VideoReader(vpath);
    if vidobject.NumberOfFrames > 0; done = true; end
  end
  charDetVideo('getbbs',vidobject,models);
end
end
