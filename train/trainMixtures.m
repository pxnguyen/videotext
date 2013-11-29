function trainMixtures(chars)
configs=configsgen;
K=configs.nMixtures;

cHogFtr=@(I)reshape((5*hog(single(imResample(I,configs.canonical_scale)),...
    configs.bin_size,configs.n_orients)),[],1);
savemodel = @(sp,model) save(sp,'model');

for char_index=1:length(chars)
  class = chars(char_index);
  fprintf('Training char %s\n',class);
  prevTrained = dir(fullfile('mixture_models',sprintf('%s*',class)));
  if (length(prevTrained) == K); continue; end;

  % read the files and files
  fprintf('Loading positives\n');
  train_dir = fullfile(configs.synth_data,'train','charHard',class);
  imgs=imwrite2([],1,0,train_dir);

  % extract the features
  feats=fevalArrays(imgs,cHogFtr)';

  % cluster data into cluster
  idx=cluster_traindata(feats,K);
  
  % Get the negative
  fprintf('Loading negatives\n');
  negimgs = get_negative(class);
  negfeats=fevalArrays(negimgs,cHogFtr)';
  % debugging
  %for i=1:K
    %figure(i*10);group=imgs(:,:,:,idx==i); montage(uint8(group));
  %end
  
  % constructing featsmix, this helps running parallely
  featsmix = cell(K,1);
  for cluster_ind=1:K
    featsmix{cluster_ind} = feats(idx==cluster_ind,:);
  end
  
  % clear feats to free space;
  clear('feats')
  clear('negimgs')
  clear('imgs')

  % For each cluster, train a separate classifier
  parfor cluster_ind=1:K
    fprintf('Working on cluster %d\n',cluster_ind);
    cluster_feats=featsmix{cluster_ind};
    total_features=cat(1,cluster_feats,negfeats);
    lbls=[ones(size(cluster_feats,1),1);ones(size(negfeats,1),1)+1];
    model=train_cluster(total_features,lbls,class,configs);
    model_name = sprintf('%s_%d.mat',class,cluster_ind);
    model.name = model_name;
    savemodel(fullfile('mixture_models',model_name),model);
  end
end
end