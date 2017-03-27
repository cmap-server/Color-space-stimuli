function [img4tex, img2show] = makeColorPatch(rho,luminance,incrMB,incbMB)

load extras/phosphors_cemnl
load extras/SMJfundamentals
load extras/scaling_cemnl    %load scaling which matches Boehm et. al 2014.
load extras/gammaTableLabPC

set(0,'units','pixels')
screenRes = get(0,'screensize');
screenResX = screenRes(3);
screenResY = screenRes(4);
numColors = 24;
radiusPix = round(screenResX./74);%leave space in between circles
yCent = round(screenResY/2);
inc = 3*radiusPix; %pixel separation between blob centers
img2show = zeros(screenResY,screenResX,3);
img4tex = zeros(screenResX,screenResY,3);

startPoint = 2*radiusPix;

fails = 0;
centerPixel = startPoint;

rMB = .7-incrMB*rho:incrMB:.7+incrMB*rho;
bMB = 1-incbMB*rho:incbMB:1+incbMB*rho;

% MakeMBspace(luminance,rMB,bMB);

for i = 1:24
    theta = (i-1)*15;
    centerPixel = startPoint + (i-1)*inc;
    [rMB, bMB] = polar2MB(rho,theta,incrMB,incbMB);
    rgbMB = [rMB, 1-rMB, bMB];
    lms = rgbMB2lms(rgbMB,luminance,my_scaling');
    RGB = lms2rgb(phosphors,fundamentals,lms);
    if(any(RGB(:)>255) || any(RGB(:)<0))
%         fails = fails + 1;
%         [rho theta]
    end
    RGB = linearizeOutput(RGB,gammaTable);    
%     img(centerPixel:centerPixelNew,yCent-radiusPix:yCent+radiusPix,1) = RGB(1);
%     img(centerPixel:centerPixelNew,yCent-radiusPix:yCent+radiusPix,2) = RGB(2);
%     img(centerPixel:centerPixelNew,yCent-radiusPix:yCent+radiusPix,3) = RGB(3);
    
    img2show(yCent-radiusPix:yCent+radiusPix,centerPixel-radiusPix:centerPixel+radiusPix,1) = RGB(1);
    img2show(yCent-radiusPix:yCent+radiusPix,centerPixel-radiusPix:centerPixel+radiusPix,2) = RGB(2);
    img2show(yCent-radiusPix:yCent+radiusPix,centerPixel-radiusPix:centerPixel+radiusPix,3) = RGB(3);
    
    img4tex(centerPixel-radiusPix:centerPixel+radiusPix,yCent-radiusPix:yCent+radiusPix,1) = RGB(1);
    img4tex(centerPixel-radiusPix:centerPixel+radiusPix,yCent-radiusPix:yCent+radiusPix,2) = RGB(2);
    img4tex(centerPixel-radiusPix:centerPixel+radiusPix,yCent-radiusPix:yCent+radiusPix,3) = RGB(3);
    
end
fails;

img4tex = img2show;
% img4tex(img4tex==0) = 122.5;
img4tex = img4tex(round(.45*screenResY):round(.55*screenResY),:,:);

img2show = img2show./255;
img2show(img2show==0) = .5;
img2show = img2show(1:screenResY,:,:);




end