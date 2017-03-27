% script to compute a gamma table 
% by Yuki Kamitani   12-7-99 
% ---- data,  [col1 lum1; col2 lim2;...] ------------ 
measTest = [ 50  6.25 ; 100  12.5; 150  18; 200  32; 250  50]; 
% --------------------------------------

%%%%  put your data into 'meas' 
meas = measTest;

maxIndex = 255;  %  +1 = total num of indices 
indexNormal = [0:0.001:1]'; 
maxLum = meas(size(meas,1),2);

% You can select a fitting method with the last argument 
% see help for FitGamma in Psychophysics Toolbox 
[out1 params1  message1] = FitGamma(meas(:,1)/maxIndex,  meas(:,2)/maxLum, indexNormal, 1);

figure(1); 
plot(maxIndex*[0:0.001:1]', maxLum*out1); 
hold on; 
scatter(meas(:,1), meas(:,2));

% create a gamma-corrected table 
% Inverse function is calculated numerically 
% independent of fitting curves 
orgTable = [maxIndex*indexNormal  maxLum*out1 ]; 
correctedTable = []; 
for i = 0: 255 
 eqLum = i * maxLum/maxIndex; 
 numTable = max(find(orgTable(:,2) <= eqLum)); 
 correctedTable = [correctedTable ;  i round(orgTable(numTable,1))]; 
end

% confirm linearity 
figure(2); 
linearTable = []; 
for i=0:255 
 numTable = max(find(orgTable(:,1) <= correctedTable(i+1, 2))); 
    linearTable = [linearTable;  i  orgTable(numTable, 2) ]; 
end 
plot(linearTable(:,1), linearTable(:,2)');

correctedTable 
gammaValue = params1(1); 