%simple script to play stimulus movie only
%dysfunctional as of 3/14/17

monitor = 'fMRI';
angle = 330;
anglePair = [45 225];
doubleFirstColorRuns = 1; %1 to display first color twice as many times as second color


% try
    Screen('Preference', 'SkipSyncTests', 1);
    ifis=1; %each coded frame lasts for 1 frame
    device = -3;
    screens=Screen('Screens');
    screenNumber=max(screens);
    PsychDefaultSetup(2);
    KbName('UnifyKeyNames');
    
    % Open a double-buffered fullscreen window:
    window=Screen('OpenWindow',screenNumber);
    rect=Screen('Rect', screenNumber);
    
    %     if useTinyWindow
    %     window = Screen('OpenWindow', screenNumber, [], [0 0 640 480]);
    %     end
    
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
    
    % Query the real duration of a monitor refresh interval, gained through
    % some measurement during Screen('OpenWindow')...
    ifi_duration = Screen('GetFlipInterval', window);
    
    frameRate=Screen('FrameRate',screenNumber);
    if(frameRate==0)  % if MacOSX does not know the frame rate the 'FrameRate' will return 0.
        frameRate=60; % 60 Hz is a good guess for flat-panels...
    end
    % Switch to realtime:
    if strcmp(computer,'MACI64')
        Priority(9);
    else
        priorityLevel=MaxPriority(window);
        Priority(priorityLevel);
    end
    
    
    stimuli = getGeneratedStimuli(anglePair(1),anglePair(2),.1,'black');
    
    %         num = round(rand)
    %         if num
    %         stimuli = getGeneratedStimuli(60,75,.1,'black');
    %         else
    %            stimuli = getGeneratedStimuli(60,60,.1,'black');
    %         end
    
    %Pause for half of 1 second at the grey point
    count = 0;
    for i = 1:60
        count = count+1;
        tex(count) = Screen('MakeTexture', window, squeeze(stimuli(1,:,:,:)));
    end
    %navigations
    %for j = 1:numRuns
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
    %Pause for half of 1 second at the grey point
    for i = 1:60
        count = count+1;
        tex(count) = Screen('MakeTexture', window, squeeze(stimuli(1,:,:,:)));
    end
    
    %end
    numFrames = length(tex);
    % Show the gray background, return timestamp of flip in 'vbl'
    vbl = Screen('Flip', window);
    
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
%     sca
% 
% catch
% sca;
% end