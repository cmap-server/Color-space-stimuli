%
%[incDKLX, incDKLY, origin, luminance, stepRadius] = findMaxDKLDisc(background_grey,monitor,plot,runTime)        

%Code to find the maximum circular region of a given luminance. Finds a
%first approximation radius, then draws a circle with n points at that
%radius. Tests each point for RGB validity, and if a failure is found, the
%radius is decremented. The process is repeated until all test points
%pass. 
%Copied from equivalent function for MB space for use with DKL space
%Updated 3/13/2017
%Author: Nick Blauch

function [incDKLX, incDKLY, origin, luminance, stepRadius] = findMaxDKLDisc(background_grey,monitor,plot,runTime)        
    

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

    background_lms = rgb2lms(phosphors,fundamentals,repmat(background_grey,[3,1]));
    background_dkl = lms2cartDKL(background_lms,my_scaling');
    origin = background_dkl(1:2); %set background chromatic dimensions as origin
    luminance = background_dkl(3);

    
%     test_stim_dkl = background_dkl + [0 0.5 0];
%     test_stim_lms = cartDKL2lms(test_stim_dkl,my_scaling');
%     test_stim_rgb = lms2rgb(phosphors,fundamentals,test_stim_lms)
    
%     test_stim = repmat(test_stim_rgb',[1, 100,100]);
%     background = repmat(origin_rgb',[1, 100, 100]);
%     figure
%     subplot(2,1,1)
%     imshow(permute(background,[2 3 1])./255)
%     subplot(2,1,2)
%     imshow(permute(test_stim,[2,3,1])./255)


    %%
    %Here we find a first approximation of the maximum radius
    %We test along the  y-axis, from origin to 2, and use the
    %radius which produces the first invalid MB point.
    
    if strcmp(monitor,'cemnl')
        
        X = origin(1);
        YtoTry = linspace(origin(2),origin(2)+.5,100); %origin(2) + .5 was experimentally found to fail, and be close to passing
        incDKLY = (YtoTry(end)-origin(2))/100;
        for Y = YtoTry
            DKL_coords = [X, Y, luminance];
            lms = cartDKL2lms(DKL_coords,my_scaling');
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
        Yradius = ((Y-incDKLY)- origin(2));
        incDKLY = (Yradius/60);
        
        Y = origin(2);
        XtoTry =  linspace(origin(1),origin(1)+.06,100); %origin(1) + .06 was experimentally found to fail, and be close to passing
        incDKLX = (XtoTry(end) - origin(1))/100;
        
        for X = XtoTry
            DKL_coords = [X, Y, luminance];
            lms = cartDKL2lms(DKL_coords,my_scaling');
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
        Xradius = (X-incDKLX- origin(1));
        incDKLX = (Xradius/60);
    
    elseif strcmp(monitor,'fMRI')
        
        X = origin(1);
        YtoTry = linspace(origin(2),origin(2)+.5,100); %origin(2) + .5 was experimentally found to fail, and be close to passing
        incDKLY = (YtoTry(end)-origin(2))/100;
        for Y = YtoTry
            DKL_coords = [X, Y, luminance];
            lms = cartDKL2lms(DKL_coords,my_scaling');
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
        Yradius = ((Y-incDKLY)- origin(2));
        incDKLY = (Yradius/60);
        
        Y = origin(2);
        XtoTry =  linspace(origin(1),origin(1)+.04,100); %origin(1) + .04 was experimentally found to fail, and be close to passing
        incDKLX = (XtoTry(end) - origin(1))/100;
        
        for X = XtoTry
            DKL_coords = [X, Y, luminance];
            lms = cartDKL2lms(DKL_coords,my_scaling');
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
        Xradius = (X-incDKLX- origin(1));
        incDKLX = (Xradius/60);
    end
    
    
    
%     
%     
%     thetaInc = 1; %degrees
%     
%     %Now we decrease the radius from the initial guess until we find a
%     %radius where all points tested along the perimeter,at steps of 1 deg
%     %of angle, pass the validity test in rgb coords. 
%     count = 0;
%     for radius = 1:-Yinc:0
%         count = count + 1;
%         saveRadius = radius;
%         count1 = 0;
%         broken = 0;
%         for theta = 0:thetaInc:360
%             count1 = count1 + 1;
%             [DKLX, DKLY] = polar2DKL(radius,theta,incDKLX,incDKLY,origin);
%             DKL_coords = [DKLX, DKLY, luminance];
%             lms = cartDKL2lms(DKL_coords,my_scaling');
%             RGB = lms2rgb(phosphors,fundamentals,lms);
%             %gamma table not needed for fMRI, which is pre-linearized
%             if ~strcmp(monitor,'fMRI')
%                 try
%                     RGB = linearizeOutput(RGB,gammaTable);
%                 catch
%                     broken = 1; %break if any color is invalid, return to loop and decrease value
%                     break
%                 end
%             end
%             if(any(RGB(:)>255) || any(RGB(:)<0))
%                 broken = 1; %break if any color is invalid, return to loop and decrease value
%                 break
%             end
%         end
%         if broken ==0 %if not broken, all points are valid so break and save info
%             break
%         end      
%     end
%         
%     XRadius = saveRadius*incDKLX;
%     Yradius = saveRadius*incDKLY;
%     %Get radius in right number of steps and update increments accordingly
%     incDKLX = XRadius./stepRadius;
%     incDKLY = Yradius./stepRadius;

    DKLX = origin(1)-Xradius:incDKLX:origin(1)+Xradius;
    DKLY = origin(2)-Yradius:incDKLY:origin(2)+Yradius;
    
    if plot
        img = MakeDKLspace(background_grey,monitor,DKLX,DKLY);
    end
    
    
return
