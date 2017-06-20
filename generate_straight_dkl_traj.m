
function dkl_traj_in_rgb = generate_straight_dkl_traj(dkl_space,dkl_radius,traj_length,orientation)

found_trajectory = 0;
while found_trajectory == 0
    
try_rad = randi(dkl_radius); try_theta = deg2rad(randi(360)); %pick a rand starting point
[try_x, try_y] = pol2cart(try_theta,try_rad); %convert to cartesian
[x_shift,y_shift] = pol2cart(deg2rad(orientation),traj_length);
test_x = try_x + x_shift; test_y = try_y + y_shift;
[test_theta,test_rad] = cart2pol(test_x,test_y);

if abs(test_rad)<dkl_radius
    [x_shifts, y_shifts] = pol2cart(repmat(deg2rad(orientation),[traj_length,1])',0:traj_length-1);
    x_traj = try_x + x_shifts; y_traj = try_y + y_shifts;
    found_trajectory = 1;
end

end

x_traj = round(x_traj); y_traj = round(y_traj);

dkl_traj_in_rgb = zeros(traj_length,3);
for ii = 1:traj_length
    dkl_traj_in_rgb(ii,:) = dkl_space(dkl_radius+y_traj(ii),dkl_radius+x_traj(ii),:);
end

end