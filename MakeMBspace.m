%Production of a Macleod-Boynton isoluminant color space.
%Author: Nick Blauch
%Updated 4/19/2016 w/ ability to create annuli
%Updated 10/31/2016 w/ ability to change monitor (options 'fMRI', 'cemnl')

function img = MakeMBspace(luminance,monitor,rMB,bMB)


%%
%-------------------------------------------------------------------------%
gammaCorrect = 0;
if ~strcmp(monitor,'fMRI')
    gammaCorrect = 1; %1 to gamma correct, 0 to not gamma correct.
end
showOnlyValidColors = 1; %one to make non-valid colors black
showOnlyDisc = 1; %one to black out points outside of disc
showOnlyAnnulus = 0; %one to black out points inside a thin annulus

%If we show only disc, set boundaries realistically and decrease increment
%to enlarge the plot
if showOnlyDisc
    incrMB = .0001;
    axisRatio = 80/3; %from Boehm et. al, 2014
    incbMB = incrMB*axisRatio;
    if nargin==2
        rMB = .65:incrMB:.75;
        bMB = 0:incbMB:2;
    end 
%Otherwise show a large range of values with a smaller increment
else
    incrMB = .001;
    axisRatio = 80/3; %from Boehm et. al, 2014
    incbMB = incrMB*axisRatio;
    if nargin==2
        rMB = 0:incrMB:1;
        bMB = -10:incbMB:5;
    end
end

origin = [.7, 1];

[incrMBsub, ~, stepRadius] = findMaxMBDisc(luminance,monitor,0,1,incrMB,incbMB);
discRadiusR = stepRadius*incrMBsub;
stepRadius = discRadiusR/incrMB;


%-------------------------------------------------------------------------%
if strcmp(monitor,'cemnl')
    load extras/phosphors_cemnl
    load extras/scaling_cemnl
    load extras/gammaTableLabPC
elseif strcmp(monitor,'fMRI')
    load extras/phosphors_fMRI_monitor
    load extras/scaling_fMRI_monitor
end

load extras/SMJfundamentals
wavelength = 390:730;

%%
%Produce color maps

%Create matrices to store R, G, B values over the MB space.
Rsurface = zeros(length(rMB),length(bMB));
Gsurface = zeros(length(rMB),length(bMB));
Bsurface = zeros(length(rMB),length(bMB));

count1 = 0;
for r = rMB
    count1 = count1 + 1;
    count2 = 0;
    for b = bMB
      count2 = count2 + 1;
      rgbMB = [r, 1-r, b];
      lms = rgbMB2lms(rgbMB,luminance,my_scaling');
      RGB = lms2rgb(phosphors,fundamentals,lms);
      try
          if gammaCorrect
             RGB = linearizeOutput(RGB,gammaTable);
          end
          Rsurface(count1,count2) = RGB(1);
          Gsurface(count1,count2) = RGB(2);
          Bsurface(count1,count2) = RGB(3);
          if (r == .7 && b == 1)
              Rsurface(count1,count2) = 255;
              Gsurface(count1,count2) = 255;
              Bsurface(count1,count2) = 255;
          end
          if (Rsurface(count1,count2)<0 || Rsurface(count1,count2)>255 || Gsurface(count1,count2)<0 || Gsurface(count1,count2)>255 || Bsurface(count1,count2)<0 || Bsurface(count1,count2)>255)
              if showOnlyValidColors
                  Rsurface(count1,count2) = 0;
                  Gsurface(count1,count2) = 0;
                  Bsurface(count1,count2) = 0;
              end
          end
      catch
            Rsurface(count1,count2) = 0;
            Gsurface(count1,count2) = 0;
            Bsurface(count1,count2) = 0;
      end

      [~, testRadius] = MB2polar(r,b,incrMB,incbMB);
      if testRadius>stepRadius
          if showOnlyDisc
            Rsurface(count1,count2) = 0;
            Gsurface(count1,count2) = 0;
            Bsurface(count1,count2) = 0;
          end
      end
      if testRadius<stepRadius-10
          if showOnlyAnnulus
            Rsurface(count1,count2) = 0;
            Gsurface(count1,count2) = 0;
            Bsurface(count1,count2) = 0;
          end 
      end
    end
end

%%
%plotting the isoluminant plane

img = zeros(length(bMB),length(rMB),3);

img(:,:,1) = Rsurface'./255;
img(:,:,2) = Gsurface'./255;
img(:,:,3) = Bsurface'./255;

figure
hold on
iptsetpref('ImshowAxesVisible','on');
imshow(img);
xlabel('L/L+M')
ylabel('S/L+M')
xlim([0, length(rMB)])
ylim([0, length(bMB)])
set(gca,'YDir','normal')
%relabel axes in terms of MB coordinates
ax = gca;
ax.XTick = round([0 length(rMB)/4 2*length(rMB)/4 3*length(rMB)/4 length(rMB)],1);
ax.YTick = round([0 length(bMB)/4 2*length(bMB)/4 3*length(bMB)/4 length(bMB)],1);
MB1inc = (rMB(length(rMB)) - rMB(1))/4;
labelsMB1 = rMB(1):MB1inc:rMB(length(rMB));
MB2inc = (bMB(length(bMB)) - bMB(1))/4;
labelsMB2 = bMB(1):MB2inc:bMB(length(bMB));
ax.XTickLabel = labelsMB1;
ax.YTickLabel = labelsMB2;

if gammaCorrect
    titleString = strcat('Gamma corrected isoluminant plane',' luminance = ',num2str(luminance));
    title(titleString)
else
    titleString = strcat('Gamma uncorrected isoluminant plane',' luminance = ',num2str(luminance));
    title(titleString)
end
hold off

return