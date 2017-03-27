
function stimuli = generate_one_angle_nav_stimulus_MB(theta,rho,gabor_angle,incrMB,incbMB,luminance,stripeType,phosphors,fundamentals,my_scaling,gamma_correct)

if gamma_correct
    %gamma correction only necessary for lab computer, not fMRI
    load extras/gammaTableLabPC
end

count = 0;

%%Out to first color
for radius = 0:rho
    count = count + 1;
    [rMB, bMB] = polar2MB(radius,theta,incrMB,incbMB);
    rgbMB = [rMB, 1-rMB, bMB];
    lms = rgbMB2lms(rgbMB,luminance,my_scaling');
    RGB = lms2rgb(phosphors,fundamentals,lms);
    if gamma_correct
        RGB = linearizeOutput(RGB,gammaTable);
    end
    stimuli(count,:,:,:) = colored_gabor(RGB,gabor_angle,6,0,stripeType,luminance);
end

end