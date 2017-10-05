function [wf, alphaf, Xf] = ADMM(X, zeta, scale_factor, yf, G, P, S, common_region_sz, feat_size_border, opts, flag)

% Read the default parameters 
mu = opts.mu;
lambda = opts.lambda;

% Set the ADMM parameters
iter = 1;
max_iteration = 2;

filter_sz = size(X);
S_full = zeros(filter_sz);

% Obtain the crop range of the common regions
[crop_range_h, crop_range_w] = get_common_region(filter_sz(1:2), feat_size_border, common_region_sz, flag);
   
if flag == 0
    S_full = [];
    tmp = zeros(filter_sz);    
    for i = 1: size(feat_size_border,2)
        tmp(crop_range_h, crop_range_w,:) = reshape(S{i}, numel(crop_range_h), numel(crop_range_w),[]);
    end
    S_full = [S_full, tmp(:)];
else
    feat_size = feat_size_border(flag);
    S_full = reshape_features(S_full, feat_size{1}, opts.reshape_mode{flag}, '1Dto2D');
    S_full(crop_range_h, crop_range_w,:) = S;
    S_full = S_full(:);
end

% Pre-compute the Sig
[U,Sigma, ~] = svd(S_full,0);

while (iter <= max_iteration)
    
    zeta = min(100, scale_factor * zeta);
    [W,alphaf, Xf] = argmin_f(X, zeta, lambda, yf, G, P);

    % reshape to 2D
    if(flag >0)
        feat_size = feat_size_border(flag);
        W_2D = reshape_features(W, feat_size{1}, opts.reshape_mode{flag}, '1Dto2D');
        P_2D = reshape_features(P, feat_size{1}, opts.reshape_mode{flag}, '1Dto2D');   
        G_2D = argmin_g(U, Sigma, mu, zeta, W_2D, P_2D);
        G_2D = reshape(G_2D, size(W_2D));
        G = reshape_features(G_2D, feat_size{1}, opts.reshape_mode{flag}, '2Dto1D');      
    else
        G = argmin_g(U, Sigma, mu, zeta, W, P);
        G = reshape(G, size(W));
    end
    
    P = P + (G - W);
    iter = iter+1;
end

wf = fft2(W);