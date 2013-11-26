function trainAll(chars)
    configs=globals;
    label_classes = configs.classes;
    cHogFtr=@(I)reshape((5*hog(single(imResample(I,configs.char_dims{1})),...
        configs.bin_size,configs.n_orients)),[],1);
    
    for char_index=1:length(chars)
        class = chars{char_index};
        alphabet_index = findstr(configs.alphabets,class);
        
        % read the files and files
        fprintf('Reading images...\n');
        train_dir = fullfile(configs.path_to_processedChars74k,class);
        [images,labels] = readAllImgs(train_dir,label_classes);
    
        % extract the features
        features = fevalArrays(images,cHogFtr)';
        
        model=train_cluster(features,labels,alphabet_index,configs);
        model.char_class = class;
        model_name = sprintf('%s.mat',class);

        fprintf('Saving %s...\n',model_name);
        model.name = model_name;
        model.char_index = alphabet_index;
        save(fullfile('models',model_name),'model');
    end
end
