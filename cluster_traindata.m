function idx = cluster_traindata(features,K)
    [U, ~] = princomp(features);
    d = 100;
    rotated = features*U;
    rotated = rotated(:,1:d);
    [ idx, ~, ~ ] = kmeans2( rotated, K);
end