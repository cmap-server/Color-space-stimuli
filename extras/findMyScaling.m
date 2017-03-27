
%This file computes the scaling for a set of cone fundamentals and phosphor
%spectral distributions.

%This calculation makes it such that luminance = 1 is the maximum possible
%luminance, where the white point (RGB = [255 255 255]) corresponds to [.7 .3 1] in
%macleod-boynton coordinates, as in Boehm et. al (2014). 

function scaling = findMyScaling(phosphor_measurements,SMJ_fundamentals)

% phosphors_toolbox = load('phosphors_toolbox'); phosphors_toolbox = phosphors_toolbox.phosphors;

M_measurements = SMJ_fundamentals'*phosphor_measurements;
vector =  M_measurements*[255 255 255]';
s1 = .7/vector(1);
s2 = .3/vector(2);
s3 = 1/vector(3);
scaling = [s1 s2 s3];

% M_toolbox = fundamentals'*phosphors_toolbox;
% vector =  M_toolbox*[255 255 255]';
% s1 = .7/vector(1);
% s2 = .3/vector(2);
% s3 = 1/vector(3);
% scaling_toolbox = [s1 s2 s3];

% save('scaling_cemnl','scaling_cemnl');

return

