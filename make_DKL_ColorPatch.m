
function [img4tex, img2show, colors, fails] = make_DKL_ColorPatch(background_grey,monitor,display)


[incDKLX, incDKLY, origin, luminance, stepRadius] = findMaxDKLDisc(background_grey,monitor,0,1);

if strcmp(monitor,'cemnl')
    load extras/phosphors_cemnl
    load extras/scaling_cemnl     %load scaling which matches Boehm et. al 2014.
elseif strcmp(monitor,'fMRI')
    load extras/phosphors_fMRI_monitor
    load extras/scaling_fMRI_monitor     %load scaling which matches Boehm et. al 2014.
end

load extras/SMJfundamentals
%gamma table not needed for fMRI, which is pre-linearized
if ~strcmp(monitor,'fMRI')
    load extras/gammaTableLabPC
end

set(0,'units','pixels')
screenRes = get(0,'screensize');
screenResX = screenRes(3);
screenResY = screenRes(4);
num_colors = 24;
radiusPix = round(screenResX./74);%leave space in between circles
yCent = round(screenResY/2);
inc = 3*radiusPix; %pixel separation between blob centers
img2show = zeros(screenResY,screenResX,3);
img4tex = zeros(screenResX,screenResY,3);

startPoint = 2*radiusPix;

fails = 0;
colors = cell(num_colors,1);

for i = 1:num_colors
    theta = (i-1)*(360/num_colors);
    centerPixel = startPoint + (i-1)*inc;
    [DKLX,DKLY] = polar2DKL(stepRadius,theta,incDKLX,incDKLY,origin);
    lms = cartDKL2lms([DKLX,DKLY,luminance],my_scaling');
    RGB = lms2rgb(phosphors,fundamentals,lms);
    if strcmp(monitor,'cemnl')
        RGB = linearizeOutput(RGB,gammaTable);
    end
    
    if(any(RGB(:)>255) || any(RGB(:)<0))
        fails = fails + 1;
        RGB
    end

    colors{i} = RGB;
    
    img2show(yCent-radiusPix:yCent+radiusPix,centerPixel-radiusPix:centerPixel+radiusPix,1) = RGB(1);
    img2show(yCent-radiusPix:yCent+radiusPix,centerPixel-radiusPix:centerPixel+radiusPix,2) = RGB(2);
    img2show(yCent-radiusPix:yCent+radiusPix,centerPixel-radiusPix:centerPixel+radiusPix,3) = RGB(3);
    
    img4tex(centerPixel-radiusPix:centerPixel+radiusPix,yCent-radiusPix:yCent+radiusPix,1) = RGB(1);
    img4tex(centerPixel-radiusPix:centerPixel+radiusPix,yCent-radiusPix:yCent+radiusPix,2) = RGB(2);
    img4tex(centerPixel-radiusPix:centerPixel+radiusPix,yCent-radiusPix:yCent+radiusPix,3) = RGB(3);
    
end

img4tex = img2show;
% img4tex(img4tex==0) = 122.5;
img4tex = img4tex(round(.45*screenResY):round(.55*screenResY),:,:);

img2show(img2show==0) = background_grey;
img2show = img2show./255;
img2show = img2show(1:screenResY,:,:);

if display
   figure; imshow(img2show) 
end


end