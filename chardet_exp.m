function chardet_exp(models,test_dataset,output_path)
% This function aims to perform different experiments on the effectiveness
% of various character detection pipeline
%   models: the trained character models
%   test_dataset: the path to the test_dataset

image_paths = dir(fullfile(test_dataset,'*.jpg'));
nImg = length(image_paths);
ticId=ticStatus('Running PLEX on full images',1,30,1);
for i=1:nImg
    current_image = image_paths(i).name;
    I = imread(fullfile(test_dataset,current_image));
    t1S=tic; bbs=charDet(I,models,{}); t1=toc(t1S);

    % save the bbs
    sF = fullfile(output_path,current_image);
    save(sF,'bbs');
    tocStatus(ticId,i/nImg);
end
end
