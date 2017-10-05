function opts = init_params(opts)
% Set the default parameters for IBCCF method

% Set the CNN layers and response weights for both CCF and BCFs
opts.indLayers = [37, 28, 19];   % The CNN layers Conv5-4, Conv4-4, and Conv3-4 in VGG Net
opts.indLayers_border = [37, 28, 19];
opts.nweights  = [1, 0.5, 0.02]; % Weights for combining correlation filter responses
opts.nweights_border = [1, 1, 0];

% Initialize the parameters of CCF
opts.padding = struct('generic', 1.8, 'large', 1, 'height', 0.4); % Extra area surrounding the target for CCF (following the CF2 method)
opts.cell_size = 4; % Spatial cell size for CCF

% Initialize the parameters of BCFs
opts.delta = 0.8; % Reduce the search range of 1D response maps for large position shifts
opts.decay_ratio = 0.3; % Decrease the cosine window responses outside the target region (i.e., the context region)
opts.cell_size_border = 2; % Spatial cell size for BCFs

% Define the range of target scale changes during tracking
opts.min_scale_factor = 5;
opts.max_scale_factor = 5;

% Other parameters 
opts.mu = 1; % The orthogonality regularization parameter
opts.lambda = 1e-4; % Regularization parameter
opts.output_sigma_factor = 0.1; % Spatial bandwidth
opts.interp_factor = 0.01;  % Model learning rate
opts.update_time_stamp = 3; % The number of intermediate frames with no training
opts.max_init_value = 40; % the maximum initial value for ADMM algorithm
opts.scale_factor = 1.2;  % the scale factor for ADMM algorithm

% Enable or disable GPU
opts.enableGPU = true;

% Visualize the tracking or not
opts.show_visualization = true;
end