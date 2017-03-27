%Function to transform a point in our arbitrary polar coordinates to a corresponding
%point in Macleod-Boynton chromaticity coordinates.

%Author: Nick Blauch
%Updated 3/8/2016


function [rMB,bMB] = polar2MB(rho,theta,incRMB,incBMB)
    origin = [.7, 1];
    
    theta = deg2rad(theta);
    
    [numStepsR, numStepsB] = pol2cart(theta,rho);
    rMB = origin(1) + numStepsR*incRMB;
    bMB = origin(2) + numStepsB*incBMB;
return