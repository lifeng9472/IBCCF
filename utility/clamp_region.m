function region = clamp_region(region, image_size)
% image_size = [height width];
% region = [left right top bottom];
    region(region <1) = 1;
    region(region(1:2) > image_size(2)) = image_size(2);
    region(3) = min(region(3), image_size(1));
    region(4) = min(region(4), image_size(1));
end

