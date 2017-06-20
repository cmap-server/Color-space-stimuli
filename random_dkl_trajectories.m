
dkl_space = MakeDKLspace(128,'cemnl',500);

angle1 = 0;
angle2 = 90;
traj_length = round(.5*size(dkl_space,1));
traj_length = traj_length - mod(traj_length,2);

traj_length = 240; %2 s on 120 hz display
dkl_radius = ceil(size(dkl_space,1)/2) - 1;

straight_dkl_traj = generate_straight_dkl_traj(dkl_space,dkl_radius,traj_length,angle1);
straight_sequence = permute(repmat(straight_dkl_traj,[1,1,100,100]),[1,3,4,2]);
split_dkl_traj = generate_split_dkl_traj(dkl_space,dkl_radius,traj_length/2,angle1,angle2);
split_sequence = permute(repmat(split_dkl_traj,[1,1,100,100]),[1,3,4,2]);

mov1 = VideoWriter(strcat('/Volumes/SANDISK/straight_traj'));
mov1.FrameRate = 120;

open(mov1);
for i = 1:traj_length
    writeVideo(mov1,im2frame(squeeze(straight_sequence(i,:,:,:))))
end

close(mov1)

mov2 = VideoWriter(strcat('/Volumes/SANDISK/split_traj'));
mov2.FrameRate = 120;

open(mov2);
for i = 1:traj_length
    writeVideo(mov2,im2frame(squeeze(split_sequence(i,:,:,:))))
end

close(mov2)


%% make a bunch of trajectories

trajectory_matrix = zeros(24,20,traj_length,3);
angle_num = 0;
for angle_change = 0:15:345
    angle_num = angle_num + 1;
    for repeat = 1:20
        angle1 = randi(360);
        if rand>.5
            angle2 = angle1 + angle_change;
        else
            angle2 = angle1 - angle_change;
        end
        split_dkl_traj = generate_split_dkl_traj(dkl_space,dkl_radius,traj_length/2,angle1,angle2);
        trajectory_matrix(angle_num,repeat,:,:) = split_dkl_traj;
    end
end




