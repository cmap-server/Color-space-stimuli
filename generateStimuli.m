

function stimuli = generateStimuli(theta,phi,rho,incrMB,incbMB,luminance,stripeType,phosphors,fundamentals,my_scaling,gammaTable)

count = 0;

%%Out to first color
for radius = 0:rho
    count = count + 1;
    [rMB, bMB] = polar2MB(radius,theta,incrMB,incbMB);
    rgbMB = [rMB, 1-rMB, bMB];
    lms = rgbMB2lms(rgbMB,luminance,my_scaling');
    RGB = lms2rgb(phosphors,fundamentals,lms);
    RGB = linearizeOutput(RGB,gammaTable);
    stimuli(count,:,:,:) = colored_gabor(RGB,45,6,0,stripeType,luminance);
end

% %%From first color back to gray
% for radius = linspace(rho,0,1 + rho)
%     count = count + 1;
%     [rMB, bMB] = polar2MB(radius,theta,incrMB,incbMB);
%     rgbMB = [rMB, 1-rMB, bMB];
%     lms = rgbMB2lms(rgbMB,luminance,my_scaling');
%     RGB = lms2rgb(phosphors,fundamentals,lms);
%     RGB = linearizeOutput(RGB,gammaTable);
%     stimuli(count,:,:,:) = colored_gabor(RGB,45,6,0,stripeType,luminance);
%     
% end

%%Out to second color
for radius = 0:rho
    count = count + 1;
    [rMB, bMB] = polar2MB(radius,phi,incrMB,incbMB);
    rgbMB = [rMB, 1-rMB, bMB];
    lms = rgbMB2lms(rgbMB,luminance,my_scaling');
    RGB = lms2rgb(phosphors,fundamentals,lms);
    RGB = linearizeOutput(RGB,gammaTable);
    stimuli(count,:,:,:) = colored_gabor(RGB,45,6,0,stripeType,luminance);
end

% %%From second color out to gray
% for radius = linspace(rho,0,1 + rho)
%     count = count + 1;
%     [rMB, bMB] = polar2MB(radius,phi,incrMB,incbMB);
%     rgbMB = [rMB, 1-rMB, bMB];
%     lms = rgbMB2lms(rgbMB,luminance,my_scaling');
%     RGB = lms2rgb(phosphors,fundamentals,lms);
%     RGB = linearizeOutput(RGB,gammaTable);
%     stimuli(count,:,:,:) = colored_gabor(RGB,45,6,0,stripeType,luminance);
% end


end