function model=trainClassifier(features,labels)
    % For every folder in Processed, train a seperate classifier
    % TODO: need to sweep for C in the training phase
    configs = globals;
    cHogFtr=@(I)reshape((5*hog(single(imResample(I,configs.char_dims)),...
        configs.bin_size,configs.n_orients)),[],1);
    
    disp('Reading images');
    
    disp('Extracting features');
    features = fevalArrays(images,cHogFtr)';
    
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
    model = train(labels_train, sparse(double(features_train)), '-s 2 -e 0.0001 -c 3 -q');

    disp('Training accuracy');
    [predicted_label,accuracy, score] = predict(labels_train, sparse(double(features_train)), model);
    disp('Testing accuracy');
    [predicted_label,accuracy, score] = predict(labels_test, sparse(double(features_test)), model);
end