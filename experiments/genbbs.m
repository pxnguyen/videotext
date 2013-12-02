function runFullVidReal(indeces)
% It is generating the bounding boxes for the frames
configs=configsgen;
models = loadModels('models');
avi_path = fullfile(configs.YVT_path,'videos','avi');
vidpaths = dir(fullfile(avi_path,'*.avi'));

if ~exist('indeces','var'); indeces=1:length(vidpaths); end

%% Getting the hms first
for iVid = indeces
  vpath = fullfile(avi_path,vidpaths(iVid).name);
  fprintf('Extracting hms from %s\n',vpath);
  vidobject = VideoReader(vpath);
  charDetVideo('gethm',vidobject,models);
end

%% Then get the bbs
for iVid = indeces
  vpath = fullfile(avi_path,vidpaths(iVid).name);
  fprintf('Getting bbs on %s\n',vpath);
  vidobject = VideoReader(vpath);
  charDetVideo('getbbs',vidobject,models);
end
end
