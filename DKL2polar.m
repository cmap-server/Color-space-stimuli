%Function to transform a point in DKL chromaticity coordinates
%to an arbitrary polar (slice of cylindrical) frame defined by the number of computed steps.

%Author: Nick Blauch
%Updated: 3/13/2017

function [theta,rho] = DKL2polar(DKLX,DKLY,incDKLX,incDKLY,origin)
numStepsR = (DKLX - origin(1))./incDKLX;
numStepsB = (DKLY - origin(2))./incDKLY;
[theta, rho] = cart2pol(numStepsR,numStepsB);
theta = rad2deg(theta);

return
