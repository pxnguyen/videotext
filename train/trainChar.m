function trainChar(charName,saveDir,trainDims)
configs = configsgen;
if ~exist('trainDims','var'); trainDims = configs.canonical_scale; end;
fprintf('Training a model for the character %s\n',charName);
cHogFtr=@(I)reshape((5*hog(single(imResample(I,trainDims)),...
  configs.bin_size,configs.n_orients)),[],1);
  
fprintf('Loading positives\n');
train_dir = fullfile(configs.clean_data,charName);
posFiles = dir(fullfile(train_dir,'*.jpg'));
nFiles = length(posFiles);
posFeats = [];
for i=1:nFiles
  curPath = fullfile(train_dir,posFiles(i).name);
  I = imread(curPath);
  feat = cHogFtr(I);
  if isempty(posFeats)
    posFeats = zeros(nFiles,length(feat));
  end
  
  posFeats(i,:) = feat;
end
  
fprintf('Loading negatives\n');
negimgs = get_negative(charName);
negFeats=fevalArrays(negimgs,cHogFtr)';

totalFeats=cat(1,posFeats,negFeats);

lbls=[ones(size(posFeats,1),1);ones(size(negFeats,1),1)+1];
model=train_cluster(totalFeats,lbls,charName,configs,trainDims);
savePath = fullfile(saveDir,sprintf('%s.mat',charName));
save(savePath,'model');
end