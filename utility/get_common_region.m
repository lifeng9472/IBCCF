function [crop_range_h, crop_range_w] = get_common_region(feature_size, feat_size_border, common_region_sz, flag)
    if flag == 0 % center
        crop_range_h = [floor((feature_size(1) - common_region_sz(1))/2) + 1 : floor((feature_size(1) + common_region_sz(1))/2)];
        crop_range_w = [floor((feature_size(2) - common_region_sz(2))/2) + 1 :floor((feature_size(2) + common_region_sz(2))/2)];
    elseif flag == 1 % left
        crop_range_h = [floor((feat_size_border{1}(1) - common_region_sz(1))/2 + 1) : floor((feat_size_border{1}(1) + common_region_sz(1))/2)];
        crop_range_w = [feat_size_border{1}(2) - common_region_sz(2) + 1 : feat_size_border{1}(2)];
    elseif flag == 2 % right
        crop_range_h = [floor((feat_size_border{2}(1) - common_region_sz(1))/2 + 1) : floor((feat_size_border{2}(1) + common_region_sz(1))/2)];
        crop_range_w = [1: common_region_sz(2)];
    elseif flag == 3 % top
        crop_range_h = [feat_size_border{3}(1) - common_region_sz(1) + 1 : feat_size_border{3}(1)];
        crop_range_w = [floor((feat_size_border{3}(2) - common_region_sz(2))/2 + 1) : floor((feat_size_border{3}(2) + common_region_sz(2))/2)];
    elseif flag == 4 % down
        crop_range_h = [1:common_region_sz(1)];
        crop_range_w = [floor((feat_size_border{4}(2) - common_region_sz(2))/2 + 1) : floor((feat_size_border{4}(2) + common_region_sz(2))/2)];
    end
end

