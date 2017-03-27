%Script to generate stimuli files for all angles
%Updated 10/31/2016
%Author: Nick Blauch

clear all

 luminance = .1;
gabor_angle = 90;
monitor = 'fMRI';
stripeType = 'black';
runTime = 1; %seconds for out to one color and back, frame rate of 120 hz
color_space = 'MB';

load extras/SPDs_fMRI_mirror_dark
load extras/scaling_fMRI_monitor    %load scaling which matches Boehm et. al 2014.

load extras/SMJfundamentals

axisRatio = 80/3; %to produce a square plot in MB space corresponding to square MDS plot (Boehm et. al, 2014).
origin = [.7, 1];

%initial guesses
incrMB = .0005;
incbMB = incrMB*axisRatio;

incrMB_store = zeros(1,4);
incbMB_store = zeros(1,4);
rho = zeros(1,4);

count = 0;
for luminance = [.1, .2, .3, .4]
    count = count + 1;
    if strcmp(color_space,'MB')
        [incrMB_store(count), incbMB_store(count), rho(count)] = findMaxMBDisc(luminance,'fMRI',1,1,incrMB,incbMB);
    elseif strcmp(color_space,'DKL')
         [incrMB_store(count), incbMB_store(count), rho(count)] = findMaxDKLDisc(luminance,'fMRI',0,1,incrMB,incbMB);
    end
end

count = 0;
for luminance = [.4]
    count = 4;
    for gabor_angle = [0 90]
        
        angles = 0:15:345;

        for i = 1:length(angles)
            theta = angles(i);
            stimuli = generate_one_angle_nav_stimulus(theta,rho(count),gabor_angle,incrMB_store(count),incbMB_store(count),luminance,stripeType,SPDs_fMRI_mirror_dark,fundamentals,my_scaling,0);
            save(strcat('fMRI_stimuli_6deg/','T',num2str(theta),'R',num2str(rho(count)),'O',num2str(gabor_angle),'L',num2str(10*luminance),'ST',stripeType),'stimuli');
        end
    end
end


