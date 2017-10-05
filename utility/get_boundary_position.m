function boundary_position = get_boundary_position(position, target_sz)

% Return the position of each boundary given the target positon and size 
boundary_position(1) =  position(2) - floor(target_sz(2)/2);
boundary_position(2) =  position(2) + floor(target_sz(2)/2);
boundary_position(3) =  position(1) - floor(target_sz(1)/2);
boundary_position(4) =  position(1) + floor(target_sz(1)/2);

end

