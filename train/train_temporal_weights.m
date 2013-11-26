function model=train_temporal_weights(training_folder)
    configs=globals;
    ground_truth_paths = configs.ground_truth_paths;
    training_files = dir(fullfile(training_folder,'*.mat'));
    
    N = 5;
    
    %limit = length(ground_truths);
    
    limit = 10;
    total_features = zeros(1e5,N*2);
    total_labels = zeros(1e5,1);
    current_count = 0;
    for i=6:limit
        file_name = training_files(i).name;
        disp(file_name);
        load(fullfile(ground_truth_paths,file_name));
        load(fullfile(training_folder,file_name));

        %features = [1 2 3 4 1 2 3 4 1 1; 1 2 3 4 1 2 3 4 1 1;];
        %labels = [1 1];
        
        [features,labels] = extract_temporal_features(predictions,gt_mat,N);
        
        current_size = length(labels);
        
        total_features(current_count+1:current_count+current_size,:) = features;
        total_labels(current_count+1:current_count+current_size,:) = labels;
        current_count = current_count + current_size;
    end
    
    total_features = total_features(1:current_count,:);
    total_labels = total_labels(1:current_count);
    
    model = train(total_labels, sparse(double(total_features)), '-s 2 -e 0.0001 -c 3 -q');
end