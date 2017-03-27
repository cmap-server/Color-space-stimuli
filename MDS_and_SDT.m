clear all

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

axisRatio = 80/3; %to produce a square plot in MB space corresponding to square MDS plot (Boehm et. al, 2014).
origin = [.7, 1];

%initial guesses
incrMB = .0005;
incbMB = incrMB*axisRatio;
[incrMB, incbMB, rho] = findMaxMBDisc(luminance,monitor,0,runTime,incrMB,incbMB);
[incDKLX, incDKLY, origin, luminance_dkl, stepRadius] = findMaxDKLDisc(background_grey,monitor,0,runTime);

%define colors for plotting
for theta = 0:15:345

    [rMB1 bMB1] = polar2MB(rho,theta,incrMB,incbMB);
    lms = rgbMB2lms([rMB1 1-rMB1 bMB1],luminance,my_scaling');
    rgb2(theta/15 + 1,:) = lms2rgb(phosphors,fundamentals,lms);
    rgb2(theta/15 + 1,:) = linearizeOutput(rgb2(theta/15 + 1,:),gammaTable);    
    
    [DKLX DKLY] = polar2DKL(stepRadius,theta,incDKLX,incDKLY,origin);
    lms = cartDKL2lms([DKLX DKLY luminance_dkl],my_scaling');
    rgb_dkl(theta/15 + 1,:) = lms2rgb(phosphors,fundamentals,lms);
    if strcmp(monitor,'cemnl')
        rgb_dkl(theta/15 + 1,:) = linearizeOutput(rgb_dkl(theta/15 + 1,:),gammaTable);
    end

end
rgb2 = rgb2./255;
rgb_dkl = rgb_dkl./255;



showAll = 1;
dissimilarity_matrix_all = zeros(24);
MDS_dissimilarity_matrix_all = zeros(24);
false_alarms_all = 0;
hits_all = zeros(12,4);
numParticipants = 22;
figure
for participant = 1:numParticipants
    switch participant
        case 1
             load experimentalData/validData/sub0Nick
        case 2
            load experimentalData/validData/sub2
        case 3
            load experimentalData/validData/sub3
        case 4
            load experimentalData/validData/sub4
        case 5
            load experimentalData/validData/sub8
        case 6
            load experimentalData/validData/sub9
        case 7
            load experimentalData/validData/sub12
        case 8
            load experimentalData/validData/sub13
        case 9
            load experimentalData/validData/sub17
        case 10
            load experimentalData/validData/sub18
        case 11
            load experimentalData/validData/sub19
        case 12
            load experimentalData/validData/sub20
        case 13
            load experimentalData/validData/sub21
        case 14
            load experimentalData/validData/sub22
        case 15
            load experimentalData/validData/sub23
        case 16
            load experimentalData/validData/sub24
        case 17
            load experimentalData/validData/sub25
        case 18
            load experimentalData/validData/sub26
        case 19
            load experimentalData/validData/sub27
        case 20
            load experimentalData/validData/sub28
        case 21
            load experimentalData/validData/sub29
        case 22
            load experimentalData/validData/sub30
            
    end
    
    
    %Store group MDS data
    dissimilarity_matrix_all = dissimilarity_matrix_all + dissimilarityMatrix;
    MDS_dissimilarity_matrix_all = MDS_dissimilarity_matrix_all + MDSdissimilarityMatrix;
    
    %Make full dissimilarity matrix
    MDSdissimilarityMatrix(MDSdissimilarityMatrix~=0) = MDSdissimilarityMatrix(MDSdissimilarityMatrix~=0)-1;
    for i=1:24
        for j= i+1:24
            MDSdissimilarityMatrix(j,i) = MDSdissimilarityMatrix(i,j);
        end
    end
    solution = mdscale(MDSdissimilarityMatrix,2);
    
    if showAll
        %plot MDS solution
        subplot(4,6,participant)
        hold on
        for i = 1:24
            scat = scatter(solution(i,2),solution(i,1),100,rgb2(i,:),'filled');
        end
        whitebg('black')
        circ = plot(solution(:,2),solution(:,1),'white','MarkerSize',.4);
        axis equal
        if participant ==1
            xlabel('MDS dimension 2');
            ylabel('MDS dimension 1');
        end
        ylim([-3 3])
        xlim([-3 3])
%         set(gca,'Ydir','reverse')
        %title(strcat('subject ',num2str(participant)))
%         view(15,90)
        % set(gca,'Xdir','reverse')
        hold off
    end
    
    %Prepare group data for signal detection
    
    %Add individual false alarms to group false alarms
    diagonal = dissimilarityMatrix(1:24+1:24*24);
    false_alarms_indiv = length(diagonal(diagonal~=1));
    false_alarms_all = false_alarms_all + false_alarms_indiv;

    %Steps to store hits by angle difference
    
    %organize data according to angle difference
    longData = zeros(300,2);
    count = 0;
    for i=1:24
        for j=1:24
            if(dissimilarity_matrix_all(i,j)~=0)
                count = count + 1;
                index = abs(i-j);
                if index>12
                    index = 12 - (index-12);
                end
                longData(count,:) = [index*15, dissimilarityMatrix(i,j)];
            end
        end
    end
    longData = sortrows(longData,1);
    %compute hits for all angle differences besides 0
    hits_indiv = zeros(12,4);
    count1=25;
    count2 = 49;
    for i = 1:11
        %store angle, mean, standard error
        longDataI = longData(count1:count2,2);
        hits_indiv(i,:) = [i*15, numel(longDataI(longDataI~=1)),numel(longDataI),numel(longDataI(longDataI~=1))/numel(longDataI)];
        count1 = count1+24;
        count2 = count2 + 24;
    end
    longDataI = longData(count1:count1+11,2);
    hits_indiv(12,:) = [180, numel(longDataI(longDataI~=1)),numel(longDataI),numel(longDataI(longDataI~=1))/numel(longDataI)];
    hits_all = hits_all + hits_indiv;
    hits_all(:,1) = 15:15:180;    
    

    
%     hitRate = length(dissimilarity_matrix_all(dissimilarity_matrix_all~=1))/length(dissimilarity_matrix_all);
%     dPrime = 1/normcdf(.5 - hitRate) - 1/normcdf(.5 - falseAlarmRate);

end

dissimilarity_matrix_all = dissimilarity_matrix_all./numParticipants;
MDS_dissimilarity_matrix_all = MDS_dissimilarity_matrix_all./numParticipants;
hits_all(:,4) = hits_all(:,4)./numParticipants;
hit_rate_all = hits_all(:,4);
false_alarm_rate_all = false_alarms_all./(numParticipants*24);



%Make full dissimilarity matrix
MDS_dissimilarity_matrix_all(MDS_dissimilarity_matrix_all~=0) = MDS_dissimilarity_matrix_all(MDS_dissimilarity_matrix_all~=0)-1;
for i=1:24
    for j= i+1:24
    MDS_dissimilarity_matrix_all(j,i) = MDS_dissimilarity_matrix_all(i,j);
    end
end
solution = mdscale(MDS_dissimilarity_matrix_all,2);




%plot MDS solution
figure
hold on
for i = 1:24
scat = scatter(solution(i,2),solution(i,1),200,rgb2(i,:),'filled');
end
whitebg('black')
circ = plot(solution(:,2),solution(:,1),'white');
axis equal
xlabel('MDS dimension 2');
ylim([-3 3])
ylabel('MDS dimension 1');
set(gca,'Ydir','reverse')
title('GROUP')
view(15,90)
% set(gca,'Xdir','reverse')
hold off



% draw circle in MB
figure
hold on
for i = 1:24
scatter(cosd((i-1)*15),sind((i-1)*15),200,rgb2(i,:),'filled')
end
whitebg('black')
% plot(cosd(0:360),sind(0:360),'white')
axis equal
ylim([-1.2 1.2])
xlabel('l / l+m')
ylabel('s / l+m')
whitebg('black')
hold off

% draw circle in DKL
figure
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

%SDT
%organize data according to angle difference
data = zeros(300,2);
count = 0;
for i=1:24
    for j=1:24
        if(dissimilarity_matrix_all(i,j)~=0)
            count = count + 1;
            index = abs(i-j);
            if index>12
                index = 12 - (index-12);
            end
            data(count,:) = [index*15, dissimilarity_matrix_all(i,j)];
        end
    end
end

data = sort(data,1);
figure
hold on
plot(data(:,1),data(:,2),'x')
xlabel('Angle difference (deg)')
ylabel('Dissimilarity Rating (1-7)')
xlim([-5 185])
ylim([1 7])
whitebg('white')
hold off

%average data to group average response by angle difference
meanDifferences = zeros(13,3);
count1=1;
count2 = 24;
for i = 1:12
    %store angle, mean, standard error
    meanDifferences(i,:) = [(i-1)*15, mean(data(count1:count2,2)), std(data(count1:count1+11,2))/length(data(count1:count1+11,2))];
    count1 = count1+24;
    count2 = count2 + 24;
end
i = 13;
meanDifferences(i,:) = [(i-1)*15, mean(data(count1:count1+11,2)), std(data(count1:count1+11,2))/length(data(count1:count1+11,2))];


%plot mean dissimilarity as a function of angle difference
figure
hold on
%errbar(meanDifferences(:,1),meanDifferences(:,2),meanDifferences(:,3))
plot(meanDifferences(:,1),meanDifferences(:,2),'x')
xlabel('Angle difference (deg)')
ylabel('Mean dissimilarity')
xlim([-5 185])
ylim([1 7])
whitebg('white')
hold off


%this SDT code only works for individual data

for angle_difference=15:15:180
    index = angle_difference/15;
    dPrime(index) = 1/normcdf(.5 - hit_rate_all(index)) - 1/normcdf(.5 - false_alarm_rate_all);
end


figure
hold on
plot(15:15:180,dPrime)
xlabel('Angle difference (deg)');
ylabel('D-prime');
hold off

