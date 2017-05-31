
%create orientation-tuning stimuli
%which are just black/white gabors

wavelength = 1; %deg/cycle

for orientation = [90, 180]
    for phase_mult = [0,1,2,3]
        for contrast = [1, .5]
            
            background_grey = 128;
            gabor_size_ang = 15;
            inner_r_ang = .1; % deg, size of inner radius
            outer_r_ang = gabor_size_ang/2 - inner_r_ang; %deg, size of outer radius
            box_size_ang = gabor_size_ang + .1*gabor_size_ang; %Box is slightly bigger than gabor
            
            %%BOLD settings
            view_dist_mm = 1370; %mm
            screenwidth = 700; %mm
            screenres = 1920; %pixels
            max_BOLD_vis_angle_width = 28; %deg
            sizex = round((wavelength./max_BOLD_vis_angle_width)*screenres);
            imSize = round((box_size_ang./max_BOLD_vis_angle_width)*screenres);
            
            
            %%
            %-------------------------------------------------------------------------%
            %Step 1 -- create a greyscale sinusoidal grating
            %-------------------------------------------------------------------------%
            
            lambda = sizex; %spatial wavelength
            theta = orientation + 90;
            phase = phase_mult*(wavelength/4);
            amp = 1; %amplitude
            sigma = 10000; %decay constant for gaussian envelope. very large for no envelope.
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
                    if (sqrt((x1-origin_r)^2 + (x2-origin_r)^2) <=inner_r_pix || ((sqrt((x1-origin_r)^2 + (x2-origin_r)^2) - outer_r_pix) >= 0 && ((sqrt((x1-origin_r)^2 + (x2-origin_r)^2) - outer_r_pix) <= 1 )))
                        img(x1,x2,:) = [0 0 0];
                    end
                end
            end
            
            img = uint8(img);
            
            save(strcat('Orientation_tuning_stim_15deg/orientation',num2str(orientation),'phase',num2str(phase_mult),'contrast',num2str(1+floor(contrast))),'img')
        end
    end
end
