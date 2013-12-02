function dt0 = loadBB(outputPath, charIndex)
% Helper funtion to load the bounding box
% TODO: need to put more information
%
% USAGE
%  dt0 = loadBB(outputPath,charIndex)
%
% INPUTS
%  outputPath       - class IDs
%  charIndex        - the index of the character you want to return
%  
% OUTPUTS
%  y1      - new class IDs
%  ch2     - new (equivalent) character classes
configs=configsgen;
[fs,~] = bbGt('getFiles', {outputPath});
dt0 = cell(length(fs),1);
parfor i=1:length(fs)
  lstruct = load(fs{i}); bbs = lstruct.bbs;

  % equivocate the class
  bbs(:,6)=equivClass(bbs(:,6),configs.alphabets);
  
  bbs = bbs(bbs(:,6)==charIndex,1:5);
  
  % take the top 100 if there are more than that
  if size(bbs,1) > 100
    [~,order] = sort(bbs(:,5),'descend');
    bbs = bbs(order(1:100),:);
  end
  
  % run nms
  bbs = bbNms(bbs,'type','max','overlap',.5,'separate',1);
  
  % only take the character of interest
  dt0{i} = bbs;
end
end