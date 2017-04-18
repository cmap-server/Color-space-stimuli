

function run_DKL_perceptual_similarity_study

%define data structure
addpath('color_toolbox_v1');

%Create randomly ordered list of all angle pairs
anglePairs = nchoosek(0:15:345,2);
sameAnglePairs = [0:15:345; 0:15:345]';
anglePairs = [anglePairs; sameAnglePairs];
randomAnglePairs = anglePairs(randperm(size(anglePairs,1)),:);

%[incDKLX, incDKLY, origin, luminance, stepRadius] = findMaxDKLDisc(50,'cemnl',0,1);
[color_patch_img, ~, colors, ~] = make_DKL_ColorPatch(50,'cemnl',0);
load extras/phosphors_cemnl
load extras/scaling_cemnl     %load scaling which matches Boehm et. al 2014.
load extras/SMJfundamentals
load extras/gammaTableLabPC
    

% try
    %----------------------------------------------------------------------------------------%
    %                                     Setup
    %----------------------------------------------------------------------------------------%
    
    Screen('Preference', 'SkipSyncTests', 1);
    
    ifis=1; %each coded frame lasts for 1 frame
    %keyboard
    device = -3;
    useTinyWindow = 0;%debugging
    
	screens=Screen('Screens');
	screenNumber=max(screens);
    PsychDefaultSetup(2);
    KbName('UnifyKeyNames');
    
    
    
    if useTinyWindow
        window = Screen('OpenWindow', screenNumber, [], [0 0 640 480]);
    else
        % Open a double-buffered fullscreen window:
        window=Screen('OpenWindow',screenNumber);
    end
    rect=Screen('Rect', screenNumber);

    
    [screenXpixels, screenYpixels] = Screen('WindowSize', window);

    % Get the centre coordinate of the window
    [xCenter, yCenter] = RectCenter(rect);


    % Enable alpha blending with proper blend-function. We need it
    % for drawing of our alpha-mask (gaussian aperture):
    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	%Define white, black, and gray  
	white=WhiteIndex(screenNumber);
    gray=white/2;
	black=BlackIndex(screenNumber);
    inc=white-gray;
        
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
        window, 'Enter Subject Number:  ', xCenter, yCenter);
    subjectNumber = str2num(GetEchoString(window,'Enter Subject Number:  ',...
        xCenter-normBoundsRect(3)/2, yCenter-normBoundsRect(4)/2, black));
    Screen('Flip', window);
    %%
    %----------------------------------------------------------------------------------------%
    %                                     Instructions
    %----------------------------------------------------------------------------------------%
    
    Screen('FillRect',window, gray);
    Screen('TextSize', window, 60);
    str0 =' Welcome to the Color Similarity experiment';
    DrawFormattedText(window, [str0],'center',.35*screenYpixels, black,80);
    Screen('TextSize', window, 30);
    str1 = '\n\n\n\n\n\n We will first allow you to become familiar with the experiment by completing some practice trials.';
    str2 = '\n\n Press any key to continue';
    DrawFormattedText(window, [str1 str2],'center','center', black,80);
    Screen('Flip', window);
    KbStrokeWait;
    
    Screen('FillRect',window, gray);
%     Screen('TextSize', window, 30);
% 
%     fullString = 'You will be asked to rate the similarity of a series of color pairs. These colors will be chosen from a set of 24 colors, shown below.';
%     DrawFormattedText(window, fullString, 'center',.65*yCenter,black,80);
%     texture = Screen('MakeTexture',window,color_patch_img);        
%     Screen('DrawTexture', window, texture,[] ,[]);
%     str2 = '(press any key to continue)';
%     DrawFormattedText(window, str2, 'center',1.35*yCenter,black,80);
%     Screen('Flip', window);
%     KbStrokeWait;
%     
%     str1 = 'In each trial, you will see two colored boxes. Your task is to rate the similarity of the two colors.';
%     str2 = 'If the colors are the same, you should give a rating of 0. If they are different, use the scale 1-6, where increasing number indicates increasing color dissimilarity.';
%     str3 = '\n You will now complete some practice trials. Once you feel comfortable with the task, press space to move on to the experiment.';
%     DrawFormattedText(window,[str1 str2 str3],'center',.5*yCenter,black,80);
%     Screen('Flip',window);
%     KbStrokeWait;
    


    
    %%
    %----------------------------------------------------------------------------------------%
    %                                     Practice Phase
    %----------------------------------------------------------------------------------------%
    
    % Make a base Rect of 200 by 200 pixels
    baseRect = [0 0 200 200];
    
    rectXPos = [screenXpixels * 0.33 screenXpixels * 0.66];
    allRects = nan(4, 2);
    for i = 1:2
        allRects(:, i) = CenterRectOnPointd(baseRect, rectXPos(i), yCenter+.25*yCenter);
    end
 
    while(1)
        %Draw Textures
        
        color_1 = colors{anglePair(1)./15+1};
        color_2 = colors{anglePair(2)./15+1};
        
        Screen('FillRect', window, [color_1',color_2'], allRects ) 
        Screen('FrameRect', window, black, allRects);

        
        % Response block
        Screen('TextSize', window, 30);
        str11 = '\n \n \n \n \n \n \n Your task is to rate the similarity of the two colors shown in the boxes below.';
        str0 =' \n Rate the similarity of the two colors on a scale from 1-7';
        str1 = '\n (press space to move on to the experiment)';
        str2 ='\n\n\n\n         same            most similar -------------------> most dissimilar';
        str3 = '\n \n 1     |     2   3   4   5   6   7 ';
        DrawFormattedText(window, [str11 str0 str1 str2],'center',0,black,80);
        Screen('TextSize', window, 60);
        DrawFormattedText(window, [str3],'center',.35*screenYpixels, black,80);
        
        Screen('Flip', window);
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
    
    str1 = 'The experiment will now begin. There are 300 trials per run, and 4 runs.';
    str2 = '\n\n You may take breaks at any time, but you should try to proceed quickly while making accurate judgments.';
    str3 = '\n\n Press any button to proceed.';
    Screen('TextSize', window, 30);
    DrawFormattedText(window, [str1 str2 str3],'center','center',black,80);
    
    Screen('Flip',window)
    KbStrokeWait;
    
    num_iterations = 4;
    color_angles = zeros(num_iterations*length(anglePairs),2);
    responses = zeros(num_iterations*length(anglePairs),1);
    
    trial = 0;
    
    for iteration = 1:num_iterations
        randomAnglePairs = anglePairs(randperm(size(anglePairs,1)),:);
        
        if iteration > 1
            str1 = sprintf('%s %s %s', 'The experiment is', strcat(num2str(iteration-1),'/',num2str(5)),'done');
            str2 = '\n\n Press any button to continue.';
            Screen('TextSize', window, 60);
            DrawFormattedText(window, [str1 str2],'center','center',black,80);
            Screen('Flip',window)
            KbStrokeWait;
        end
        
        for color = 1:length(randomAnglePairs)
            trial = trial + 1;
            
            anglePair = randomAnglePairs(color,:);
            
            color_1 = colors{anglePair(1)./15+1};
            color_2 = colors{anglePair(2)./15+1};
            
            Screen('FillRect', window, [color_1',color_2'], allRects )
            Screen('FrameRect', window, black, allRects);
            % Response block
            Screen('TextSize', window, 30);
            str0 ='\n \n \n \n \n \n \n \n Rate the similarity of the two colors on a scale from 1-7';
            str2 ='\n\n\n\n         same            most similar -------------------> most dissimilar';
            str3 = '\n \n 1     |     2   3   4   5   6   7 ';
            DrawFormattedText(window, [str0 str2],'center',0,black,80);
            Screen('TextSize', window, 60);
            DrawFormattedText(window, [str3],'center',.35*screenYpixels, black,80);
%             Screen('TextSize', window, 20);
%             progress_str = sprintf('%s %s %s', 'The experiment is', strcat(num2str(100*(trial/length(color_angles))),'%'),'done');
%             DrawFormattedText(window,progress_str,'center',.8*screenYpixels,black,80);
            
            Screen('Flip', window);
            
            [~, keyCode, ~] = KbStrokeWait();
            if(keyCode(KbName('Escape')))
                break;
            end
            if(any(keyCode(49:55)))
                keyNum = find(keyCode(49:55),1);
                color_angles(trial,:) = anglePair;
                responses(trial) = keyNum;
            end
            
        end
    end
   
    fileName = strcat('experimental_data_DKL_similarity/sub',num2str(subjectNumber),'_',char(datetime('now')),'.mat');
    fileName = strrep(fileName,' ','_');
    fileName = strrep(fileName,':','-');
    save(fileName,'responses','color_angles')
    
    %%
    %----------------------------------------------------------------------------------------%
    %                             End of experiment instructions
    %----------------------------------------------------------------------------------------%

    Screen('TextSize', window, 40);
    str0 = 'Thank you for your time';
    str1 = '\n You have completed the experiment';
    str2 = '\n Press any key to exit, then let the experimeter know you have finished.';
    DrawFormattedText(window, [str0 str1 str2],'center', 'center', black,80);
    Screen('Flip', window);
    KbStrokeWait;
    sca;
    
    % Shut down realtime-mode:
    Priority(0);
    
% catch MExc
%     %this "catch" section executes in case of an error in the "try" section
%     %above.  Importantly, it closes the onscreen window if its open.
%     psychrethrow(psychlasterror);
%     %MDS requires 0 on diagonal. we save both upper triangular matrix and
%     %upper triangular minus diagonal matrix.
%     fileName = strcat('experimental_data_DKL_similarity/broken_sub',num2str(subjectNumber),'_',char(datetime('now')),'.mat');
%     fileName = strrep(fileName,' ','_');
%     fileName = strrep(fileName,':','-');
%     save(fileName,'responses','color_angles')    
%     Priority(0);
%     Screen('CloseAll');
% end %try..catch..
end