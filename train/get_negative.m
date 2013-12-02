function negative_images=get_negative(char,dims)
% This function returns the list of negative images for the input chart
%
% INPUTS
%   char: the character of the positive class
%   dims: 1x2 array, dimensions to rescale the initial negatives
%
% OUTPUTS
%   negative_images: the negative images
configs=configsgen;
if( nargin < 3 || isempty(dims)); dims=configs.canonical_scale;
raw_dirs_path = configs.clean_data;
char_index = strfind(configs.alphabets,char);
sr = dims(1); sc = dims(2);

% data structure to return the negative images;
negative_images = zeros(sr,sc,3,5e3); total = 1;

% Find out classes are not similar to the current characters
excluded_set = configs.similar_classes(char_index,:)==0;
to_be_added = configs.alphabets(excluded_set);
for i=1:length(to_be_added)
    current_char = to_be_added(i);
    data_dir = fullfile(raw_dirs_path,current_char);
    files = dir(fullfile(data_dir,'*.jpg'));
    for file_index = 1:min(length(files),30)
        I = imread(fullfile(fullfile(data_dir,files(file_index).name)));
        negative_images(:,:,:,total) = imResample(I,[sr,sc]);
        total = total + 1;
    end
end

negative_images = negative_images(:,:,:,1:total-1);
end