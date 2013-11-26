%% This scripts run all the top level experiments
plex_icdar_video();

%% load gts
configs=configsgen;
gtpath = fullfile(configs.icdar_video,'test','gt');
blpath = fullfile(configs.icdar_video,'test','baseline');
tspath = fullfile(configs.icdar_video,'test','textspotter');
xmls = dir(fullfile(gtpath,'*.xml'));
gts = cell(length(xmls),1);
bls = cell(length(xmls),1);
for i=1:length(xmls)
  xmlpath = fullfile(gtpath,xmls(i).name);
  gts{i} = loadGT(xmlpath);
  bls{i} = loadDT(blpath);
end

%% Get ATA icdar_video baseline
xmls = filf
%% Get ATA icdar_video textspotter
