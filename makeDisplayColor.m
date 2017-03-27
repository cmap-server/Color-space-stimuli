%Program to display a color of a given RGB code on the full screen

function makeDisplayColor(RGB)

imSize = 800;
img = zeros(imSize,imSize,3);
img(:,:,1) = RGB(1);
img(:,:,2) = RGB(2);
img(:,:,3) = RGB(3);

try
    screens=Screen('Screens');
    screenNumber=max(screens);
    PsychDefaultSetup(2);
    
    % Open a double-buffered fullscreen window:
    w=Screen('OpenWindow',screenNumber);
    [width, height]=Screen('WindowSize', w);
    
    
    Screen('FillRect',w, RGB);
    
    
    % We also abort on keypress...
    if KbCheck
        % Shut down realtime-mode:
        Priority(0);
        
        % We're done: Close all windows and textures:
        Screen('CloseAll');
        
    end
    

    
catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Priority(0);
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end %try..catch..

end