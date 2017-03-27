function stimuli = getGeneratedStimuli(theta,phi,luminance,monitor,stripeType)

if strcmp(monitor,'cemnl')
    fileName = strcat('gabor stimuli/stim','T',num2str(theta),'P',num2str(phi),'R',num2str(60),'L',num2str(10*luminance),'ST',stripeType);
elseif strcmp(monitor,'fMRI')
    fileName = strcat('fMRI_stimuli/T',num2str(theta),'R60','O90','L',num2str(luminance*10),'ST',stripeType);
end

load(fileName,'stimuli');


end