function configs = configsgen

% YVT: Youtube Video Text
configs = struct();
[~,hostname] = system('hostname');
hostname = strtrim(hostname);

switch hostname
  case 'phuc-ThinkPad-T420'
    configs.RandomFlickr = '/home/phuc/Research/data/RandomFlickr';
    configs.data_base = '/home/phuc/Research/data/';
    configs.ground_truth_path = '/home/phuc/Research/videotext/matlab_code/ground_truth';
    configs.guesses_path = '/home/phuc/Research/videotext/matlab_code/guesses';
    configs.path_to_rawChars74k = fullfile(configs.data_base2,'Chars74k/raw/English/Img/GoodImg/Bmp/');
    configs.path_to_processedChars74k = fullfile(configs.data_base2,'Chars74k/Processed/');
    configs.path_to_generalnegative = fullfile(configs.data_base2,'Chars74k/general_negatives/');
    configs.root_model_folder = '/home/phuc/Research/videotext/matlab_code/root_model/';
    configs.ground_truth_paths = 'formatted_results';
    configs.testingset = '/home/phuc/Research/videotext/matlab_code/testing';
    configs.extracted_frames = '/home/phuc/Research/Samsung/vatic/extracted_frames';
    configs.videofolder = '/home/phuc/Research/Samsung/src/phase1accepts';
    configs.icdar_char = '/home/phuc/Research/data/ICDAR_char/';
    configs.svt_char = '/home/phuc/Research/data2/SVT-CHAR/';
    configs.piotr_toolbox = '/home/phuc/Research/toolbox';
    configs.libsvm = '/home/phuc/Research/libsvm-3.12';
    configs.ihog = '/home/phuc/Research/Research/ihog-master/';
    configs.clean_data = '/home/phuc/Research/videotext/matlab_code/chardet_traindata';
    configs.icdar = '/home/phuc/Research/data2/icdar/';
    configs.liblinear = '/home/phuc/Research/liblinear-1.92';

    % Training data
    configs.synth_data = '/home/phuc/Research/data2/synth';

    % Video dataset
    configs.YVT_path = '/home/phuc/Research/data2/YVT';
    configs.icdar_video = '/home/phuc/Research/data2/icdar_video';
  case 'deepthought'
    % toolbox
    configs.piotr_toolbox = '/home/nguyenpx/code/toolbox';
    configs.libsvm = '/home/nguyenpx/code/libsvm-3.17';
    configs.liblinear = '/home/nguyenpx/code/liblinear-1.92';
    
    % dataset
    configs.RandomFlickr = '/home/nguyenpx/data2/RandomFlickr';
    configs.YVT_path = '/home/nguyenpx/data2/YVT';
    configs.icdar_video = '/home/nguyenpx/data2/icdar_video';
    configs.synth_data = '/home/nguyenpx/data2/synth';
    configs.clean_data = '/home/nguyenpx/data2/chardet_traindata';
end

% character classification configurations
configs.canonical_scale = [100 100];
configs.alphabets = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

% character trainings
configs.nMixtures = 10;

% Initial threshold to reject the "ridiculous" local boundingbox
% This is used in getbbs, the point of this is to speed up the process
% by not wasting time on really bad scored bounding box
configs.initThres = -1;

% Training parameters
configs.num_datamine = 10;
configs.OVERLAY_TYPE=1;
configs.SCENE_TYPE=2;
configs.BOTH=3;
configs.ALL=4;

configs.bin_size = 8;
configs.n_orients= 8;

configs.classes = {'pos','neg'};

lstruct = load('data/related_matrix');
similar_classes = lstruct.related_matrix;
configs.similar_classes = similar_classes;