%Script to generate stimuli files for all angles for DKL space
%created 3/14/17 as a model after generateAllStimuli (for MB space)
%Author: Nick Blauch

clear all

monitor = 'fMRI';
stripeType = 'grey';
runTime = 1; %seconds for out to one color and back, frame rate of 120 hz
gabor_size_deg = 15;
fullField = 1;

if strcmp(monitor,'fMRI')
    load extras/phosphors_fMRI_monitor
    load extras/scaling_fMRI_monitor    %load scaling which matches Boehm et. al 2014.
    background_grey = 128;
elseif strcmp(monitor,'cemnl')
    load extras/phosphors_cemnl
    load extras/scaling_cemnl
    background_grey = 50;
end

load extras/SMJfundamentals
addpath('color_toolbox_v1')
    
[incDKLX, incDKLY, origin, luminance, stepRadius] = findMaxDKLDisc(background_grey,monitor,1,1);


for phase_shift = [0 1]
    for gabor_angle = [90 180]
        for theta = 0:15:345
            stimuli = generate_one_angle_nav_stimulus_DKL(theta,stepRadius,gabor_angle,gabor_size_deg,phase_shift,incDKLX,incDKLY,background_grey,monitor,phosphors,fundamentals,my_scaling,0,fullField);
            if phase_shift
                fileName = strcat(monitor,'_stimuli_DKL_fullField/','T',num2str(theta),'O',num2str(gabor_angle),'ST',stripeType,'shifted');
            else
                fileName = strcat(monitor,'_stimuli_DKL_fullField/','T',num2str(theta),'O',num2str(gabor_angle),'ST',stripeType);
            end
            save(fileName,'stimuli')
        end
    end
end


