function target_sz = clamp_target_sz(target_sz, init_target_sz, min_scale_factor, max_scale_factor)
   max_target_sz = init_target_sz .* max_scale_factor;
   min_target_sz = init_target_sz ./ min_scale_factor;
   
   target_sz(1) = min((max(target_sz(1), min_target_sz(1))), max_target_sz(1));
   target_sz(2) = min((max(target_sz(2), min_target_sz(2))), max_target_sz(2));  
end

