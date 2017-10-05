function [window_sz, padding_flag] = get_search_window( target_sz, im_sz, padding, padding_flag)
% GET_SEARCH_WINDOW


if(padding_flag == 1 || target_sz(1)/target_sz(2) > 2)
    % For objects with large height, we restrict the search window with padding.height
    window_sz = floor(target_sz.*[1+padding.height, 1+padding.generic]);
    padding_flag = 1;
elseif(padding_flag == 2 || prod(target_sz)/prod(im_sz(1:2)) > 0.05)
    % For objects with large height and width and accounting for at least 10 percent of the whole image,
    % we only search 2x height and width
    window_sz=floor(target_sz*(1+padding.large));
    padding_flag = 2;
else
    %otherwise, we use the padding configuration
    window_sz = floor(target_sz * (1 + padding.generic));
    padding_flag = 3;
end


end

