function model=extractAndTrain(charname)
configs=configsgen;
fprintf('Extracing and training for %s\n',charname);
posf = fullfile(configs.clean_data,charname);
path_list = dir(fullfile(posf,'*.jpg'));
image_list = cell(length(path_list),1);
size_list = zeros(length(path_list),2);

fprintf('Extracting positives...');
%TODO: need to make this a function like get_positives
for image_index = 1:length(image_list)
    current_img_path = path_list(image_index).name;
    I = imread(fullfile(posf,current_img_path));
    [sr sc ~] = size(I);
    size_list(image_index,:) = [sr sc];
    image_list{image_index} = I;
end

% Determine the mean aspect ratios
mean_dims = floor(mean(size_list));
ar = mean_dims(1)/mean_dims(2);
canonical_dims = [80 80/ar];

fprintf('Done\n');
fprintf('Extracting negatives...');
neg_list = get_negative(charname,canonical_dims);
fprintf('Done\n');
fprintf('Done');
pos_feat = get_features(neg_list,canonical_dims);
neg_feat = get_features(image_list,canonical_dims);

pos_label = ones(size(pos_feat,1),1);
neg_label = ones(size(neg_feat,1),1)+1;

% concatenate them together
total_feat = [pos_feat; neg_feat];
labels = [pos_label; neg_label];

fprintf('Training...')
model = trainChar(total_feat,labels,charname,canonical_dims,configs);
fprintf('Done\n');
end
