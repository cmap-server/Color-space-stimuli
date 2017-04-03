%Plots the radius of the maximum valid MB-space disc against luminance
%Updated 3/10/2016
%Author: Nick Blauch

%% Macleod_Boynton
luminances = .1:.05:.9;
incrMB = .001;
axisRatio = 80/3; %from Boehm et. al, 2014
incbMB = incrMB*axisRatio;

discRadii = zeros(1,length(luminances));
incrMBs = zeros(1,length(luminances));
incbMBs = zeros(1,length(luminances));

count = 0;
for lum = luminances
    count = count + 1;
    [incrMBs(count), incbMBs(count), discRadii(count)] = findMaxMBDisc(lum,0,incrMB,incbMB,1);
end

figure
plot(luminances,incrMBs.*discRadii);
xlabel('Normalized luminance')
ylabel('Radius in r coordinate')

%%
%DKL
background_grey = 0:5:255;

discRadii = zeros(1,length(background_grey));
incDKLX = zeros(1,length(background_grey));
incDKLY = zeros(1,length(background_grey));

count = 0;
for grey_val = background_grey
    count = count + 1;
    [incDKLX(count), incDKLY(count), origin, luminances(count), discRadii(count)] = findMaxDKLDisc(grey_val,'cemnl',0,1);
end

figure
plot(background_grey,incDKLX.*discRadii);
xlabel('Normalized luminance')
ylabel('Radius in r coordinate')

