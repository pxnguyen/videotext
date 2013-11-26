function bbs = loadDT(path)
% Read in an xml from the path and return the bbs
% INPUTS:
%   path: the path to the xml file
%
% OUTPUTS:
%   bbs: [Nx7] bounding boxes results
%
% NOTES:
%   Bounding box's format is [x,y.w,h,oid,frameid]
dnode = xmlread(path);
allListitems = dnode.getElementsByTagName('frame');
bbs = zeros(1e6,6); %[x,y,w,h,oid,frameid,quality]
total = 1;
for k = 0:allListitems.getLength-1
  item = allListitems.item(k);
  frameid = str2double(char(item.getAttribute('ID'))); % frrame i
  object_list = item.getElementsByTagName('object');
  for j = 0:object_list.getLength-1
    object = object_list.item(j);
    oid = str2double(char(object.getAttribute('ID')));
    points = object.getElementsByTagName('Point');
    minx=inf;miny=inf;maxx=0;maxy=0;
    for jj=0:points.getLength-1
      point=points.item(jj);
      x=str2double(char(point.getAttribute('x')));
      y=str2double(char(point.getAttribute('y')));
      minx = min(x,minx); miny = min(y,miny);
      maxx = max(x,maxx); maxy = max(y,maxy);
    end
    w = maxx-minx; h = maxy-miny;
    bbs(total,:) = [minx miny w h oid frameid];
    total = total + 1;
  end
end
bbs=bbs(1:total-1,:);
end