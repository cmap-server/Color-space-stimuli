%Function to transform a point in Macleod-Boynton chromaticity coordinates
%to an arbitrary polar frame defined by the number of computed steps.

%Author: Nick Blauch
%Updated: 3/8/2016

function [theta,rho] = MB2polar(rMB,bMB,incRMB,incBMB)
   origin = [.7 , 1];
   numStepsR = (rMB - origin(1))./incRMB;
   numStepsB = (bMB - origin(2))./incBMB;
   [theta, rho] = cart2pol(numStepsR,numStepsB);
   theta = rad2deg(theta);
   
return
