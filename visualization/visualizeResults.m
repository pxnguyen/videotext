function total_images=visualizeResults(filename,frames,frames_smooth,indeces)
    configs=globals;
    extracted_frames = configs.extracted_frames;
    segments = regexp(filename,'\.','split');
    video_name = sprintf('%s.%s',segments{1},segments{2});
    path_to_frame_folder = fullfile(extracted_frames,video_name);

    max_frame = length(indeces);

    % Run the detection on this frame
    total_images = zeros(405,720,3,max_frame);
    total_images_s = zeros(405,720,3,max_frame);
    current_count = 0;
    for frame_index=indeces
        frame_index
        first_index = floor(frame_index/1000);
        second_index = floor(frame_index/100);
        path_to_frame = fullfile(path_to_frame_folder,...
                         int2str(first_index),int2str(second_index),sprintf('%d.jpg',frame_index));
        I = imread(path_to_frame);
        Is = imread(path_to_frame);

        bbs = frames{frame_index+1};
        bbs_smooth = frames_smooth{frame_index+1};
        if ~isempty(bbs)
            I = bbApply('embed',I,bbs);
            Is = bbApply('embed',Is,bbs_smooth);
        end
        
        total_images(:,:,:,current_count+1) = I;
        total_images_s(:,:,:,current_count+1) = Is;
        
        current_count = current_count + 1;
    end
    
    figure(1); montage(uint8(total_images),'Size',[1,max_frame]);
    figure(2); montage(uint8(total_images_s),'Size',[1,max_frame]);
end
