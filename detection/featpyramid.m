function pyramid=featpyramid(I,configs,varargin)
dfs={'ss',2^(1/4),'minH',.04,'maxH',1,'thr',-75};
[ss,minH,maxH,~] = getPrmDflt(varargin,dfs,1);
sz=[configs.canonical_scale(1),configs.canonical_scale(2)];
hImg=size(I,1);
wImg=size(I,2);
minHP=minH*min(hImg,wImg);
maxHP=maxH*min(hImg,wImg);
sStart=ceil(max(log(sz(1)/maxHP),log(sz(2)/wImg))/log(ss));
sEnd=floor(log(sz(1)/minHP)/log(ss));
pyramid.feat = cell(sEnd-sStart+1,1);
pyramid.scales = ss.^(sStart:sEnd);
level = 1;
for s=sStart:sEnd, r=ss^s;
    if(s==0), I1=I;
    else I1=imResample(I,[round(hImg*r),round(wImg*r)]);
    end
    hogI = 5*hog(single(I1),configs.bin_size,configs.n_orients);
    pyramid.feat{level} = hogI;
    level = level + 1;
end
end