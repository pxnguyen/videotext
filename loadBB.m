function dt0 = loadBB(output_path,char_index)
    [fs,~] = bbGt('getFiles', {output_path});
    dt0 = cell(length(fs),1);
    for i=1:length(fs)
        lstruct = load(fs{i}); bbs = lstruct.bbs;
        dt0{i} = bbs(bbs(:,6)==char_index,1:5);
    end
end