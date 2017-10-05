function [wf, alphaf, xf] = compute_2D_CF(feat, yf, lambda)
% computer the 2D correaltion filters 
    xf = fft2(feat);
    kf = sum(xf .* conj(xf), 3) / numel(xf);
    alphaf = yf./ (kf+ lambda);
    wf = bsxfun(@times, xf, alphaf);
end

