% This script runs all the experiments for the chardet_exp
[dPath,ch]=globals;
clfPath=fullfile('data','models_real_nomixture.mat');
fmodel=load(clfPath);
models = fmodel.models;
test_dataset = fullfile(dPath,'icdar','test','images');
output_path = fullfile(dPath,'icdar','test','det_results_real');

%% Actually running the SVM
image_paths = dir(fullfile(test_dataset,'*.jpg'));
nImg = length(image_paths);
%ticId=ticStatus('Running PLEX on full images',1,30,1);
saveRes=@(f,bbs)save(f,'bbs');
parfor i=1:nImg
    bbs = [];
    current_image = image_paths(i).name;
    fprintf('Working on index: %d, image: %s\n',i,current_image);
    sF = fullfile(output_path,[current_image '.mat']);
    if exist(sF,'file')
        continue
    end
    I = imread(fullfile(test_dataset,current_image));
    try
        bbs=charDetSVM(I,models,{});
    catch e
        fprintf('Error at index %d\n',i);
        continue
    end

    % save the bbs
    saveRes(sF,bbs);
    %tocStatus(ticId,i/nImg);
end


% %% Calculating the F-score for the characters
% gtDir = fullfile(dPath,'icdar','test','charAnn');
% fscores = zeros(length(ch),1);
% ticId=ticStatus('Collecting Fscore',1,30,1);
% for char_index = 1:length(ch)-1
%     [gt0,~] = bbGt('loadAll',gtDir,[],{'lbls',ch(char_index)});
%     dt0 = loadBB(output_path,char_index);
%     current_char = ch(char_index);
% 
%     % filter out the groundtruth
%     [gt,dt] = bbGt( 'evalRes', gt0, dt0);
%     [xs,ys,sc]=bbGt('compRoc', gt, dt, 0);
%     fs = Fscore(xs,ys);
%     fscores(char_index) = fs;
%     tocStatus(ticId,char_index/(length(ch)));
% end
