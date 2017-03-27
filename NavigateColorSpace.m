%Navigates Macleod-Boynton color space. Plays a PTB movie where a
%square-wave grating appears, where one set of bars on the grating is
%colored by a point in Macleod-Boynton color space. Two angles are picked,
%theta and phi. The movie navigates through MB space from the origin to
%theta, back to the origin and then to phi, back to the origin and so on,
%until a set time is elapsed.
%Calls: findMaxMBDisc, generateStimuli, PTBNavigation
%Updated 4/10/2016
%functional as of 3/14/17
%2Author: Nick Blauch
clear all

luminance = .4;
theta = 120;
phi = 60;
stripeType = 'grey';
saveFile = 0;
runTrial = 1;
runTime = 1; %seconds for out to one color and back


load extras/phosphors_cemnl
load extras/SMJfundamentals
load extras/scaling_cemnl    %load scaling which matches Boehm et. al 2014.
load extras/gammaTableLabPC

axisRatio = 80/3; %to produce a square plot in MB space corresponding to square MDS plot (Boehm et. al, 2014).
origin = [.7, 1];

%initial guesses
incrMB = .0005;
incbMB = incrMB*axisRatio;

[incrMB, incbMB, rho] = findMaxMBDisc(luminance,'cemnl',0,runTime,incrMB,incbMB);

stimuli = generateStimuli(theta,phi,rho,incrMB,incbMB,luminance,stripeType,phosphors,fundamentals,my_scaling,gammaTable);
if saveFile
    save(strcat('stim','T',num2str(theta),'P',num2str(phi),'R',num2str(rho),'L',num2str(10*luminance),'ST',stripeType));
end

% if runTrial
%     realDifference = round(rand);
% 
%     if realDifference
%     PTBNavigation(stimuli);
%     else
%     PTBNavigation(stimuli2);
%     end
% end

PTBNavigation(stimuli);

