function [f,x,y,i]=fscore2(xs,ys,beta)
% Compute F-score using beta so the 
%
% USAGE
%  [f,x,y,i]=Fscore( xs, ys )
%
% INPUTS
%  xs     - precision
%  ys     - recall
%  beta   - weight factor, 2 favors recall, 1 fair, .5 favors precision
%
% OUTPUTS
%  f      - fscore
%  x      - precision at best fscore
%  y      - recall at best fscore
%  i      - index of best fscore
%
% CREDITS
%  Written and maintained by Kai Wang and Boris Babenko
%  Copyright notice: license.txt
%  Changelog: changelog.txt
%  Please email kaw006@cs.ucsd.edu if you have questions.

fs=(1+beta^2)*(xs.*ys)./(beta^2*ys+xs);
[f,i]=max(fs); x=xs(i); y=ys(i);