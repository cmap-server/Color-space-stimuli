function [ gabor ] = make_gabor( imSize, lambda, amp, theta, sigma, phase, show, prp)
% Purpose:
%   Function to generate a gabor patch overlaid with visual white noise.
%   Adapted from Matlab code provided by Freeman (2007)
% Arguments:
%  imSize  - the size in pixels of the final (square) image
%  lambda  - Forthcoming
%  amp     - The amplitude for the sine wave making the grating
%  theta   - The orientation in degrees (0 = straight, + rotated clockwise,
%            rotated counter-clockwise).
%  sigma   - Standard deviation for the gaussian filter (larger values
%            lead to more of the gabor patch being exposed).
%  phase   - Forthcoming
%  show    - Set to 1 to generate a figure displaying the output.
%  prp     - Set to 1 to rescale the intensity matrix to be between 0 and 
%            1 instead of -1 and 1.
%  cntrst - A vector of 2 coefficients for the beta rng function (use
%            [ 1, 1 ] for uniform (i.e. white noise).
% References:
%   Freeman, E. (2007, February). Steps to making a gabor patch. Retrieved 
%   from http://www.icn.ucl.ac.uk/courses/MATLAB-Tutorials/Elliot_Freeman/html/gabor_tutorial.html

% Make linear ramp
X = 1:imSize;           % X is a vector from 1 to imageSize
X0 = (X / imSize) - .5; % Rescale X -> -.5 to .5

freq = imSize/lambda;        % Compute frequency from wavelength
phaseRad = (phase * 2* pi); % Convert phase to radians: 0 -> 2*pi

% Create a grid for grating
[ Xm, Ym ] = meshgrid(X0, X0);

% Put 2D grating through sine
thetaRad = (theta / 360) * 2*pi; % Convert theta (orientation) to radians
Xt = Xm * cos(thetaRad);         % Compute proportion of Xm for given orientation
Yt = Ym * sin(thetaRad);         % Compute proportion of Ym for given orientation
XYt = Xt + Yt;                   % Sum X and Y components
XYf = XYt * freq * 2*pi;         % Convert to radians and scale by frequency
grating = amp*sin( XYf + phaseRad);  % Make 2D sinewave

s = sigma / imSize; % Gaussian width as fraction of imageSize
gauss = exp( -(((Xm.^2)+(Ym.^2)) ./ (2* s^2)) ); % formula for 2D Gaussian

gabor = grating.*gauss;
gabor(gabor < -1) = -1; gabor(gabor > 1)=1;
% gabor_prp = (1 + gabor)/2;

% Create gabor patch by combining 2D Gaussian and the 2D sinewave
% gauss = 1 - gauss; % Switch color gradient to white transitioning to grey
% grating_prp = (1 + grating)/2; % Convert to proportion: 0 = Black, 1 = white
% gabor_prp = grating_prp.*(1-gauss);
% gabor = -1*(2*gabor_prp - 1);

% Create noise using beta distribution
% B = ones(imSize)*cntrst(2);
% B = repmat(cntrst(2),imSize);
% Noise = betarnd(cntrst(1),B);
% Noise = (Noise.*2) - 1;
% Noise = normrnd(cntrst(1),B);
% Noise(Noise < -1) = -1;
% Noise(Noise > 1) = 1;
% Noise = (1 + Noise)/2;

% gabor = gabor.*Noise;
% gabor = 2*((1-gabor_prp).*Noise) - 1;
% gabor = 2*(gabor_prp.*Noise) - 1;

% gabor(gabor > Noise) = Noise( gabor > Noise);

if show==1
    colormap gray(256);                     % use gray colormap (0: black, 1: white)
    imagesc( gabor, [-1 1] );                        % display
end

if prp==1
    gabor = (1 + gabor)/2; % Convert to proportion
end

end
