
function stimuli = generate_one_angle_nav_stimulus_DKL(theta,rho,gabor_angle,incDKLX,incDKLY,background_grey,monitor,phosphors,fundamentals,my_scaling,gamma_correct)

if gamma_correct
    %gamma correction only necessary for lab computer, not fMRI
    load extras/gammaTableLabPC
end

background_lms = rgb2lms(phosphors,fundamentals,repmat(background_grey,[3,1]));
background_dkl = lms2cartDKL(background_lms,my_scaling');
origin = background_dkl(1:2); %set background chromatic dimensions as origin
luminance = background_dkl(3);

count = 0;

%%Out to first color
for radius = 0:rho-1 %rho frames
    count = count + 1;
    [DKLX, DKLY] = polar2DKL(radius,theta,incDKLX,incDKLY,origin);
    DKL_coords = [DKLX, DKLY, luminance];
    lms = cartDKL2lms(DKL_coords,my_scaling');
    RGB = lms2rgb(phosphors,fundamentals,lms);
    if gamma_correct
        RGB = linearizeOutput(RGB,gammaTable);
    end
    stimuli(count,:,:,:) = colored_gabor(RGB,gabor_angle,6,monitor,0,'grey');
end

end

