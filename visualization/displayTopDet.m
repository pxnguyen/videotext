function displayTopDet(bbs,N,configs,dfNP)
    for char_index=1:length(configs.alphabets)
        char_index
        bbs_char = bbs(bbs(:,6)==char_index,:);
        bbs_char = bbNms(bbs_char,dfNP);
        [~,sortorder] = sort(bbs_char(:,5),'descend');
        td = min(N,size(bbs_char,1));
        bbs_char = bbs_char(sortorder(1:td),:);
        charDetDraw(bbs_char,configs.alphabets);
    end
end