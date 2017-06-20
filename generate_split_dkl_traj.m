
function dkl_traj_in_rgb = generate_split_dkl_traj(dkl_space,dkl_radius,half_traj_length,orientation_1,orientation_2)

found_full_trajectory = 0;
while found_full_trajectory == 0
    
    found_initial_trajectory = 0;
    while found_initial_trajectory == 0
        
        try_rad = randi(dkl_radius); try_theta = deg2rad(randi(360)); %pick a rand starting point
        [try_x, try_y] = pol2cart(try_theta,try_rad); %convert to cartesian
        [x_shift,y_shift] = pol2cart(deg2rad(orientation_1),half_traj_length);
        test_x = try_x + x_shift; test_y = try_y + y_shift;
        [test_theta,test_rad] = cart2pol(test_x,test_y);
        
        if abs(test_rad)<dkl_radius
            [x_shifts, y_shifts] = pol2cart(repmat(deg2rad(orientation_1),[half_traj_length,1])',0:half_traj_length-1);
            x_traj_pt1 = round(try_x + x_shifts); y_traj_pt1 = round(try_y + y_shifts);
            found_initial_trajectory = 1;
        end
        
    end
    
    [x_shift,y_shift] = pol2cart(deg2rad(orientation_2),half_traj_length);
    test_x = x_traj_pt1(end) + x_shift; test_y = y_traj_pt1(end) + y_shift;
    [test_theta,test_rad] = cart2pol(test_x,test_y);
    
    if abs(test_rad)<dkl_radius
        [x_shifts, y_shifts] = pol2cart(repmat(deg2rad(orientation_2),[half_traj_length,1])',1:half_traj_length);
        x_traj_pt2 = round(x_traj_pt1(end) + x_shifts); y_traj_pt2 = round(y_traj_pt1(end) + y_shifts);
        found_full_trajectory = 1;
    end    
        
end


dkl_traj_in_rgb = zeros(2*half_traj_length,3);

for ii = 1:half_traj_length
    dkl_traj_in_rgb(ii,:) = dkl_space(dkl_radius+y_traj_pt1(ii),dkl_radius+x_traj_pt1(ii),:);
end

for ii = 1:half_traj_length
    index = half_traj_length + ii;
    dkl_traj_in_rgb(index,:) = dkl_space(dkl_radius+y_traj_pt2(ii),dkl_radius+x_traj_pt2(ii),:);

end
end