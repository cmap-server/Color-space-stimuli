%Production of a DKL isoluminant color space.
%Author: Nick Blauch
%created 3/13/2017 as a model after MakeMBspace

function img = MakeDKLspace(background_grey,monitor,DKLX,DKLY)


%%
%-------------------------------------------------------------------------%
gammaCorrect = 0;
if ~strcmp(monitor,'fMRI')
    gammaCorrect = 1; %1 to gamma correct, 0 to not gamma correct.
end
showOnlyValidColors = 1; %one to make non-valid colors black
showOnlyDisc = 1; %one to black out points outside of disc
showOnlyAnnulus = 1; %one to black out points inside a thin annulus

%-------------------------------------------------------------------------%
if strcmp(monitor,'cemnl')
    load extras/phosphors_cemnl
    load extras/scaling_cemnl
    load extras/gammaTableLabPC
elseif strcmp(monitor,'fMRI')
    load extras/phosphors_fMRI_monitor
        load extras/scaling_fMRI_monitor
%     load extras/scaling_cemnl
    
end

load extras/SMJfundamentals
wavelength = 390:730;

background_lms = rgb2lms(phosphors,fundamentals,repmat(background_grey,[3,1]));
background_dkl = lms2cartDKL(background_lms,my_scaling');
origin = background_dkl(1:2); %set background chromatic dimensions as origin
luminance = background_dkl(3);

if nargin<3
    [incDKLX, incDKLY, origin, luminance, stepRadius] = findMaxDKLDisc(background_grey,monitor,0,1);
    DKLX = origin(1)-incDKLX*stepRadius:incDKLX:origin(1) + stepRadius*incDKLX;
    DKLY = origin(2)-incDKLY*stepRadius:incDKLY:origin(2) + stepRadius*incDKLY;
else
    incDKLX = DKLX(2) - DKLX(1);
    incDKLY = DKLY(2) - DKLY(1);
    stepRadius = length(DKLX)/2 - 1;
end
    


%%
%Produce color maps

%Create matrices to store R, G, B values over the MB space.
Rsurface = zeros(length(DKLX),length(DKLY));
Gsurface = zeros(length(DKLX),length(DKLY));
Bsurface = zeros(length(DKLX),length(DKLY));

count1 = 0;
for dkl_x = DKLX
    count1 = count1 + 1;
    count2 = 0;
    for dkl_y = DKLY
      count2 = count2 + 1;
      DKL_coords = [dkl_x,dkl_y,luminance];
      lms = cartDKL2lms(DKL_coords,my_scaling');
      RGB = lms2rgb(phosphors,fundamentals,lms);
      try
          if gammaCorrect
             RGB = linearizeOutput(RGB,gammaTable);
          end
          Rsurface(count1,count2) = RGB(1);
          Gsurface(count1,count2) = RGB(2);
          Bsurface(count1,count2) = RGB(3);
          if (dkl_x == origin(1) && dkl_y == origin(2))
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

      [~, testRadius] = DKL2polar(dkl_x,dkl_y,incDKLX,incDKLY,origin);
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

img = zeros(length(DKLY),length(DKLX),3);

img(:,:,1) = Rsurface'./255;
img(:,:,2) = Gsurface'./255;
img(:,:,3) = Bsurface'./255;

figure
hold on
iptsetpref('ImshowAxesVisible','on');
imshow(img);
xlabel('L-M')
ylabel('S-(L+M)')
xlim([0, length(DKLX)])
ylim([0, length(DKLY)])
set(gca,'YDir','normal')
%relabel axes in terms of MB coordinates
ax = gca;
ax.XTick = round([0 length(DKLX)/4 2*length(DKLX)/4 3*length(DKLX)/4 length(DKLX)],1);
ax.YTick = round([0 length(DKLY)/4 2*length(DKLY)/4 3*length(DKLY)/4 length(DKLY)],1);
DKLXInc = (DKLX(length(DKLX)) - DKLX(1))/4;
labelsDKLX = DKLX(1):DKLXInc:DKLX(length(DKLX));
DKLYInc = (DKLY(length(DKLY)) - DKLY(1))/4;
labelsDKLY = DKLY(1):DKLYInc:DKLY(length(DKLY));
ax.XTickLabel = labelsDKLX;
ax.YTickLabel = labelsDKLY;

if gammaCorrect
    titleString = strcat('Gamma corrected isoluminant plane',' luminance = ',num2str(luminance));
    title(titleString)
else
    titleString = strcat('Gamma uncorrected isoluminant plane',' luminance = ',num2str(luminance));
    title(titleString)
end
hold off


return
