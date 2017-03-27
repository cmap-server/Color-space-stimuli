%The full color navigation experiment
%Author: Nick Blauch
%Updated: 4/20/2016

function runExperiment

%define data structure
dissimilarityMatrix = zeros(24,24);
addpath('color_toolbox_v1');


try
    %----------------------------------------------------------------------------------------%
    %                                     Setup
    %----------------------------------------------------------------------------------------%
    ifis=1; %each coded frame lasts for 1 frame
    %keyboard
    device = -3;
    %useTinyWindow = 1;%debugging
    
    %Create randomly ordered list of all angle pairs
    anglePairs = nchoosek(0:15:345,2);
    sameAnglePairs = [0:15:345; 0:15:345]';
    anglePairs = [anglePairs; sameAnglePairs];
    randomAnglePairs = anglePairs(randperm(size(anglePairs,1)),:);   
    
    %numRuns = 1; %number of runs for second color
    doubleFirstColorRuns = 0; %1 to display first color twice as many times as second color
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
    [oldStyle oldFont oldNum] =Screen('TextFont', window);
    
    
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
    
    %% 
    %----------------------------------------------------------------------------------------%
    %                                     Get subject number
    %----------------------------------------------------------------------------------------%
    [xCenter, yCenter] = RectCenter(rect);
    Screen('FillRect',window,gray);
    Screen('TextSize', window, 30);
    [normBoundsRect, offsetBoundsRect] = Screen('TextBounds',...
        window, ['Enter Subject Number:  '], xCenter, yCenter);
    subjectNumber = str2num(GetEchoString(window, ['Enter Subject Number:  '],...
        xCenter-normBoundsRect(3)/2, yCenter-normBoundsRect(4)/2, black));
    Screen('Flip', window);
    %%
    %----------------------------------------------------------------------------------------%
    %                                     Instructions
    %----------------------------------------------------------------------------------------%
    
    Screen('FillRect',window, gray);
    Screen('TextSize', window, 60);
    str0 =' Welcome to the experiment';
    str1 = '\n Press any key to continue';
    DrawFormattedText(window, [str0 str1],'center','center', black);
    Screen('Flip', window);
    KbStrokeWait;

%     while 1
%         [ch ~] = GetChar;
%         if ch
%             break
%         end
%     end
    
    Screen('FillRect',window, gray);
    Screen('TextSize', window, 30);
    %%Attemping to draw samples of each color onto the screen
    axisRatio = 80/3; %to produce a square plot in MB space corresponding to square MDS plot (Boehm et. al, 2014).
    %initial guesses
    incrMB = .0005;
    incbMB = incrMB*axisRatio;
    [incrMB, incbMB, rho] = findMaxMBDisc(.1,'cemnl',0,1,incrMB,incbMB);
    [imgXY imgYX] = makeColorPatch(rho-15,.1,incrMB,incbMB);

    fullString = 'You will be asked to rate the similarity of a series of color pairs. These colors will be chosen from a set of 24 colors, shown below.';
    DrawFormattedText(window, fullString, 'center',.65*yCenter,black,80);
    texture = Screen('MakeTexture',window,imgXY);        
    Screen('DrawTexture', window, texture,[] ,[]);
    str2 = '(press any key to continue)';
    DrawFormattedText(window, str2, 'center',1.35*yCenter,black,80);
    Screen('Flip', window);
    KbStrokeWait;
    
    str1 = 'In each trial, there will be a visual stimulus, called a gabor patch, with alternating black and colored stripes. Each trial contains a very short movie where the colored stripes change color.';
    str2 = '\n Press any key to see a demo movie';
    DrawFormattedText(window,str1,'center',.5*yCenter,black,80);
    Screen('Flip',window);
    KbStrokeWait;

%     while 1
%         [ch ~] = GetChar;
%         if ch
%             break
%         end
%     end
    
    %% demo movie
    anglePair = randomAnglePairs(round(300*rand+1),:);
    stimuli = getGeneratedStimuli(anglePair(1),anglePair(2),.1,'cemnl','black');
    
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
    Screen('FillRect',window, gray);
    vbl = Screen('Flip', window);
    
    % Color navigation demo
    for i=1:length(tex)
        t1=GetSecs;
        % Draw grating for current frame:
        Screen('DrawTexture', window, tex(i), [], []);
        %Leave text on the screen
        str1 = 'In each trial, there will be a visual stimulus, called a gabor patch, with alternating black and colored stripes. Each trial contains a very short movie where the colored stripes change color.';
        DrawFormattedText(window,str1,'center',.5*yCenter,black,80);
        if i == length(tex)
            DrawFormattedText(window,'(press any key to continue)','center',1.5*yCenter,black,80)
        end
        % Show result on screen: We only want to show a new frame every
        % ifis monitor refresh intervals. Therefore we calculate a proper
        % presentation time that is '(ifis - 0.5) * ifi_duration' after the
        % time 'vbl' when the previous frame was shown.
        % This is the equivalent of WaitBlanking on old PTB:
        vbl=Screen('Flip', window, vbl + (ifis - 0.5) * ifi_duration);
        if i == length(tex)
            KbStrokeWait;
        end
        % We also abort on keypress...
        if KbCheck
            break
        end
    end
    %%
    Screen('FillRect',window, gray);
    Screen('TextSize', window, 30);
    
    fullString = 'As you just saw, the colored stripes begin at gray and progressively saturate to a color chosen from the 24 you saw earlier. They then progressively desaturate to gray. The stripes then saturate to a second color, and again return to gray. After the movie finishes, you will be asked to rate the similarity of the two colors you saw.  If you think the two colors were the same, you should give a rating of 1. If you think the colors were different, you should give a rating of 2-7, where 2 is most similar, and 7 is most dissimilar. \n\n (press any key to continue).';
    DrawFormattedText(window, fullString, 'center','center',black,[, 80]);
    Screen('Flip', window);
    Screen('Close');
    KbStrokeWait;
    
   
%     while 1
%         [ch ~] = GetChar;
%         if ch
%             break
%         end
%     end
   
    Screen('FillRect',window, gray);
    Screen('TextSize', window, 30);
    str1 = 'You may now complete some practice trials in preparation for the experiment. In these trials, a small number will appear at the fixation point indicating 1 of 2 saturated colors to compare. This is to get you used to the experiment. These numbers will not be part of the test experiment. You should make sure you are comfortable detecting the sequence of color 1 into color 2';
    str2 = '\n When you feel that you have had enough practice, press space to move on to the experiment.';
    str3 ='\n\n (press any key to continue)';
    DrawFormattedText(window, [str1 str2 str3],'center','center', black,[,80]);
    Screen('Flip', window);
    KbStrokeWait;
%     while 1
%         [ch ~] = GetChar;
%         if ch
%             break
%         end
%     end
    
    %%
    %----------------------------------------------------------------------------------------%
    %                                     Practice Phase
    %----------------------------------------------------------------------------------------%
    
    while(1)
        %Draw Textures
        anglePair = randomAnglePairs(round(300*rand+1),:);
        stimuli = getGeneratedStimuli(anglePair(1),anglePair(2),.1,'cemnl','black');
        
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
        firstColor = count;
        
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
        secondColor = count;
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
            thirdColor = count;
            %back to gray
            for i = linspace(size(stimuli,1)/2,1,size(stimuli,1)/2)
                count = count+1;
                tex(count) = Screen('MakeTexture', window, squeeze(stimuli(i,:,:,:)));
            end
        else
            thirdColor = 0;
        end
        %Pause for half of 1 second at the grey point
        for i = 1:60
            count = count+1;
            tex(count) = Screen('MakeTexture', window, squeeze(stimuli(1,:,:,:)));
        end
        
        %end
        numFrames = length(tex);
        % Show the gray background, return timestamp of flip in 'vbl'
        Screen('FillRect',window, gray);
        vbl = Screen('Flip', window);
        
        % Color navigation demo
        for i=1:length(tex)
            t1=GetSecs;
            % Draw grating for current frame:
            Screen('DrawTexture', window, tex(i), [], []);
            if any(i==firstColor-15:firstColor)
                Screen('TextSize', window, 10);
                DrawFormattedText(window,num2str(1),'center','center',black );
            end 
            if any(i==secondColor-15:secondColor)
                Screen('TextSize', window, 10);
                DrawFormattedText(window,num2str(2),'center','center',black );
            end
            if any(i==thirdColor-15:thirdColor)
                Screen('TextSize', window, 10);
                DrawFormattedText(window,num2str(1),'center','center',black );
            end
            
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
        str0 ='\n \n \n \n \n \n \n \n \n \n \n Rate the similarity of the two colors on a scale from 1-7';
        str1 = '\n (press space to move on to the experiment)';
        str2 ='\n\n\n\n\n         same            most similar -------------------> most dissimilar';
        str3 = '\n \n 1     |     2   3   4   5   6   7 ';
        DrawFormattedText(window, [str0 str1 str2],'center',[,0],black,[,80]);
        Screen('TextSize', window, 60);
        DrawFormattedText(window, [str3],'center','center', black,[,80]);
        
        Screen('Flip', window);
        Screen('Close',[tex]);
        clear tex
        [~, keyCode, ~] = KbStrokeWait();
        
%         [ch ~] = GetChar;
        
        if(keyCode(KbName('space')))
            break
        end
        
    end
    
    %%
    %----------------------------------------------------------------------------------------%
    %                                      Test phase
    %----------------------------------------------------------------------------------------%
    Screen('TextSize', window, 30);
    str0 ='We will now begin the experiment. There are 300 trials. After each trial, you will see your progress on the screen, and can wait as long as you want before pressing a key to begin the next trial. Please do your best to pay attention and make accurate similarity judgments. You should try to make these judgments quickly, in under 2 seconds. ';
    str1 = '\n Press any button to begin';
    DrawFormattedText(window, [str0 str1],'center','center', black,80);

    Screen('Flip', window);
    KbWait;
    
%     %Create the queue once. Future queues will be flushed versions of this.
%     KbQueueCreate;
    for trial = 1:length(randomAnglePairs)

%         [ch ~] = GetChar;

        %------------------------Make Color Textures----------------------%
        %-----------------------------------------------------------------%
        anglePair = randomAnglePairs(trial,:);
        stimuli = getGeneratedStimuli(anglePair(1),anglePair(2),.1,'cemnl','black');
        count = 0;
        clear tex
        tic
        %Pause for half of 1 second at the grey point
        for i = 1:60
            count = count+1;
            tex(count) = Screen('MakeTexture', window, squeeze(stimuli(1,:,:,:)));
        end
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
        toc
%         if trial>1
%             KbQueueRelease;
%             [ pressed, firstPress]=KbQueueCheck;
%             if pressed
%                 keyNum = find(firstPress == max(firstPress(49:55)));
%                 angleIndices = 1+ randomAnglePairs(trial-1,:)./15;
%                 dissimilarityMatrix(angleIndices(1),angleIndices(2)) = keyNum;
%             end
%             KbQueueFlush;
%             Screen('TextSize',window,40);
%             numFrames = length(tex);
%             DrawFormattedText(window,[strcat('Trial ',num2str(trial),' of 300'),'\n \n Press any key to continue'],'center','center',black,[,80])
%             Screen('Flip',window);
%             KbWait;
%         end

        %Display wait screen after textures are loaded. When subject
        %presses a button, the movie starts quickly.  
        Screen('TextSize',window,40);
        numFrames = length(tex); 
        DrawFormattedText(window,['Trial ' num2str(trial) ' of 300' '\n \n Press any key to continue'],'center','center',black,[,80]);
        Screen('Flip',window);
        KbStrokeWait;
        
        % Show the gray background, return timestamp of flip in 'vbl'        
        vbl = Screen('Flip', window);
        %------------------------Draw Color Textures----------------------%
        for i=1:length(tex)
            Screen('DrawTexture', window, tex(i), [], []);
            vbl=Screen('Flip', window, vbl + (ifis - 0.5) * ifi_duration);
        end

        %-----------------------------------------------------------------%
        % Response block
        Screen('FillRect',window, gray);
        Screen('TextSize', window, 30);
        str0 ='\n \n \n \n \n \n \n \n \n \n \n Rate the similarity of the two colors on a scale from 1-7';
        str2 ='\n\n\n\n\n         same            most similar -------------------> most dissimilar';
        str3 = '\n \n 1     |     2   3   4   5   6   7 ';
        DrawFormattedText(window, [str0 str2],'center',[,0],black,[,80]);
        Screen('TextSize', window, 60);
        DrawFormattedText(window, [str3],'center','center', black,[,80]);
        Screen('Flip', window);
        Screen('Close',tex);        
        
%         KbQueueStart; 
        
        [~, keyCode, ~] = KbStrokeWait();
        if(keyCode(KbName('Escape')))
            break;
        end
        if(any(keyCode(49:55)))
            keyNum = find(keyCode(49:55),1);
            angleIndices = 1+ anglePair./15;
            dissimilarityMatrix(angleIndices(1),angleIndices(2)) = keyNum;
        end
        

        
    end
    %MDS requires 0 on diagonal. we save both upper triangular matrix and
    %upper triangular minus diagonal matrix. 
    MDSdissimilarityMatrix = dissimilarityMatrix;
    MDSdissimilarityMatrix(1:24+1:24*24) = 0;
    save(strcat('experimentalData/sub',num2str(subjectNumber)),'MDSdissimilarityMatrix','dissimilarityMatrix','randomAnglePairs','angleIndices');
    
    %%
    %----------------------------------------------------------------------------------------%
    %                             End of experiment instructions
    %----------------------------------------------------------------------------------------%

    Screen('TextSize', window, 40);
    str0 = 'Thank you for your time';
    str1 = '\n You have completed the experiment';
    str2 = '\n Press any key to exit, then let the experimeter know you have finished.';
    DrawFormattedText(window, [str0 str1 str2],'center', 'center', black,[,80]);
    Screen('Flip', window);
    KbStrokeWait;
    sca;
    
    % Shut down realtime-mode:
    Priority(0);
    
catch MExc
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    psychrethrow(psychlasterror);
    %MDS requires 0 on diagonal. we save both upper triangular matrix and
    %upper triangular minus diagonal matrix.
    MDSdissimilarityMatrix = dissimilarityMatrix;
    MDSdissimilarityMatrix(1:24+1:24*24) = 0;
    save(strcat('experimentalData/sub',num2str(subjectNumber)),'MDSdissimilarityMatrix','dissimilarityMatrix','randomAnglePairs','angleIndices');
    Priority(0);
    Screen('CloseAll');
end %try..catch..
end