

%took lux readings from spectroradiometer with and without gamma
%correction applied 5/31/2017. Spec was mounted with camera facing screen
%center, at constant distance throughout all readings. 

readings_uncorrected = [102.7,100.7,102.3,98.7,96.0,93.0,93.0,97.6,98.5,101.9,104.9,109.5,111.5,112.0,106.7,101.4,96.3,87.5,83.6,79.7,80.0,85.6,91.7,94.1];
snr_uncorrected = mean(readings_uncorrected)./std(readings_uncorrected);

readings_corrected = [151.7,147.5,150.3,154.7,162.3,167.4,169.4,176.2,175.8,177.5,176.1,176.3,177.2,177.6,174.6,175.7,169.2,168.4,165.0,160.2,155.8,152.2,145.4,144.6];
snr_corrected = mean(readings_corrected)./std(readings_corrected);

figure
subplot(2,1,1)
plot(0:15:345,readings_uncorrected)
% ylim([0, 1.1*max(readings_uncorrected)])
title('Gamma uncorrected')
ylabel('Illuminance (lux)')
subplot(2,1,2)
plot(0:15:345,readings_corrected)
% ylim([0, 1.1*max(readings_corrected)])
title('Gamma corrected')
ylabel('Illuminance (lux)')
xlabel('DKL polar angle')

figure
subplot(2,1,1)
polar(deg2rad(0:15:345),readings_uncorrected)
title('Gamma uncorrected')
subplot(2,1,2)
polar(deg2rad(0:15:345),readings_corrected)
title('Gamma corrected')



