function [lms] = cartDKL2lms(DKL_coords,scaling)
%cartDKL2lms 
%   Convert isoluminant DKL space to lms cone activations
% DKL_coords = [(l-m),(s-(l+m)),(l+m)]
%author: Nick Blauch. 
%Updated 3/13/2017

% check number of input arguments.
% if s is not provided, use default scaling factors valid 
% for the Stockman and Sharpe (2000) 2-deg fundamentals.
% else use s.
if nargin==1
    lms_scaling=[0.689903 0.348322 0.0371597];
    
else
    lms_scaling = scaling;  
end
% compute scaled LMS from rgbMB and luminance.
lms_scaled(1) = (DKL_coords(1) + DKL_coords(3))/2;
lms_scaled(2) = (DKL_coords(3) - DKL_coords(1))/2;
lms_scaled(3) = DKL_coords(2) + DKL_coords(3);
% to obtain LMS excitations the previous LMS values need to be unscaled.
% define LMS scaling according to which fundamentals are used.
lms = lms_scaled./(lms_scaling);

