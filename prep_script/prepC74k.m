function prepC74k
% Process the raw files downloaded from C74k into a common format
% Download site,
%   http://www.ee.surrey.ac.uk/CVSSP/demos/chars74k/
%
% Move the English and Lists folder here,
%  [dPath]/c74k/raw/
% After moving, the folder should look like,
%  [dPath]/c74k/raw/Kannada/.
%  [dPath]/c74k/raw/Lists/.
%

configs=globals;
c74k_path = fullfile(configs.data_base, 'c74k','raw');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% process the IMG data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
img_list = load(fullfile(c74k_path, 'Lists','English','Img','lists.mat'));
list = img_list.list;
sz=100; padding=.5;
I=zeros(sz,sz,3,sum(list.is_good));
Ipd=zeros(sz,sz,3,sum(list.is_good));
img_base = fullfile(c74k_path,'English','Img');
img_paths = list.ALLnames(list.is_good,:);
img_labels = list.ALLlabels(list.is_good,:);
for i = 1:size(img_paths,1)
  I1 = imread(fullfile(img_base,[list.ALLnames(i,:),'.png']));
  
  % The commented out code instead 'squarifies' bounding in different
  % ways. This might be worth trying as an alternative to stretching.
  bb=[1 1 size(I1,2) size(I1,1)];
  bb=bbApply('squarify',bb,3,1);  
  P=bbApply('crop',I1,bb,'symmetric',[sz sz]); P=P{1};
  %P=imResample(I1,[sz,sz]);
  if(size(P,3)==1), P=cat(3,P,P,P); end
  I(:,:,:,i)=P;
end

% crappy way of converting number array to cell array of strings
all_classes = cell(max(img_labels),1);
for i = 1:max(img_labels), all_classes{i} = num2str(i); end

writeAllImgs(I,img_labels,all_classes,...
  fullfile(configs.data_base,'c74k','English','img','char'));