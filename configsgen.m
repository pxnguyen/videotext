function configs = configsgen

% YVT: Youtube Video Text
configs = struct();

[~,hostname] = system('hostname');
hostname = strtrim(hostname);

switch hostname
  case 'phuc-ThinkPad-T420'
        configs.data_base2 = '/home/phuc/Research/data/';
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
        configs.svt_char = '/home/phuc/Research/Dataset/SVT-CHAR/';
        configs.piotr_toolbox = '/home/phuc/Research/toolbox';
        configs.YVT_path = '/home/phuc/Research/data2/YVT';
    case 'deepthought'
        configs.piotr_toolbox = '/home/nguyenpx/code/toolbox';
        configs.YVT_path = '/home/nguyenpx/data2/YVT';
end

% character classification configurations
configs.canonical_scale = [100 80];
configs.alphabets = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

% Initial threshold to reject the "ridiculous" local boundingbox
% This is used in getbbs, the point of this is to speed up the process
% by not wasting time on really bad scored bounding box
configs.initThres = -1;

% Training parameters
configs.num_datamine_char = 5;
configs.bin_size = 8;
configs.n_orients= 8;
configs.OVERLAY_TYPE=1;
configs.SCENE_TYPE=2;
configs.BOTH=3;
configs.ALL=4;

configs.classes = {'pos','neg'};