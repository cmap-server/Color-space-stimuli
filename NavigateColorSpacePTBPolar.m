%Navigates Macleod-Boynton color space. Plays a PTB movie where a
%square-wave grating appears, where one set of bars on the grating is
%colored by a point in Macleod-Boynton color space. Two angles are picked,
%theta and phi. The movie navigates through MB space from the origin to
%theta, back to the origin and then to phi, back to the origin and so on,
%until a set time is elapsed.
%Updated 3/16/2016
%Author: Nick Blauch


function NavigateColorSpacePTBPolar(luminance,theta,phi,stripeType)
%
% numFrames Number of grating textures to use for the drifting grating...
%
% ifis = Number of monitor refreshes to wait between drawing single
% textures...
%
    if nargin<4
        stripeType = 'black';
    end
    
    ifis=2; %final?
    
    load extras/phosphors_cemnl
    load extras/SMJfundamentals
    load extras/scaling_cemnl    %load scaling which matches Boehm et. al 2014. 

    axisRatio = 80/3; %to produce a square plot in MB space corresponding to square MDS plot (Boehm et. al, 2014).
    origin = [.7, 1];

    incrMB = .0005;
    incbMB = incrMB*axisRatio;
    
    [rRadius, bRadius, rho] = findMaxMBDisc(luminance,0,incrMB,incbMB);    
    
    gamma = 2.4; %estimated
    gammaCorrect = 1; %1 to gamma correct, 0 to not gamma correct.   
    
    numNavs = 1;
    
try
	screens=Screen('Screens');
	screenNumber=max(screens);
    PsychDefaultSetup(2);

    % Open a double-buffered fullscreen window:
	w=Screen('OpenWindow',screenNumber);
    [width, height]=Screen('WindowSize', w);
    
    % Enable alpha blending with proper blend-function. We need it
    % for drawing of our alpha-mask (gaussian aperture):
    Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	% Find the color values which correspond to white and black.  Though on OS
	% X we currently only support true color and thus, for scalar color
	% arguments,
	% black is always 0 and white 255, this rule is not true on other platforms will
	% not remain true on OS X after we add other color depth modes.  
	white=WhiteIndex(screenNumber);
	black=BlackIndex(screenNumber);
	gray=(white+black)/2;
	if round(gray)==white
		gray=black;
	end
	inc=white-gray;
    
    frameRate=Screen('FrameRate',screenNumber);
	if(frameRate==0)  % if MacOSX does not know the frame rate the 'FrameRate' will return 0. 
        frameRate=60; % 60 Hz is a good guess for flat-panels...
    end
    
    runTime = 1; %seconds, time for out and back
    framesPerRun = frameRate*runTime;
    
    count = 0;
    for i = 1:numNavs
        for radius = linspace(0,rho,framesPerRun/2)
            count = count + 1;
            [rMB, bMB] = polar2MB(radius,theta,incrMB,incbMB);
            rgbMB = [rMB, 1-rMB, bMB];
            lms = rgbMB2lms(rgbMB,luminance,my_scaling');
            RGB = lms2rgb(phosphors,fundamentals,lms);
            if gammaCorrect
                RGB = (255.*((RGB./255).^(1/gamma)));
            end
            %tex(count) = Screen('MakeTexture', w, colored_gabor(RGB,45,6,0));
            tex(count) = Screen('MakeTexture', w, colored_gabor(RGB,45,6,0,stripeType,luminance));
        end
        
        for radius = linspace(rho,0,framesPerRun/2)
            count = count + 1;
            [rMB, bMB] = polar2MB(radius,theta,incrMB,incbMB);
            rgbMB = [rMB, 1-rMB, bMB];
            lms = rgbMB2lms(rgbMB,luminance,my_scaling');
            RGB = lms2rgb(phosphors,fundamentals,lms);
            if gammaCorrect
                RGB = (255.*((RGB./255).^(1/gamma)));
            end
            %tex(count) = Screen('MakeTexture', w, colored_gabor(RGB,45,6,0));
            tex(count) = Screen('MakeTexture', w, colored_gabor(RGB,45,6,0,stripeType,luminance));
            
        end
    end

    
    for i= 1:numNavs
        for radius = linspace(0,rho,framesPerRun/2)
            count = count + 1;
            [rMB, bMB] = polar2MB(radius,phi,incrMB,incbMB);
            rgbMB = [rMB, 1-rMB, bMB];
            lms = rgbMB2lms(rgbMB,luminance,my_scaling');
            RGB = lms2rgb(phosphors,fundamentals,lms);
            if gammaCorrect
                RGB = (255.*((RGB./255).^(1/gamma)));
            end
            %tex(count) = Screen('MakeTexture', w, colored_gabor(RGB,45,6,0));
            tex(count) = Screen('MakeTexture', w, colored_gabor(RGB,45,6,0,stripeType,luminance));
        end
        
        
        for radius = linspace(rho,0,framesPerRun/2)
            count = count + 1;
            [rMB, bMB] = polar2MB(radius,phi,incrMB,incbMB);
            rgbMB = [rMB, 1-rMB, bMB];
            lms = rgbMB2lms(rgbMB,luminance,my_scaling');
            RGB = lms2rgb(phosphors,fundamentals,lms);
            if gammaCorrect
                RGB = (255.*((RGB./255).^(1/gamma)));
            end
            %tex(count) = Screen('MakeTexture', w, colored_gabor(RGB,45,6,0));
            tex(count) = Screen('MakeTexture', w, colored_gabor(RGB,45,6,0,stripeType,luminance));
        end
    end
    
    numFrames = length(tex)
    
        
    % Query the real duration of a monitor refresh interval, gained through
    % some measurement during Screen('OpenWindow')...
    ifi_duration = Screen('GetFlipInterval', w);
    
	% Run the movie animation for a fixed period of max 20 seconds.  
	movieDurationSecs=20;
    

    movieDurationFrames=round(movieDurationSecs * frameRate / ifis);
    movieDurationFrames = min(movieDurationFrames,numFrames);
	movieFrameIndices=mod(0:(movieDurationFrames-1), numFrames) + 1;

    % Switch to realtime:
    if strcmp(computer,'MACI64')
        Priority(9);
    else
        priorityLevel=MaxPriority(w);
        Priority(priorityLevel);
    end
    

    % Prepare screen for animation:
    % Draw gray full-screen rectangle to clear to a defined
    % background color:
    Screen('FillRect',w, gray);

    % Show the gray background, return timestamp of flip in 'vbl'
    vbl = Screen('Flip', w);
%     
    % Animation loop:
    for i=1:movieDurationFrames
        t1=GetSecs;
        % Draw grating for current frame:
        Screen('DrawTexture', w, tex(movieFrameIndices(i)), [], []);

        % Show result on screen: We only want to show a new frame every
        % ifis monitor refresh intervals. Therefore we calculate a proper
        % presentation time that is '(ifis - 0.5) * ifi_duration' after the
        % time 'vbl' when the previous frame was shown.
        % This is the equivalent of WaitBlanking on old PTB:
        vbl=Screen('Flip', w, vbl + (ifis - 0.5) * ifi_duration);
        
        t1=GetSecs - t1;
        if (i>numFrames)
            tavg=tavg+t1;
        end;
        
        % We also abort on keypress...
        if KbCheck
            break
        end
    end

    % Shut down realtime-mode:
    Priority(0);

    % We're done: Close all windows and textures:
    Screen('CloseAll');
    
catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Priority(0);
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end %try..catch..