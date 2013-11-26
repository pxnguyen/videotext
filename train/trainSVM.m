%% Reading images
configs = globals;
train_dir = fullfile(configs.data_base,'ICDAR','Processed');

cHogFtr=@(I)reshape((5*hog(single(imResample(I,configs.char_dims)),...
    configs.bin_size,configs.n_orients)),[],1);

% check if features already extracted
if (exist('built_features.mat','file'))
    load('built_features');
else  
    % load images
    %features_test=fevalArrays(images_test,cHogFtr)';

%         save('built_features','features_train','features_test',...
%             'labels_train','labels_test','order')
end

disp('Reading images');
[images,labels] = readAllImgs(train_dir,configs.classes);

%% extract features
disp('Extracting features')
features=fevalArrays(images,cHogFtr)';

number_of_examples = size(features,1);
cutoff = floor(.8*number_of_examples);
order = randperm(number_of_examples);
features_train = features(order(1:cutoff),:);
features_test = features(order(cutoff+1:end),:);
labels_train = labels(order(1:cutoff));
labels_test = labels(order(cutoff+1:end));

%% Possibly do something regarding reduce the dimension of the feature vectors.
% Use random projection or PCA
% Train the SVM and crossvalidation, model selections

%% Find best model
disp('Training SVM');
sizes = [17000];
training_acc = zeros(length(sizes),1);
test_acc = zeros(length(sizes),1);
for i=1:length(sizes)
    current_size = sizes(i);
    model = train(labels_train(1:current_size,:), sparse(double(features_train(1:current_size,:))), '-s 2 -e 0.0001 -c .2 -q');

    disp('Training accuracy');
    [predicted_label,accuracy, score] = predict(labels_train(1:current_size,:), sparse(double(features_train(1:current_size,:))), model);
    training_acc(i) = accuracy(1);
    disp('Testing accuracy');
    [predicted_label,accuracy, score] = predict(labels_test, sparse(double(features_test)), model);
    test_acc(i) = accuracy(1);
end

figure(1);
plot(sizes,training_acc); hold on;
plot(sizes,test_acc,'r');
legend('Training','Cross-validation');
xlabel('Training examples');
ylabel('Accuracy');
save('svm_model_liblinear','model');