function [ DKL_coords ] = lms2cartDKL( lms,scaling )
%lms2cartDKL 
%   Convert lms cone excitations to isoluminant DKL space
% DKL_coords = [(l-m),(s-(l+m)),(l+m)]
%author: Nick Blauch. 
%Updated 3/13/2017

% if s is not provided, use default scaling factors valid 
% for the Stockman and Sharpe (2000) 2-deg fundamentals.
% else use s.
if nargin==1
    lms_scaling=[0.689903 0.348322 0.0371597];
else
    lms_scaling = scaling;  
end

% rescale cone excitations.
lms   =  diag(lms_scaling')*lms;
% compute luminance
luminance =  lms(1)+ lms(2); 
% compute rgbMB chromaticities.
DKL_coords(1) = lms(1) - lms(2);
DKL_coords(2) = lms(3) - luminance;
DKL_coords(3) = luminance;

end

