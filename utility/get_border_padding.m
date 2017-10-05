function border_padding = get_border_padding(target_sz, im_sz)
%GET_BORDER_PADDING 此处显示有关此函数的摘要
%   此处显示详细说明
if(prod(target_sz)/prod(im_sz(1:2)) > 0.05)
    border_padding.primary_horz = 1.2;
    border_padding.primary_vert = 1.2;
elseif(max(target_sz) / min(target_sz) >2)
    if(target_sz(1) > target_sz(2))
        border_padding.primary_horz = 2;
        border_padding.primary_vert = 1.2;
    else
        border_padding.primary_horz = 1.2;
        border_padding.primary_vert = 2;
    end
else
    border_padding.primary_horz = 1.5;
    border_padding.primary_vert = 1.5;
end

border_padding.secondary = 1.3;

end

