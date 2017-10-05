% Tracker: Integrating Boundary and Center Correlation Filters for Visual Tracking with
% Aspect Ratio Variation
%
% Input:
%   - img_files:           list of image names
%   - pos:                 intialized center position of the target in (row, col)
%   - init_target_sz:           intialized target size in (Height, Width)
% Output:
%   - results:          return the tracking results and fps
%

function results = tracker(img_files, pos, init_target_sz)

% ================================================================================
% Environment setting
% ================================================================================
% read the default parameters from file
opts = [];
opts = init_params(opts);

% Get the CNN layers for both CCF and BCFs
indLayers = opts.indLayers ;
indLayers_border = opts.indLayers_border;

% Initialize the parameters of CCF
padding = opts.padding;
cell_size = opts.cell_size;

% Initialize the parameters of BCFs
decay_ratio = opts.decay_ratio;
cell_size_border = opts.cell_size_border;

% Get the range of target scale changes during tracking
min_scale_factor = opts.min_scale_factor;
max_scale_factor = opts.max_scale_factor;

% Other parameters 
output_sigma_factor = opts.output_sigma_factor;
show_visualization = opts.show_visualization;
video_path = [];

% Get the number of layers for CCF
numLayers = length(indLayers);
numLayers_border = length(indLayers_border);

% Get image size and search window size for CCF
im_sz = size(imread([video_path img_files{1}]));
[searching_sz, padding_strategy] = get_search_window(init_target_sz, im_sz, padding, -1);

% Get the padding method and search window size for BCFs
padding_border = get_border_padding(init_target_sz, im_sz);
searching_sz_horz = floor(init_target_sz .* [padding_border.secondary, padding_border.primary_horz]);
searching_sz_vert = floor(init_target_sz .* [padding_border.primary_vert, padding_border.secondary]);
opts.padding_border = padding_border;

% Compute the sigma for the Gaussian function label
output_sigma = sqrt(prod(init_target_sz)) * output_sigma_factor / cell_size;
output_sigma_horz = searching_sz_horz(2) * output_sigma_factor / cell_size_border;
output_sigma_vert = searching_sz_vert(1) * output_sigma_factor / cell_size_border;

% Compute the desired filter sizes
feature_sz = floor(searching_sz / cell_size);
feature_sz_horz = floor(searching_sz_horz / cell_size_border);
feature_sz_vert = floor(searching_sz_vert / cell_size_border);

% Compute the Fourier Transform of the Gaussian function label
yf = fft2(gaussian_shaped_labels(output_sigma, feature_sz,'center'));
yf_horz = fft(gaussian_shaped_labels(output_sigma_horz, feature_sz_horz(2),'horz'))';
yf_vert = fft(gaussian_shaped_labels(output_sigma_vert, feature_sz_vert(1),'vert'));

% Compute the cosine window (for avoiding boundary discontinuity)
cos_window = hann(size(yf,1)) * hann(size(yf,2))';
cos_window_horz = hann(size(yf_horz, 2))';
cos_window_vert =  hann(size(yf_vert, 1));

% Clip the boundary cosine windows to suppress the effects of context
% region
cos_window_horz(1:floor(size(yf_horz,2) / 2)) = cos_window_horz(1:floor(size(yf_horz, 2) / 2)) * decay_ratio;
cos_window_vert(1:floor(size(yf_vert,1) / 2)) = cos_window_vert(1:floor(size(yf_vert, 1) / 2)) * decay_ratio;

% Create video interface for visualization
if(show_visualization)
    update_visualization = show_video(img_files, video_path);
end

% Initialize the variables
positions = zeros(numel(img_files), 4);
boundary_positions = zeros(numel(img_files), 4);
boundary_positions(1,:) = get_boundary_position(pos, init_target_sz);

% Initialize the processing orders of the boundary features
opts.reshape_mode = [{'horz'},{'horz'},{'vert'},{'vert'}];
opts.feat_size_border = [{feature_sz_horz},{feature_sz_horz},{feature_sz_vert},{feature_sz_vert}];
opts.cos_window_border = [{cos_window_horz},{cos_window_horz(end:-1:1)},{cos_window_vert},{cos_window_vert(end:-1:1)}];
opts.yf_border = [{yf_horz},{yf_horz},{yf_vert},{yf_vert}];

% Note: variables ending with 'f' are in the Fourier domain.
[model_xf, model_alphaf] = deal(cell(numLayers, 1));
[model_xf_border, model_alphaf_border] = deal(cell(numLayers_border, 4));

% Initialize the target position, size and time
cur_pos = pos;
cur_target_sz = init_target_sz;
time = 0;
% ================================================================================
% Start tracking
% ================================================================================
for frame = 1:numel(img_files)
    opts.frame = frame;
    im = imread([video_path img_files{frame}]); % Load the image at the current frame
    if ismatrix(im)
        im = cat(3, im, im, im);
    end
    
    tic();
    % ================================================================================
    % Predict the object position from the learned CFs
    % ================================================================================
    if frame > 1
        % Estimate the intial positions of the target with the center CF
        
        % Extract the deep features
        feat = extract_features_CCF(im, cur_pos, searching_sz, cos_window, opts);
        % Predict the initial position in current frame
        [cur_pos, confidence_CCF] = predict_position_CCF(feat, cur_pos, feature_sz, model_xf, model_alphaf, cur_target_sz ./ init_target_sz ,opts);
        
        % Compute the initial positions for four boundaries in current frame
        boundary_positions(frame,:) = get_boundary_position(cur_pos, cur_target_sz);
        
        % Extract deep features for 1D boundary trackers
        feat_border  = extract_features_BCFs(im, cur_pos, cur_target_sz, opts);
        % Refine the boundary positions with 1D boundary trackers
        delta_border  = predict_position_BCFs(feat_border, model_xf_border, model_alphaf_border, opts);
        
        boundary_positions(frame, :) = boundary_positions(frame, :) + delta_border;
        
        % Clamp the boundaries
        boundary_positions(frame, :) = clamp_region(boundary_positions(frame, :), size(im));
        
        old_pos = cur_pos;
        old_target_sz = cur_target_sz;
        
        cur_pos = [(boundary_positions(frame, 3) + boundary_positions(frame, 4)), (boundary_positions(frame, 1) + boundary_positions(frame, 2)) ] / 2;
        cur_target_sz =  [(boundary_positions(frame, 4) - boundary_positions(frame, 3) + mod(cur_target_sz(1),2)),...
                            (boundary_positions(frame, 2) - boundary_positions(frame, 1) + mod(cur_target_sz(2),2))];

        % Clamp the target size
        cur_target_sz = clamp_target_sz(cur_target_sz, init_target_sz, min_scale_factor, max_scale_factor);
                        
        % Compare the tracking results between CCF and BCFs
        searching_sz = get_search_window(cur_target_sz, im_sz, padding, padding_strategy);
        feat = extract_features_CCF(im, cur_pos, searching_sz, cos_window, opts);
        [~, confidence_BCFs]  = predict_position_CCF(feat, cur_pos, feature_sz, model_xf, model_alphaf, cur_target_sz ./ init_target_sz, opts);
        
        if(confidence_BCFs < confidence_CCF)
            cur_target_sz = old_target_sz;
            cur_pos = old_pos;
        end
        
        % Clamp the target size again
        cur_target_sz = clamp_target_sz(cur_target_sz, init_target_sz, min_scale_factor, max_scale_factor);
    end
    
    % ================================================================================
    % Update the CF models with Alternating Direction Method of Multipliers (ADMM)
    % ================================================================================
    searching_sz = get_search_window(cur_target_sz, im_sz, padding, padding_strategy);
    feat = extract_features_CCF(im, cur_pos, searching_sz, cos_window, opts);
    feat_border  = extract_features_BCFs(im, cur_pos, cur_target_sz, opts);
    
    [model_xf, model_xf_border, model_alphaf, model_alphaf_border] = update_model(feat, feat_border,...
        yf, model_xf, model_xf_border, model_alphaf, model_alphaf_border, init_target_sz, opts);
    
    % ================================================================================
    % Save predicted position and time
    % ================================================================================
    positions(frame,:) = [cur_pos([2,1]) - cur_target_sz([2,1])/2, cur_target_sz([2,1])];    
    time = time + toc();
    
    % Visualization
    if show_visualization,
        box = [cur_pos([2,1]) - cur_target_sz([2,1])/2, cur_target_sz([2,1])];
        stop = update_visualization(frame, box);
        if stop, break, end  %user pressed Esc, stop early
        drawnow
    end
end
    results.type = 'rect';
    results.res = positions;
    results.fps = numel(img_files) / time;
end