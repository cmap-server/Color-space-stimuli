% ================================================================
% *** FUNCTION lms2rgb
% ***
% *** function [rgb] = lms2rgb(phosphors,fundamentals,lms)
% *** computes rgb from lms.
% *** phosphors is an n by 3 matrix containing 
% *** the three spectral power distributions of the display device
% *** fundamentals is an n x 3 matrix containing
% *** the lms are the cone spectral sensitivities.
% *** the rgb are the rgb values of the display device.
% ================================================================
function [rgb] = lms2rgb(phosphors,fundamentals,lms)

% Compute lms from rgb.
rgbTOlms = fundamentals'*phosphors; 
lmsTOrgb = rgbTOlms\eye(3);
rgb      = lmsTOrgb * lms';
% minverse= [13.5896552930608	-22.9767589472682	9.01531967054780
% -0.336346440945981	3.23750392942789	-2.74436773989818
% 0.0125538134636033	-0.237892292039156	69.1395442065079];
% rgb = minverse * lms';

rgb = rgb';



% ===================================================
% *** END FUNCTION lms2rgb
% ===================================================