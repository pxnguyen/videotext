function model=trainChar(features,labels,char_name,char_dims,configs)
% This function train a character model
%   Inputs:
%       features: [NxD] array
%       labels: [NxD]
%   Output:
%       model: the trained model
%
testI = imread(fullfile(configs.svt_char,'svt-word','03_01_3.png'));
limit = 200;
debug = true;

nothing_list = zeros(600,1);
cHogFtr=@(I)reshape((5*hog(single(imResample(I,char_dims)),...
    configs.bin_size,configs.n_orients)),[],1);

iteration = 1;
disp('Training the first iteration');
model = train(labels, sparse(double(features)), '-s 2 -e 0.001 -c 3 -q');
model.char_dims = char_dims;
model.char_index = strfind(configs.alphabets,char_name);

shouldBreak = false;
while iteration <= configs.num_datamine_char
    fprintf('Data mining - Iteration %d\n',iteration);

    if debug
        bbs1=detect(testI,{model},0);
        bbs1 = bbs1(bbs1(:,3) > 10,:);
        figure(10); subplot(2,5,mod(iteration-1,10)+1);
        imshow(testI); bbApply('draw',bbs1(:,1:4));
        drawnow;
    end

    % Performing hard negative finding
    indeces = floor(rand(200,1)*600)+1;
    fprintf('Mining negatives - Phase %d...\n',iteration);
    [hard_negative_patches,no_detection,isFull] = mine_negative(model,indeces,limit,nothing_list);
    nothing_list(no_detection==1)=1;

    if(size(hard_negative_patches,4)==0)
        break;
    end

    new_features=fevalArrays(hard_negative_patches,cHogFtr)';
    features=cat(1,features,new_features);
    twos=ones(size(new_features,1),1)+1; labels=cat(1,labels, twos);

    fprintf('Retraining\n');
    model=train(labels,sparse(double(features)), '-s 2 -e 0.0001 -c 3 -q'); model.char_dims = char_dims;
    model.char_index = strfind(configs.alphabets,char_name);

    if (shouldBreak && ~isFull); break; end
    if (~isFull); shouldBreak = true; end

    iteration = iteration + 1;
end
end
