function [pos, max_confidence] = predict_position_CCF(feat, pos, feature_sz, model_xf, model_alphaf, current_scale_factor, opts)
% Predict the initialized position of the target with the learned 2D center CFs

% Read the default parameters
nweights = opts.nweights;
cell_size = opts.cell_size;
layers = opts.indLayers;

% ================================================================================
% Compute correlation filter responses at each layer
% ================================================================================
res_layer = zeros([feature_sz, length(layers)]);
for ii = 1 : length(layers)
    zf = fft2(feat{ii});
    kzf = sum(zf .* conj(model_xf{ii}), 3) / numel(zf);
    res_layer(:,:,ii) = real(fftshift(ifft2(model_alphaf{ii} .* kzf)));  %equation for fast detection
end

% Combine responses from multiple layers
nweights = reshape(nweights, [1 1 length(layers)]);
response = sum(bsxfun(@times, res_layer, nweights), 3) / sum(nweights(:));

% ================================================================================
% Find target location
% ================================================================================
% Target location is at the maximum response. we must take into
% account the fact that, if the target doesn't move, the peak
% will appear at the top-left corner, not at the center (this is
% discussed in the KCF paper). The responses wrap around cyclically.
max_confidence = max(response(:));
[vert_delta, horiz_delta] = find(response == max_confidence, 1);
vert_delta  = vert_delta  - floor(size(zf,1)/2);
horiz_delta = horiz_delta - floor(size(zf,2)/2);

% Map the position to the image space
pos_center = cell_size * [vert_delta - 1, horiz_delta - 1] .* current_scale_factor;
pos = pos + pos_center;
end
