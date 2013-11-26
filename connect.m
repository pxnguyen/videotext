function [bbs]=connect(results)
% Function to connect the per-frame detection to tracks
%
% INPUTS:
%   results: [Nx6] array, [x,y,w,h,score,frame]
%   words: [Nx1] cell array
% 
% OUTPUTS:
%   bbs: [Nx7] [x,y,w,h,score,id]
%   fwords: new filtered words to match with the filtered bbs

configs=configsgen;
nSearch = 5; % num of frames to search backward
maxFrame = max(unique(results(:,6)));
bbs = zeros(size(results,1),size(results,2)+1);
bbs(:,1:6) = results;
bbs(:,7) = -ones(size(bbs,1),1);
curid = 1;
for frame=1:maxFrame
  bbi = find(results(:,6)==frame); % index of bbs that is in the current frame
  if frame-nSearch <= 0
    farleft = 1;
  else
    farleft = frame-nSearch;
  end
  prev_bbi = find(results(:,6)==farleft);
  prev_bbs = bbs(min(prev_bbi):min(bbi)-1,:);
  for i=1:length(bbi)
    bb = bbs(bbi(i),:);
    [id,next_id] = search_backward(bb,prev_bbs,curid);
    curid = next_id;
    bbs(bbi(i),7) = id;
  end
end
end

function [id,next_id]=search_backward(bb,bbs,curid)
% Search backward and assign id
%
% INPUTS:
%   bb: [1x7] the current boundind box
%   bbs: [Nx7] the entire bounding box %TODO: could just pass the buffer
%   curid: [scalar] the current id
%
% OUTPUTS:
%   id: the id to assign to the current bb

% if there is no other bounding box, return the current id
id = -1;
next_id = curid;
if size(bbs,1) == 0
  id = curid;
  next_id = curid + 1;
  return
end

frames = unique(bbs(:,6));
votes = -ones(length(frames),1);
for i=1:length(frames)
  bbfr = bbs(bbs(:,6)==frames(i),:);
  overlaps = zeros(size(bbfr,1),1);
  for j=1:size(bbfr,1)
    bbj = bbfr(j,:);
    r = overlap(bb,bbj);
    overlaps(j) = r;
  end
  [mv,mi] = max(overlaps);
  if mv > .5
    votes(mi) = bbfr(mi,7);
  end
end
valid_votes = votes(votes>0);
if length(valid_votes) == 0
  id = curid;
  next_id = curid + 1;
  return
end
id = mode(valid_votes);
end

function r=overlap(a,b)
  u = bbApply('union',a,b);
  in = bbApply('intersect',a,b);
  r = bbApply('area',in)/bbApply('area',u);
end
















