%Loose code to make a video demonstration of DKL or MB space


%%

angle1 = 270;
angle2 = 90;


stimuli1 = load(strcat('fMRI_stimuli_DKL_6deg/T',num2str(angle1),'O90STgrey.mat'));
stimuli1 = stimuli1.stimuli;

stimuli2 = load(strcat('fMRI_stimuli_DKL_6deg/T',num2str(angle2),'O90STgrey.mat'));
stimuli2 = stimuli2.stimuli;

mov2 = VideoWriter(strcat('1trajectory',num2str(angle1),'to',num2str(angle2),'.avi'));
mov2.FrameRate = 120;

open(mov2);
for i = 1:size(stimuli1,1)
    writeVideo(mov2,im2frame(squeeze(stimuli1(i,:,:,:)./255)))
end

%back to gray
for i = size(stimuli1,1):-1:1
    writeVideo(mov2,im2frame(squeeze(stimuli1(i,:,:,:)./255)))
end

for i = 1:size(stimuli2,1)
    writeVideo(mov2,im2frame(squeeze(stimuli2(i,:,:,:)./255)))
end

%back to gray
for i = size(stimuli2,1):-1:1
    writeVideo(mov2,im2frame(squeeze(stimuli2(i,:,:,:)./255)))
end

close(mov2)





for angle = 0:15:345
    mov2 = VideoWriter(strcat(num2str(angle),'deg.avi'));
    mov2.FrameRate = 120;
    open(mov2);

    stimuli1 = load(strcat('fMRI_stimuli_DKL_6deg/T',num2str(angle),'O90STgrey.mat'));
    stimuli1 = stimuli1.stimuli;
    
    for i = 1:size(stimuli1,1)
        writeVideo(mov2,im2frame(squeeze(stimuli1(i,:,:,:))./255))
    end
    
    %back to gray
    for i = size(stimuli1,1):-1:1
        writeVideo(mov2,im2frame(squeeze(stimuli1(i,:,:,:))./255))
    end
    close(mov2)

end


%% 
luminances = 0:.01:1;

count = 0;
mov = VideoWriter('MBmovie2.avi');
open(mov);


for luminance = luminances
    count = count+1;
    MakeMBspace(luminance,'cemnl')
    F=getframe(gca);
    for i=1:2
        writeVideo(mov,F);
    end
end

close all
close(mov);
