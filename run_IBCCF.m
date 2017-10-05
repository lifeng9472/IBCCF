function results = run_IBCCF(seq, res_path, bSaveImage)

% run_IBCCF:
% process a sequence using IBCCF method
%
% Input:
%     - seq:        sequence name
%     - res_path:   result path
%     - bSaveImage: flag for saving images
% Output:
%     - results: tracking results, position prediction over time
%
%   It is provided for educational/research purpose only.
%
%   Integrating Boundary and Center Correlation Filters for Visual Tracking
%   with Aspect Ratio Variation
%   Feng Li, Yingjie Yao, Peihua Li, David Zhang, Wangmeng Zuo and Ming-Hsuan Yang
%   IEEE International Conference on Computer Vision, ICCV 2017 workshop
%
% Contact:
%   Feng Li (fengli_hit@hotmail.com).

% ================================================================================
% Environment setting
% ================================================================================
% Image file names
img_files = seq.s_frames;
% Seletected target size
target_sz = [seq.init_rect(1,4), seq.init_rect(1,3)];
% Initial target position
pos  = [seq.init_rect(1,2), seq.init_rect(1,1)] + floor(target_sz/2);

% ================================================================================
% Main entry function for visual tracking
% ================================================================================
results = tracker(img_files, pos, target_sz);

end

