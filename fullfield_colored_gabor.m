%adapted from colored_gabor to produce full field images for a given
%monitor (CEMNL or fMRI BOLD screen)


function gabor_img = fullfield_colored_gabor(RGB, orientation_deg,phase_shift,monitor,normalize,stripeType,MBluminance)
    %%
    %-------------------------------------------------------------------------%
    %Step 0 -- Set experimental conditions
    %-------------------------------------------------------------------------%
    if exist('DKL','var')==0
        DKL = 0;
    end
    
    if nargin<5
        stripeType = 'black';
        if nargin<4
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
    
    color = RGB; %specified by 1x3 vector input
    contrast = 1;
    theta = orientation_deg + 90; %orientation angle is 90 deg shifted from math angle
    inner_r_ang = .1; % deg, size of inner radius
    lambda_vis_ang = 1; %deg/cycle
    %%monitor specific settings
    %determine pixel values for lambda and imSize
    if strcmp(monitor,'fMRI')
        view_dist_mm = 1370; %mm
        screenwidth = 700; %mm
        screenres_x = 1920; %pixels
        max_BOLD_vis_angle_width = 28; %deg
        max_BOLD_vis_angle_height = 16; %deg
        screenres_y = (max_BOLD_vis_angle_height/max_BOLD_vis_angle_width)*screenres_x;
        lambda = round((lambda_vis_ang./max_BOLD_vis_angle_width)*screenres_x);
        imSize = screenres_x; %will make large square grating and chop for laziness
        background_grey = 128;
    elseif strcmp(monitor,'CEMNL') 
        view_dist_mm = 700; %mm
        screenwidth = 533; %mm
        set(0,'units','pixels')
        screenres_x = screenres(3); %pixels
        screenres_y = screenres(4); %pixels
        background_grey = 50;
        imSize = screenres_x; %full field
        [lambda,~] = visangle2stimsize(lambda_vis_ang,lambda_vis_ang,view_dist_mm,screenwidth,screenres_x);
    end
    
    %%
    %-------------------------------------------------------------------------%
    %Step 1 -- create a greyscale sinusoidal grating
    %-------------------------------------------------------------------------%

    amp = 1; %amplitude
    sigma = 10000; %decay constant for gaussian envelope. very large for no envelope.
    if phase_shift
        phase = .25*lambda; %phase; initial offset of .25*lambda to center. adding .5*lambda flips stripes. 
    else
        phase = .75*lambda; %phase; initial offset of .25*lambda to center. adding .5*lambda flips stripes. 
    end
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
    %%Step 2.5 -- create a circular aperture
    %-------------------------------------------------------------------------%

    inner_r_pix = visangle2stimsize(inner_r_ang,inner_r_ang,view_dist_mm,screenwidth,screenres_x);
    origin_r = imSize/2; %pix
    [rr cc] = meshgrid(1:imSize);
    circ_mask = (sqrt((rr-origin_r).^2+(cc-origin_r).^2)) <= inner_r_pix;
    %%Set annulus values of 1 to background
    for index1=1:imSize
        for index2=1:imSize
            if(circ_mask(index1,index2)==1)
                gabor(index1,index2) = 0;
            end
        end
    end
    
    gabor(circ_mask) = 0;
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
            end
%             if strcmp(stripeType,'color')
%                 if Regions(x1,x2) == 0 && grey(x1,x2)==0
%                     img(x1,x2,:) = lowLumRGB;
%                 end
%             end
        end
    end

    if normalize
        gabor_img = img./255;
    else
        gabor_img = img;
    end
    
    sizey = size(gabor_img,1);
    gabor_img = gabor_img(ceil(sizey/2)-(ceil(screenres_y/2)):ceil(sizey/2)+(ceil(screenres_y/2)),:,:);
    
    gabor_img = uint8(gabor_img);
    
    
return

%%
%-------------------------------------------------------------------------%
%Step 4 -- display stimulus
%-------------------------------------------------------------------------%
% figure
% imshow(img)



