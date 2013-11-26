%% Setting up
configs = globals;
load svm_model_liblinear;
train_dir = fullfile(configs.data_base,'ICDAR','Processed');

cHogFtr=@(I)reshape((5*hog(single(imResample(I,configs.char_dims)),...
    configs.bin_size,configs.n_orients)),[],1);

disp('Reading images');
files = dir(fullfile(configs.data_base,'ICDAR','RandomFlickr','*.jpg'))
for i=50:60
    figure(i)
    filepath = fullfile(configs.data_base,'ICDAR','RandomFlickr',files(i).name)
    disp('Detecting text');
    I = imread(filepath);
    bbs = detecttext(I,model,true);
    [patches,~] = bbApply('crop',I,bbs);
    
    [sr,sc,~] = size(patches{1});
    patch_stack = zeros(sr,sc,3,length(patches));
    base = length(dir(fullfile(configs.data_base,'ICDAR','Processed','nontext','*.png')));
    for j=1:length(patches)
        if bbs(j,5) > 4
            image = patches{j};
            image = imResample(image,configs.char_dims);
            fpath = fullfile(configs.data_base,'ICDAR','Processed','nontext',sprintf('I%05d.png',j+base-1));
            imwrite(image,fpath)
        end
    end
end

%[images,labels] = readAllImgs(train_dir,{'morenontext'});

%% Extracting features
disp('Extracting features');
features=fevalArrays(images,cHogFtr)';

disp('Classification')
[predicted_label,accuracy, prob] = svmpredict(labels, double(features), model, '-b 1');

disp('Getting false positives')
false_positives = (predicted_label ~= labels);

disp('Writing to false positive');
images = images(:,:,:,false_positives);

base = length(dir(fullfile(configs.data_base,'ICDAR','Processed','morenontext2','*.png')));

% Write the hard negatives
for i=1:size(images,4)
    i
    fpath = fullfile(configs.data_base,'ICDAR','Processed','morenontext2',sprintf('I%05d.png',i+base));
    imwrite(images(:,:,:,i),fpath);
end

%% Combining nontext and hard negatives
% read all images from hard negatives
hardnegs = dir(fullfile(configs.data_base,'ICDAR','Processed','hardnegatives','*.png'));
for i=1:length(hardnegs)
end
%% Train the new classifiers