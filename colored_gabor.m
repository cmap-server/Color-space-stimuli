%Input a 1x3 vector RGB color code, and an orientation in deg.
%Output a 1582x1582 img of a colored gabor patch
%Many arguments are fixed, but this code
%can easily be modified to take additional arguments (such as imSize,
%lambda, etc.)
%Author: Nick Blauch
%Updated 1/14/2016
%Updated 12/12/2016 with background_grey variable set in script to allow
%for darker background grey, for fMRI experiment.

function gabor_img = colored_gabor(RGB, orientation_deg,patch_size_deg,monitor,normalize,stripeType,MBluminance)
    %%
    %-------------------------------------------------------------------------%
    %Step 0 -- Set experimental conditions
    %-------------------------------------------------------------------------%
    if exist('DKL','var')==0
        DKL = 0;
    end
    
    if nargin<6
        stripeType = 'black';
        if nargin<5
            normalize =0; %sets colors on 0:255. otherwise on 0:1
        end
    end
        
    if strcmp(stripeType,'color')
        if strcmp(monitor,'cemnl')
            load extras/phosphors_cemnl
            load extras/scaling_cemnl
            load extras/gammaTableLabPC
        elseif strcmp(monitor,'fMRI')
            load extras/phosphors_fMRI_monitor
            load extras/scaling_fMRI_monitor
        end
       
        load extras/SMJfundamentals
        luminanceScale = 6;
        lms = rgb2lms(phosphors,fundamentals,RGB');
        rgbMB = lms2rgbMB(lms,my_scaling');
        lms2 = rgbMB2lms(rgbMB,MBluminance*luminanceScale,my_scaling');
        lowLumRGB = lms2rgb(phosphors,fundamentals,lms2);
    end
        
    
    view_dist_mm = 700; %mm
    theta = orientation_deg + 90; %orientation angle is 90 deg shifted from math angle
    lambda_vis_ang = 1; %deg/cycle
    screenwidth = 533; %mm
    %screenres = 1920; %pixels, x-direction
    set(0,'units','pixels')  
    screenres = get(0,'screensize');
    screenres = screenres(3);

    background_grey = 128;
    contrast = 1;
    gabor_size_ang = patch_size_deg;
    inner_r_ang = .015*gabor_size_ang; % deg, size of inner radius
    outer_r_ang = gabor_size_ang/2 - inner_r_ang; %deg, size of outer radius
    box_size_ang = gabor_size_ang + .1*gabor_size_ang; %Box is slightly bigger than gabor

    color = RGB; %specified by 1x3 vector input

    [box_size_xdist, boxsize_ydist] = visangle2stimsize(box_size_ang,box_size_ang,view_dist_mm,screenwidth,screenres);
    imSize = box_size_xdist;
    %convert wavelength from vis angle to size in pixels
    [sizex,sizey] = visangle2stimsize(lambda_vis_ang,lambda_vis_ang,view_dist_mm,screenwidth,screenres);
    
    %%BOLD settings
    if strcmp(monitor,'fMRI')
        view_dist_mm = 1370; %mm
        screenwidth = 700; %mm
        screenres = 1920; %pixels
        max_BOLD_vis_angle_width = 28; %deg
        sizex = round((lambda_vis_ang./max_BOLD_vis_angle_width)*screenres);
        imSize = round((box_size_ang./max_BOLD_vis_angle_width)*screenres);
    end
        

    %%
    %-------------------------------------------------------------------------%
    %Step 1 -- create a greyscale sinusoidal grating
    %-------------------------------------------------------------------------%

    lambda = sizex; %spatial wavelength
    amp = 1; %amplitude
    sigma = 10000; %decay constant for gaussian envelope. very large for no envelope.
    phase = .75*lambda; %phase; initial offset of .25*lambda to center. adding .5*lambda flips stripes. 
    show = 0; %display image
    prp = 0;
    gabor = Gabor_function( imSize, lambda, amp, theta, sigma, phase, show, prp);

    %%
    %-------------------------------------------------------------------------%
    % Step 2: Make the grating a square wave
    %-------------------------------------------------------------------------%
    %save('gabor','gabor');
    for index1=1:imSize
        for index2=1:imSize
            if(abs(gabor(index1,index2))<10^(-5) && abs(gabor(index1,index2))>0)
                gabor(index1,index2) = -1;
            end
            if(gabor(index1,index2)>0)
                gabor(index1,index2) = 1;
            end
            if(gabor(index1,index2)<=0)
                gabor(index1,index2) = -1;
            end
        end
    end
    %%
    %-------------------------------------------------------------------------%
    %%Step 2.5 -- create an annular aperture
    %-------------------------------------------------------------------------%

    inner_r_pix = visangle2stimsize(inner_r_ang,inner_r_ang,view_dist_mm,screenwidth,screenres);
    outer_r_pix = visangle2stimsize(outer_r_ang,outer_r_ang,view_dist_mm,screenwidth,screenres);
    origin_r = imSize/2; %pix
    [rr cc] = meshgrid(1:imSize);
    annulus = (sqrt((rr-origin_r).^2+(cc-origin_r).^2)) <= inner_r_pix |(sqrt((rr-origin_r).^2+(cc-origin_r).^2)) >=outer_r_pix;
    %%Set annulus values of 1 to background
    for index1=1:imSize
        for index2=1:imSize
            if(annulus(index1,index2)==1)
                gabor(index1,index2) = 0;
            end
        end
    end
    %%
    %-------------------------------------------------------------------------%
    %Step 3 -- color regions according to specs
    %-------------------------------------------------------------------------%

    % Step 2.5: Make the grating a square wave
    %-------------------------------------------------------------------------%
    for index1=1:imSize
        for index2=1:imSize
            if(gabor(index1,index2)>0)
                gabor(index1,index2) = 1;
            end
            if(gabor(index1,index2)<0)
                gabor(index1,index2) = -1;
            end
        end
    end
    
        %get values on 0-255
    gabor(gabor==1) = 128 + contrast*127;
    gabor(gabor==0) = 128;
    gabor(gabor==-1) = 128 - contrast*127;
    %Define regions
    Regions = gabor>128; %%White is 1, black is 0 logical
    grey = (gabor==128);
    %%At this stage, we have a square wave black/white gabor within an
    %%annulus where the background is set to mid gray.
    
    %%
    %-------------------------------------------------------------------------%
    %Step 3 -- color regions according to specs
    %-------------------------------------------------------------------------%
    img = zeros(imSize,imSize,3);
    img(:,:,1) = gabor;
    img(:,:,2) = gabor;
    img(:,:,3) = gabor;
    
    for x1 = 1:imSize
        for x2 = 1:imSize
            if Regions(x1,x2)==1
                img(x1,x2,:) = color;
            elseif grey(x1,x2) == 1
                img(x1,x2,:) = background_grey;
            end
            if strcmp(stripeType,'grey')
                if Regions(x1,x2) == 0
                    img(x1,x2,:) = [128 128 128];
                end
                if grey(x1,x2) == 1
                    img(x1,x2,:) = background_grey;
                end
                
                if (sqrt((x1-origin_r)^2 + (x2-origin_r)^2) <=inner_r_pix || ((sqrt((x1-origin_r)^2 + (x2-origin_r)^2) - outer_r_pix) >= 0 && ((sqrt((x1-origin_r)^2 + (x2-origin_r)^2) - outer_r_pix) <= 1 )))
                    img(x1,x2,:) = [0 0 0];
                end
            end
            if strcmp(stripeType,'color')
                if Regions(x1,x2) == 0 && grey(x1,x2)==0
                    img(x1,x2,:) = lowLumRGB;
                end
            end
        end
    end

    if normalize
        gabor_img = img./255;
    else
        gabor_img = img;
    end
return

%%
%-------------------------------------------------------------------------%
%Step 4 -- display stimulus
%-------------------------------------------------------------------------%
% figure
% imshow(img)



