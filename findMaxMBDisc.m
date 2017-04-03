%Code to find the maximum circular region of a given luminance. Finds a
%first approximation radius, then draws a circle with n points at that
%radius. Tests each point for RGB validity, and if a failure is found, the
%radius is decremented. The process is repeated until all test points
%pass. 
%Updated 3/9/2016
%Author: Nick Blauch

function [incrMB, incbMB, stepRadius] = findMaxMBDisc(luminance,monitor,plot,runTime,incrMB,incbMB)
    axisRatio = 80/3; %to produce a square plot in MB space corresponding to square MDS plot (Boehm et. al, 2014).

    if nargin<5
%         if nargin<3
%             plot = 0;
%         end
        incrMB = .0001;
        incbMB = incrMB*axisRatio;
    end
    
    origin = [.7 1];
    
    refreshRate = 120; %hz, standard.
    stepRadius = refreshRate*(runTime/2); %runtime is time out to color and back. radius is frames out to color.
    
    if strcmp(monitor,'cemnl')
        
        load extras/phosphors_cemnl
        load extras/scaling_cemnl     %load scaling which matches Boehm et. al 2014.
    elseif strcmp(monitor,'fMRI')
        load extras/phosphors_fMRI_monitor
        load extras/scaling_fMRI_monitor     %load scaling which matches Boehm et. al 2014.    
    end

    load extras/SMJfundamentals
    %gamma table not needed for fMRI, which is pre-linearized
    if ~strcmp(monitor,'fMRI')
        load extras/gammaTableLabPC
    end


    %%
    %Here we find a first approximation of the maximum radius
    %We test along the negative y-axis, from origin to 0, and use the
    %radius which produces the first invalid MB point.
    
    bMBToTry = origin(2):-incbMB:0;
    r = origin(1);
    for b = bMBToTry
        rgbMB = [r, 1-r, b];
        lms = rgbMB2lms(rgbMB,luminance,my_scaling');
        RGB = lms2rgb(phosphors,fundamentals,lms);
        if ~strcmp(monitor,'fMRI')
            try
                RGB = linearizeOutput(RGB,gammaTable);
            catch
                break
            end
        end
        if(any(RGB(:)>255) || any(RGB(:)<0))
            break
        end

    end
    bRadius = (origin(2) - b);
    stepRadiusInitial = round(bRadius/incbMB);
    thetaInc = 1; %degrees
    
    %Now we decrease the radius from the initial guess until we find a
    %radius where all points tested along the perimeter,at steps of 1 deg
    %of angle, pass the validity test in rgb coords. 
    count = 0;
    for radius = linspace(stepRadiusInitial,0,stepRadiusInitial+1);
        count = count + 1;
        saveRadius = radius;
        count1 = 0;
        broken = 0;
        for theta = 0:thetaInc:360
            count1 = count1 + 1;
            [rMB, bMB] = polar2MB(radius,theta,incrMB,incbMB);
            rgbMB = [rMB, 1-rMB, bMB];
            lms = rgbMB2lms(rgbMB,luminance,my_scaling');
            RGB = lms2rgb(phosphors,fundamentals,lms);
            %gamma table not needed for fMRI, which is pre-linearized
            if ~strcmp(monitor,'fMRI')
                try
                    RGB = linearizeOutput(RGB,gammaTable);
                catch
                    broken = 1;
                    break
                end
            end
            if(any(RGB(:)>255) || any(RGB(:)<0))
                broken = 1;
                break
            end
        end
        if broken ==0
            break
        end      
    end
    
    rRadius = saveRadius*incrMB;
    bRadius = saveRadius*incbMB;
    %Get radius in right number of steps and update increments accordingly
    incrMB = rRadius./stepRadius;
    incbMB = bRadius./stepRadius;
    
    if plot
        MakeMBspace(luminance,monitor,origin(1)-rRadius:incrMB:origin(1)+rRadius,origin(2)-bRadius:incbMB:origin(2)+bRadius)
    end
    
    
return


