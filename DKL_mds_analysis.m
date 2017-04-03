

%analyzing DKL color similarity data
load('experimental_data_DKL_similarity\sub1_30-Mar-2017_17-46-58.mat')

dissimilarity_sums = zeros(24,24);
dissimilarity_counts = zeros(24,24); %should be 4 for every entry. check in case.

for trial = 1:1200
    if responses(trial) == 0 %if bad trial
        continue
    end
    index1 = color_angles(trial,1)./15 + 1;
    index2 = color_angles(trial,2)./15 + 1;
    dissimilarity_sums(index1,index2) = dissimilarity_sums(index1,index2) + responses(trial);
    dissimilarity_counts(index1,index2) = dissimilarity_counts(index1,index2) + 1;
end

dissimilarity_means = dissimilarity_sums./dissimilarity_counts;

%Make full dissimilarity matrix 
%(subtract 1 to base at 0)
dissimilarity_means(dissimilarity_means~=0) = dissimilarity_means(dissimilarity_means~=0)-1; 
for i=1:24
    dissimilarity_means(i,i) = 0; %set diagonal to 0 for mdscale
    for j= i+1:24
        dissimilarity_means(j,i) = dissimilarity_means(i,j);
    end
end

solution = mdscale(dissimilarity_means,2);


luminance = .1;
stripeType = 'black';
runTime = 1; %seconds for out to one color and back
monitor = 'cemnl';

if strcmp(monitor,'cemnl')
load extras/phosphors_cemnl
load extras/scaling_cemnl    %load scaling which matches Boehm et. al 2014.
load extras/gammaTableLabPC
background_grey = 50;

elseif strcmp(monitor,'fMRI')
    load extras/phosphors_fMRI_monitor
    load extras/scaling_fMRI_monitor
    background_grey = 128;
end

load extras/SMJfundamentals

[incDKLX, incDKLY, origin, luminance_dkl, stepRadius] = findMaxDKLDisc(background_grey,monitor,0,runTime);

%define colors for plotting
for theta = 0:15:345

    [DKLX DKLY] = polar2DKL(stepRadius,theta,incDKLX,incDKLY,origin);
    lms = cartDKL2lms([DKLX DKLY luminance_dkl],my_scaling');
    rgb_dkl(theta/15 + 1,:) = lms2rgb(phosphors,fundamentals,lms);
    if strcmp(monitor,'cemnl')
        rgb_dkl(theta/15 + 1,:) = linearizeOutput(rgb_dkl(theta/15 + 1,:),gammaTable);
    end

end
rgb_dkl = rgb_dkl./255;


%plot MDS solution
figure
subplot(2,1,1)
hold on
for i = 1:24
scat = scatter(solution(i,2),solution(i,1),200,rgb_dkl(i,:),'filled');
end
whitebg('black')
circ = plot(solution(:,2),solution(:,1),'white');
axis equal
xlabel('MDS dimension 2');
ylim([-3 3])
ylabel('MDS dimension 1');
set(gca,'Ydir','reverse')
title('Sub 1')
view(15,90)
% set(gca,'Xdir','reverse')
hold off


% draw circle in DKL
subplot(2,1,2)
hold on
for i = 1:24
scatter(cosd((i-1)*15),sind((i-1)*15),200,rgb_dkl(i,:),'filled')
end
whitebg('black')
% plot(cosd(0:360),sind(0:360),'white')
axis equal
ylim([-1.2 1.2])
xlabel('l-m')
ylabel('s - (l+m)')
whitebg('black')
hold off



