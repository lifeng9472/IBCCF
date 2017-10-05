function feat = extract_features_CCF(im, pos, searching_sz, cos_window, opts)
% Extract the CNN features for center CFs 


% Read the default parameters
global net
layers = opts.indLayers; 
enableGPU = opts.enableGPU;

if isempty(net)
   initial_net(opts);
end

% Get the search window from previous detection
im_patch = get_subwindow(im, pos, searching_sz);

% Preprocessing
img = single(im_patch);  % note: [0, 255] range
img = imResample(img, net.normalization.imageSize(1:2));
averageImg = net.normalization.averageImage;
img = img - averageImg;
if enableGPU, img = gpuArray(img); end
sz_window = size(cos_window);

% Run the CNN
res = vl_simplenn(net,img);

% Initialize feature maps
feat = cell(length(layers), 1);

%%
for ii = 1:length(layers)
    % Resize to sz_window
    if enableGPU
        x = gather(res(layers(ii)).x);    
    else
        x = res(layers(ii)).x;     
    end
    
    x = imResample(x, sz_window(1:2));
    
    % windowing technique
    if ~isempty(cos_window),
        x = bsxfun(@times, x, cos_window);
    end
    
    feat{ii}=x;
end

end
