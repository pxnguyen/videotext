function model=train_cluster(features,labels,char_class,configs)
limit = 200; num_datamine = 5; debug = false;
if debug
  testI = imread(fullfile(configs.extracted_frames,'7jjcAuEYW9M_0.mp4/0/0','72.jpg'));
  testI = imresize(testI,[405,720]);
end

nothing_list = zeros(600,1);
char_dims = configs.canonical_scale;
cHogFtr=@(I)reshape((5*hog(single(imResample(I,configs.canonical_scale)),...
  configs.bin_size,configs.n_orients)),[],1);

iteration = 1;
disp('Training the first iteration');
model = train(labels, sparse(double(features)), '-s 2 -e 0.001 -c 3 -q');
model.char_dims = char_dims;
model.char_index = char_class;
[predicted_label,~, scores] = predict(labels, sparse(double(features)), model);

shouldBreak = false;
while iteration <= num_datamine
  fprintf('Data mining - Iteration %d\n',iteration);

  % Here we are not removing
  %labels(easy_order) = []; features(easy_order,:) = []; % removing

  if debug
    negative_indeces = find(predicted_label==2);
    negative_scores = scores(negative_indeces);
    [~,easy_order] = sort(negative_scores,'ascend');
    easy_order = negative_indeces(easy_order);
    easy_order = easy_order(1:limit-100);
    bbs1=detect(testI,{model},0);
    figure(10); subplot(2,5,mod(iteration-1,10)+1);
    imshow(testI); bbApply('draw',bbs1(:,1:4));
  end

  % Performing hard negative finding
  indeces = floor(rand(200,1)*600)+1;
  fprintf('Mining negatives - Phase %d...\n',iteration);
  [hard_negative_patches,no_detection,isFull] = mine_negative(model,indeces,limit,nothing_list);
  nothing_list(no_detection==1)=1;

  if(size(hard_negative_patches,4)==0); break; end

  new_features=fevalArrays(hard_negative_patches,cHogFtr)';
  features=cat(1,features,new_features);
  twos=ones(size(new_features,1),1)+1; labels=cat(1,labels, twos);

  fprintf('Retraining\n');
  model=train(labels,sparse(double(features)), '-s 2 -e 0.0001 -c 3 -q'); model.char_dims = char_dims;
  [predicted_label,~, scores] = predict(labels, sparse(double(features)), model);
  model.char_index = char_class;

  if (shouldBreak && ~isFull); break; end
  if (~isFull); shouldBreak = true; end

  iteration = iteration + 1;
end
end