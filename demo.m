
% This demo script runs the IBCCF on the specified videos.

% Add paths
setup_paths();

% Load video information
video_path = './sequences/Bird2/';

[seq, ground_truth] = load_video_info(video_path);

% Run IBCCF
results = run_IBCCF(seq);