function reshaped_feat = reshape_features(feat, feat_size, reshape_mode, reshape_direction)

    if(strcmp(reshape_mode, 'horz'))
        if strcmp(reshape_direction, '2Dto1D')
            reshaped_feat = reshape(permute(feat,[2,1,3]), [1, size(feat,2), numel(feat) / size(feat,2)]);
        elseif(strcmp(reshape_direction, '1Dto2D'))
            reshaped_feat = permute(reshape(permute(feat, [2,1,3]), [feat_size(2), feat_size(1), numel(feat) / prod(feat_size)]), [2,1,3]);
        end
    else
        if strcmp(reshape_direction, '2Dto1D')
           reshaped_feat = reshape(feat, [size(feat,1), 1, numel(feat) / size(feat,1)]);
        elseif(strcmp(reshape_direction, '1Dto2D'))
           reshaped_feat = reshape(feat, [feat_size, numel(feat) / prod(feat_size)]);
        end
    end
end

