%Presents color navigation in a psychtoolbox script, defined by the input
%parameter stimuli
%Calls: Screen
%Called by: NavigateColorSpace
%Author: Nick Blauch
%Updated: 4/11/2016
%functional as of 3/14/17

function PTBNavigation(stimuli)
Screen('Preference', 'SkipSyncTests', 1)
ifis=1; %each coded frame lasts for 1 frame
%keyboard
device = -3;

rng('shuffle');
numRuns = 1;
doubleFirstColorRuns = 1;

try
    screens=Screen('Screens');
    screenNumber=max(screens);
    PsychDefaultSetup(2);
    
    % Open a double-buffered fullscreen window:
    window=Screen('OpenWindow',screenNumber);
    [width, height]=Screen('WindowSize', window);
    
    % Enable alpha blending with proper blend-function. We need it
    % for drawing of our alpha-mask (gaussian aperture):
    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    %Define white, black, and gray
    white=WhiteIndex(screenNumber);
    gray=white/2;
    black=BlackIndex(screenNumber);
    inc=white-gray;
    count = 0;
    
    %%
    % Query the real duration of a monitor refresh interval, gained through
    % some measurement during Screen('OpenWindow')...
    ifi_duration = Screen('GetFlipInterval', window);
    
    frameRate=Screen('FrameRate',screenNumber);
    if(frameRate==0) % if MacOSX does not know the frame rate the 'FrameRate' will return 0.
        frameRate=60; % 60 Hz is a good guess for flat-panels...
    end
    % Switch to realtime:
    if strcmp(computer,'MACI64')
        Priority(9);
    else
        priorityLevel=MaxPriority(window);
        Priority(priorityLevel);
    end
    % Prepare screen for animation:
    % Draw gray full-screen rectangle to clear to a defined
    % background color:
    Screen('FillRect',window, gray);
    Screen('TextSize', window, 60);
    str0 =' Welcome to the experiment';
    str1 = '\n Press any key to continue';
    DrawFormattedText(window, [str0 str1],'center','center', black);
    Screen('Flip', window);
    KbStrokeWait(device);
    
    Screen('FillRect',window, gray);
    Screen('TextSize', window, 30);
    str1 ='You will be asked to rate the similarity of a series of color pairs.';
    str2 ='\n In each trial, there will be a visual stimulus, called a gabor patch, with alternating black and colored stripes.';
    str3 ='\n Each trial contains a very short movie where the colored stripes change color.';
    str4 = '\n The colored stripes will begin at gray and then saturate to a color. They will then return to gray.';
    str5 ='\n The stripes will then saturate to a second color, and again return to gray.';
    str6 ='\n Finally, the stripes will again saturate to the first color, and again return to gray';
    str7 ='\n After the movie finishes, you will be asked to rate the similarity of the two colors you saw.';
    str8 ='\n In this scale, 1 is most similar and 7 is least similar.';
    str9 ='\n Here is a demonstration (press any key to continue)';
    
    DrawFormattedText(window, [str1 str2 str3 str4 str5 str6 str7 str8 str9],'center','center', black);
    Screen('Flip', window);
    KbStrokeWait(device);
    %%
    %Draw Textures
    %Pause for 1 second at the grey point
    for j = 1:120
        count = count+1;
        tex(count) = Screen('MakeTexture', window, squeeze(stimuli(1,:,:,:)));
    end
    %navigations
    for j = 1:numRuns
        %out to first color
        for i = 1:size(stimuli,1)/2
            count = count+1;
            tex(count) = Screen('MakeTexture', window, squeeze(stimuli(i,:,:,:)));
        end
        %back to gray
        for i = linspace(size(stimuli,1)/2,1,size(stimuli,1)/2)
            count = count+1;
            tex(count) = Screen('MakeTexture', window, squeeze(stimuli(i,:,:,:)));
        end
        %out to second color
        for i = size(stimuli,1)/2+1:size(stimuli,1)
            count = count+1;
            tex(count) = Screen('MakeTexture', window, squeeze(stimuli(i,:,:,:)));
        end
        %back to gray
        for i = linspace(size(stimuli,1),size(stimuli,1)/2+1,size(stimuli,1)/2);
            count = count+1;
            tex(count) = Screen('MakeTexture', window, squeeze(stimuli(i,:,:,:)));
        end
        
        if doubleFirstColorRuns
            %out to first color
            for i = 1:size(stimuli,1)/2
                count = count+1;
                tex(count) = Screen('MakeTexture', window, squeeze(stimuli(i,:,:,:)));
            end
            %back to gray
            for i = linspace(size(stimuli,1)/2,1,size(stimuli,1)/2)
                count = count+1;
                tex(count) = Screen('MakeTexture', window, squeeze(stimuli(i,:,:,:)));
            end
        end
    end
    numFrames = length(tex);
    % Show the gray background, return timestamp of flip in 'vbl'
    vbl = Screen('Flip', window);
    %%
    % Color navigation demo
    for i=1:length(tex)
        t1=GetSecs;
        % Draw grating for current frame:
        Screen('DrawTexture', window, tex(i), [], []);
        
        % Show result on screen: We only want to show a new frame every
        % ifis monitor refresh intervals. Therefore we calculate a proper
        % presentation time that is '(ifis - 0.5) * ifi_duration' after the
        % time 'vbl' when the previous frame was shown.
        % This is the equivalent of WaitBlanking on old PTB:
        vbl=Screen('Flip', window, vbl + (ifis - 0.5) * ifi_duration);
        
        % We also abort on keypress...
        if KbCheck
            break
        end
    end
    % Response block
    Screen('TextSize', window, 30);
    str0 ='\n \n \n \n \n \n \n Rate the similarity of the two colors on a scale from 1-7';
    str1 ='\n 1 is maximum similarity and 7 is maximum dissimilarity';
    str2 = '\n \n 1 2 3 4 5 6 7 ';
    DrawFormattedText(window, [str0 str1],'center', black);
    Screen('TextSize', window, 60);
    DrawFormattedText(window, [str2],'center','center', black);
    
    Screen('Flip', window);
    KbStrokeWait(device);
    
    %%
    %More instructions
    Screen('FillRect',window, gray);
    Screen('TextSize', window, 30);
    
    str0 = 'Sometimes what is actually gray will appear to be a color, due to color after effects.';
    str1 = '\n Try to ignore these after-effect colors and focus on the two saturated colors in your similarity decision.';
    str2 = '\n Press any key to continue practicing, or press space to begin the experiment.';
    DrawFormattedText(window, [str0 str1 str2],'center','center', black);
    Screen('Flip', window);
    KbStrokeWait(device);
    
    %%
    %End of experiment instructions
    Screen('TextSize', window, 30);
    str0 = 'Thank you for your time';
    str1 = '\n You have completed the experiment';
    str2 = '\n Press any key to exit';
    DrawFormattedText(window, [str0 str1 str2],'center', 'center', black);
    Screen('Flip', window);
    KbStrokeWait(device);
    sca;
    
    % Shut down realtime-mode:
    Priority(0);
    
catch
    %this "catch" section executes in case of an error in the "try" section
    %above. Importantly, it closes the onscreen window if its open.
    psychrethrow(psychlasterror);
    Priority(0);
    Screen('CloseAll');
end %try..catch..
end