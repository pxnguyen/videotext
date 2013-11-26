function idx = cluster_traindata(features,K)
    [U,mu,~] = pca(features');
    d=100;
    [~, Xhat, ~] = pcaApply(features', U, mu, K );
    Xhat = Xhat';
    rotated = Xhat(:,1:d);
    [ idx, ~, ~ ] = kmeans2( rotated, K);
end