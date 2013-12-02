% Get fscores and draw
configs=configsgen;
gtDir = fullfile(configs.icdar,'test','charAnn');
dtDirMix = fullfile(configs.icdar,'test','det_results_mix');
dtDirReal = fullfile(configs.icdar,'test','det_results_real');
fscores = zeros(length(configs.alphabets),2);
beta = 2;
for iChar = 1:length(configs.alphabets)
  try
    iChar
    currentChar = configs.alphabets(iChar);
    [gt0,~] = bbGt('loadAll',gtDir,[],{'lbls',currentChar});

    fprintf('Load synth\n');
    dtsynth = loadBB(dtDir,iChar);
    fprintf('Load real\n');
    dtreal = loadBB(dtDirReal,iChar);

    % Computing score for synth
    [gts,dts] = bbGt( 'evalRes', gt0, dtsynth);
    [xss,yss,~]=bbGt('compRoc', gts, dts, 0);
    fs = fscore2(xss,yss,beta);
    fscores(iChar,1) = fs;

    % Computing score for real
    [gtr,dtr] = bbGt( 'evalRes', gt0, dtreal);
    [xsr,ysr,~]=bbGt('compRoc', gtr, dtr, 0);
    fs = fscore2(xsr,ysr,beta);
    fscores(iChar,2) = fs;
  catch e
    e
    continue
  end
end