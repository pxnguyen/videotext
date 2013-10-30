function [hms,scales]=get_filter_responses(I,models,configs)
    filters = cell(length(models),1);
    % contructing the filters
    for i=1:length(models)
        model = models{i};
        char_dims = model.char_dims;
        r = floor(char_dims(1)/configs.bin_size);
        c = floor(char_dims(2)/configs.bin_size);
        filter = reshape(model.w,[r,c,configs.n_orients*4]);
        filters{i} = single(filter);
    end
    
    pyramid = featpyramid(I,configs);
    scales = pyramid.scales;
    hms = cell(length(pyramid.scales),1);
    for level=1:length(pyramid.scales)
        hogI = pyramid.feat{level};
        try
            r=fconv(hogI,filters,1,length(filters));
        catch
            r = {};
        end
            
        hms{level} = r;
    end
end