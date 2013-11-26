function [ model ] = trainRoot(debug)
%trainRoot Summary of this function goes here
%   This function takes care of training the filter for the root filter

configs=globals;
label_classes = configs.classes;

limit = 1500;
num_datamine = 15;

char_dims = configs.root_dims;
cHogFtr=@(I)reshape((5*hog(single(imResample(I,char_dims)),...
    configs.bin_size,configs.n_orients)),[],1);

class = 'root';

train_dir = fullfile(configs.path_to_processedChars74k,class);
[images,labels] = readAllImgs(train_dir,label_classes);

iteration = 1;

testingImage1 = imread('/home/phuc/Research/data/RandomFlickr/im1.jpg');
testingImage2 = imread('/home/phuc/Research/data/RandomFlickr/im109.jpg');
testingImage3 = imread('IMG_2533.JPG');

while iteration <= num_datamine
    disp('Training...');
    features = fevalArrays(images,cHogFtr)';
    model = train(labels, sparse(double(features)), '-s 2 -e 0.0001 -c 3 -q');
    model.char_dims = char_dims;
    [~,~, scores] = predict(labels, sparse(double(features)), model);

    % Removing 100 easy examples
    [~,order] = sort(scores,'ascend');

    negative_indeces = find(labels == 2);

    negative_scores = scores(negative_indeces);
    %[~,hard_order] = sort(negative_scores,'descend');
    [~,easy_order] = sort(negative_scores,'ascend');

    %hard_order = negative_indeces(hard_order);
    easy_order = negative_indeces(easy_order);
    %hard_order = hard_order(1:limit);
    easy_order = easy_order(1:limit);
    
    % Removing the pictures with the easy scores
    images(:,:,:,easy_order) = [];

    % debugging
    if debug
        bbs1=detect(testingImage1,{model},0);
        bbs2=detect(testingImage2,{model},0);
        bbs3=detect(testingImage3,{model},0);
        figure(10);
        subplot(3,5,iteration); imshow(testingImage1); bbApply('draw',bbs1(:,1:4));
        figure(11);
        subplot(3,5,iteration); imshow(testingImage2); bbApply('draw',bbs2(:,1:4));
        figure(12);
        subplot(3,5,iteration); imshow(testingImage3); bbApply('draw',bbs3(:,1:4));
    end

    labels(easy_order) = [];

    % Performing hard negative finding
    disp('Mining negatives - Phase 1...');

    indeces = floor(rand(400)*400)+1;

    % Pull new negatives
    hard_negative_patches = mine_negative(model,indeces,limit);

    labels = cat(1,labels, ones(limit,1)+1);
    images = cat(4,images,hard_negative_patches);
    iteration = iteration + 1;
end

% Save the model
model_name = sprintf('root_model');
fprintf('Saving %s...\n',model_name);
model.name = model_name;
save(model_name,'model');

end

