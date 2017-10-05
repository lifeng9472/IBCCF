function feats = extract_features_BCFs(im, pos, target_sz, opts)
% Extract the CNN features for boundary CFs 

% Read the default parameters
global net
enableGPU = opts.enableGPU;
layers = opts.indLayers_border;
padding = opts.padding_border;
feat_size = opts.feat_size_border;
cos_window = opts.cos_window_border;

if isempty(net)
   initial_net(opts);
end

% Initialize the variables
feats = cell(length(layers),4);
[image_patches, res_layers] = deal(cell(1,4));
boundary_pos = zeros(4,2);
% Localize the boundary positions
boundary_pos(1,:) =  pos - [0, target_sz(2)/2];
boundary_pos(2,:) =  pos + [0, target_sz(2)/2];
boundary_pos(3,:) =  pos - [target_sz(1)/2, 0];
boundary_pos(4,:) = pos + [target_sz(1)/2, 0];

% Get image patches
image_patches{1} = get_subwindow(im, boundary_pos(1,:), floor(target_sz .*[padding.secondary, padding.primary_horz]));
image_patches{2} = get_subwindow(im, boundary_pos(2,:), floor(target_sz .*[padding.secondary, padding.primary_horz]));
image_patches{3} = get_subwindow(im, boundary_pos(3,:), floor(target_sz .*[padding.primary_vert, padding.secondary]));
image_patches{4} = get_subwindow(im, boundary_pos(4,:), floor(target_sz .*[padding.primary_vert, padding.secondary]));

% Pre-process the image patches
image_patches = cellfun(@single, image_patches, 'UniformOutput', false);
patch_size = net.normalization.imageSize(1:2);
averageImg = net.normalization.averageImage;

for i  = 1: numel(image_patches)
    image_patches{i} = imResample(image_patches{i}, patch_size) - averageImg;
end
if enableGPU
 image_patches = cellfun(@gpuArray, image_patches, 'UniformOutput', false);   
end

% Forward the network
for i  = 1: numel(res_layers)
    res_layers{i} = vl_simplenn(net, image_patches{i});
end

% Post-Process the features
for ii = 1:length(layers)
    for i = 1:numel(res_layers)
       feats{ii,i} = gather(res_layers{i}(layers(ii)).x);
        
       feats{ii,i} = imResample(feats{ii,i}, feat_size{i});
       feats{ii,i} = reshape_features(feats{ii,i}, feat_size{i}, opts.reshape_mode{i}, '2Dto1D');
       feats{ii,i} = bsxfun(@times, feats{ii,i}, cos_window{i});
    end
end
end