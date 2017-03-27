% Quick convenience function to convert stimulus size in pixels to degrees
% visual angle. If the screen and distance parameters are undefined, we use
% the CBU scanner settings (see 
% http://imaging.mrc-cbu.cam.ac.uk/mri/CbuStimulusDelivery). If using default
% CBU scanner parameters, the sizey input is also optional.
% use: [visanglex,visangley] = stimsize2visangle(sizex,[sizey],[totdistmm],[screenwidthmm],[screenres])
% 25/9/2009 J Carlin

function [visanglex,visangley] = stimsize2visangle(sizex,sizey,totdist,screenwidth,screenres)

if nargin < 3
	% mm
	distscreenmirror=823;
	distmirroreyes=90;
	totdist=distscreenmirror+distmirroreyes;
	screenwidth=268;

	% pixels
	screenres=1024;
end

visang_rad = 2 * atan(screenwidth/2/totdist);
visang_deg = visang_rad * (180/pi);

visang_perpix = visang_deg / screenres;

visanglex = sizex * visang_perpix;

if nargin > 1
	visangley = sizey * visang_perpix;
end
