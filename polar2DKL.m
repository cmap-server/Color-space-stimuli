%Function to transform a point in our arbitrary polar coordinates to a corresponding
%point in DKL chromaticity coordinates.

%Author: Nick Blauch
%Updated 3/13/2017


function [DKLX,DKLY] = polar2DKL(rho,theta,incDKLX,incDKLY,origin)
    theta = deg2rad(theta);
    [numStepsX, numStepsY] = pol2cart(theta,rho);
    DKLX = origin(1) + numStepsX*incDKLX;
    DKLY = origin(2) + numStepsY*incDKLY;
return