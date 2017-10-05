function boundary_shifts = predict_position_BCFs(feats, model_xf, model_alphaf, opts)
% Refine the position of each boundary with learned 1D Boundary CFs 

% ================================================================================
% Read the default parameters
% ================================================================================
indLayers = opts.indLayers_border;
nweights = opts.nweights_border;
cell_size = opts.cell_size_border;
feat_size = opts.feat_size_border;
delta = opts.delta;

% ================================================================================
% Compute correlation filter responses at each layer
% ================================================================================
% Intialize the variables
[responses, res_layers] = deal(cell(1,4));
[res_layers{1}, res_layers{2}] = deal(zeros(feat_size{1}(2),length(indLayers)));
[res_layers{3}, res_layers{4}] = deal(zeros(feat_size{3}(1),length(indLayers)));
boundary_shifts = zeros(1,4);

% Compute the response maps
for ii = 1 : length(indLayers)
    for i = 1 : numel(boundary_shifts)
        zf = fft2(feats{ii,i});
        kzf = sum(zf .* conj(model_xf{ii,i}), 3) / numel(zf);
        res_layers{i}(:,ii) = real(ifft2(model_alphaf{ii,i} .* kzf));
    end
end

% Combine responses from multiple layers
for i = 1 : numel(res_layers)
    responses{i} = fftshift(sum(bsxfun(@times, res_layers{i}, nweights), 2) / sum(nweights(:)));
end

% ================================================================================
% Find target location
% ================================================================================

% Define the searching range
res_length = [numel(responses{1}), numel(responses{3})];
search_lr_range = [(floor(((1 - delta) * res_length(1))/ 2) + 1) : (floor(((1 + delta) * res_length(1))/ 2))];
search_tb_range = [(floor(((1 - delta) * res_length(2))/ 2) + 1) : (floor(((1 + delta) * res_length(2))/ 2))];

if(isempty(search_lr_range))
    search_lr_range = floor(res_length(1) /2);
end
if(isempty(search_tb_range))
    search_tb_range = floor(res_length(2) /2);
end

% Compute the position shift for each boundary
delta_l = find(responses{1}(search_lr_range) == max(responses{1}(search_lr_range)), 1) + (search_lr_range(1) - 1);
boundary_shifts(1)  = delta_l  - floor(numel(responses{1})/2) - 1;
delta_r = find(responses{2}(search_lr_range) == max(responses{2}(search_lr_range)), 1) + (search_lr_range(1) - 1);
boundary_shifts(2)  = delta_r  - floor(numel(responses{2})/2) - 1;
delta_t = find(responses{3}(search_tb_range) == max(responses{3}(search_tb_range)), 1) + (search_tb_range(1) - 1);
boundary_shifts(3)  = delta_t  - floor(numel(responses{3})/2) - 1;
delta_b = find(responses{4}(search_tb_range) == max(responses{4}(search_tb_range)), 1) + (search_tb_range(1) - 1);
boundary_shifts(4)  = delta_b  - floor(numel(responses{4})/2) - 1;
boundary_shifts = boundary_shifts * cell_size;
end