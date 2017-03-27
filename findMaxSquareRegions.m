%Code to find the maximum square region of a given luminance
%Stimuli will then be chosen along the border of the maximum circle
%contained within this square region
%%Outdated
%%Updated 3/10/2016
%Author: Nick Blauch


gamma = 2.4; %estimated
gammaCorrect = 1; %1 to gamma correct, 0 to not gamma correct.
showOnlyValidColors = 1; %one to make non-valid colors black

load extras/phosphors_cemnl
load extras/SMJfundamentals
%load scaling which matches Boehm et. al 2014. 
load extras/my_scaling

axisRatio = 80/3; %to produce a square plot in MB space corresponding to square MDS plot (Boehm et. al, 2014).

luminances = .1:.1:.9; %Range = 0:1. Can get full valid MB-space up to at least luminance= .5

origin = [.7 1];

incrMB = .0005;
rMB = .2:incrMB:1; 

incbMB = incrMB*axisRatio;
bMB = 0:incbMB:5; % b coordinate in MB space; s/l+m

%%
lumCount = 0;
fails = zeros(length(luminances),1);
bhalfSideLengths = zeros(length(luminances),1);
rhalfSideLengths = zeros(length(luminances),1);
bMBTests = zeros(length(luminances),100);
rMBTests = zeros(length(luminances),100);

for luminance = luminances
    lumCount = lumCount+1;
   bMBToTry = origin(2):-incbMB:0;
   r = origin(1);
   for b = bMBToTry
      rgbMB = [r, 1-r, b];
      lms = rgbMB2lms(rgbMB,luminance,my_scaling');
      RGB = lms2rgb(phosphors,fundamentals,lms);
      if gammaCorrect
        RGB = (255.*((RGB./255).^(1/gamma)));
      end
      
      if(any(RGB(:)>255) || any(RGB(:)<0))
          break
      end
   end
   bhalfSideLength = (origin(2) - b);
   rhalfSideLength = bhalfSideLength/axisRatio;
   bMBTest = (origin(2)-bhalfSideLength):incbMB:(origin(2) + bhalfSideLength);
   %bMBTests(count,:) = bMBTest;
   rMBTest = (origin(1)-rhalfSideLength):incrMB:(origin(1) + rhalfSideLength);
   %rMBTests(count,:) = rMBTest;
   for r = rMBTest
       for b = bMBTest
          rgbMB = [r, 1-r, b];
          lms = rgbMB2lms(rgbMB,luminance,my_scaling');
          RGB = lms2rgb(phosphors,fundamentals,lms);
          if gammaCorrect
            RGB = (255.*((RGB./255).^(1/gamma)));
          end
          if(any(RGB(:)>255) || any(RGB(:)<0))
              fails(lumCount) = fails(lumCount) + 1;
              %break
          end
       end 
   end
   bhalfSideLengths(lumCount) = bhalfSideLength;
   rhalfSideLengths(lumCount) = rhalfSideLength;
   MakeMBspace(luminance,origin(1)-rhalfSideLength:incrMB:origin(1)+rhalfSideLength,origin(2)-bhalfSideLength:incbMB:origin(2)+bhalfSideLength)

end

