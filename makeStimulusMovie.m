
%doesn't seem to work as function call, but the code itself works. unclear why. 

function makeStimulusMovie(stimuli,file_name)

mov2 = VideoWriter(strcat(file_name,'.avi'));
mov2.FrameRate = 120;

open(mov2);
for i = 1:size(stimuli,1)
    writeVideo(mov2,im2frame(squeeze(stimuli(i,:,:,:)./255)))
end

%back to gray
for i = size(stimuli,1):-1:1
    writeVideo(mov2,im2frame(squeeze(stimuli(i,:,:,:)./255)))
end
close(mov2)

end