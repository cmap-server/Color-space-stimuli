
cd('/Volumes/SANDISK/UMass/CEMNL/Color space stimuli/')
addpath('color_toolbox_v1')
subject = 4;
monitor = 'cemnl';

dkl_coords = [cosd((0:23)*15); sind((0:23)*15)]';
[dkl_angles, ~] = cart2pol(dkl_coords(:,1),dkl_coords(:,2));
dkl_angles = wrapTo360(rad2deg(dkl_angles));

if subject == 1 %CG
    load('/Volumes/SANDISK/UMass/CEMNL/Color space stimuli/experimental_data_DKL_similarity/sub1_30-Mar-2017_17-46-58')
elseif subject == 2 %JD
    load('/Volumes/SANDISK/UMass/CEMNL/Color space stimuli/experimental_data_DKL_similarity/sub2_10-Apr-2017_22-26-01')
elseif subject == 3 %JL
    load('/Volumes/SANDISK/UMass/CEMNL/Color space stimuli/experimental_data_DKL_similarity/sub3_11-Apr-2017_18-19-55')
elseif subject ==4 %PS
    load('/Volumes/SANDISK/UMass/CEMNL/Color space stimuli/experimental_data_DKL_similarity/sub4_13-Apr-2017_17-58-39')
end

%% compute 2-D MDS solution

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

%% transform solution

%procrustes transformation rotates, scales, and translates
[~,transformed_solution_procrustes,transformation] = procrustes(dkl_coords,solution);
[theta_procrustes_solution, rho_procrustes_solution] = cart2pol(transformed_solution_procrustes(:,1),transformed_solution_procrustes(:,2));
proj_rad = max(rho_procrustes_solution); %used to project to circle defined by max radius
procrustes_solution_projected = zeros(24,2);
for color = 1:24
    [procrustes_solution_projected(color,1),procrustes_solution_projected(color,2)] = pol2cart(theta_procrustes_solution(color),proj_rad);
end


%compute perceptually defined angles via projection 
[perceptual_angles, ~] = cart2pol(procrustes_solution_projected(:,1),procrustes_solution_projected(:,2));
perceptual_angles = wrapTo360(rad2deg(perceptual_angles));



%% define colors for plotting

if strcmp(monitor,'cemnl')
    load extras/phosphors_cemnl
    load extras/scaling_cemnl    %load scaling which matches Boehm et. al 2014.
    load extras/gammaTableLabPC
    background_grey = 128;
elseif strcmp(monitor,'fMRI')
    load extras/phosphors_fMRI_monitor
    load extras/scaling_fMRI_monitor
    background_grey = 128;
end

load extras/SMJfundamentals

[incDKLX, incDKLY, origin, luminance_dkl, stepRadius] = findMaxDKLDisc(background_grey,monitor,0,1);

for theta = 0:15:345

    [DKLX DKLY] = polar2DKL(stepRadius,theta,incDKLX,incDKLY,origin);
    lms = cartDKL2lms([DKLX DKLY luminance_dkl],my_scaling');
    rgb_dkl(theta/15 + 1,:) = lms2rgb(phosphors,fundamentals,lms);
    if strcmp(monitor,'cemnl')
        rgb_dkl(theta/15 + 1,:) = linearizeOutput(rgb_dkl(theta/15 + 1,:),gammaTable);
    end

end
rgb_dkl = rgb_dkl./255;

%% plot circle in DKL
figure
hold on
for i = 1:24
    scatter(cosd((i-1)*15),sind((i-1)*15),200,rgb_dkl(i,:),'filled')
end
axis equal
ylim([-1.2 1.2])
xlabel('l-m')
ylabel('s - (l+m)')
title('Hues in DKL space used in behavioral experiment')
hold off

%% plot raw MDS solution
figure
hold on
for i = 1:24
scat = scatter(solution(i,1),solution(i,2),200,rgb_dkl(i,:),'filled');
end
circ = plot(solution(:,1),solution(:,2),'black');
axis equal
xlabel('MDS dimension 2');
ylim([-3 3])
ylabel('MDS dimension 1');
title(strcat('Sub',num2str(subject),'-raw MDS'))
hold off

%% plot procrustes transformed solution
figure
hold on
for i = 1:24
scat = scatter(transformed_solution_procrustes(i,1),transformed_solution_procrustes(i,2),200,rgb_dkl(i,:),'filled');
% scat2 = scatter(cosd((i-1)*15),sind((i-1)*15),200,rgb_dkl(i,:),'filled');
end
circ = plot(transformed_solution_procrustes(:,1),transformed_solution_procrustes(:,2),'black');
axis equal
xlabel('MDS dimension 2');
ylim([-1.5 1.5])
ylabel('MDS dimension 1');
title(strcat('Sub',num2str(subject),'-procrustes transformed MDS'))
hold off

%% plot circular projection of procrustes transformed MDS solution
figure
hold on
for i = 1:24
    scat = scatter(procrustes_solution_projected(i,1),procrustes_solution_projected(i,2),200,rgb_dkl(i,:),'filled');
    scat2 =  scatter(.8*proj_rad*cosd((i-1)*15),.8*proj_rad*sind((i-1)*15),200,rgb_dkl(i,:),'filled');
end
circ = plot([procrustes_solution_projected(:,1);procrustes_solution_projected(1,1)],[procrustes_solution_projected(:,2);procrustes_solution_projected(1,2)],'black');
circ2 = plot(.8*proj_rad*cosd((0:24)*15),.8*proj_rad*sind((0:24)*15),'black');
axis equal
xlabel('MDS dimension 2');
ylim([-1.1*proj_rad, 1.1*proj_rad])
ylabel('MDS dimension 1');
title(strcat('Sub',num2str(subject),'-circular projection of procrustes transformed MDS'))
hold off



%% outdated transformation code (pre-procrustes)
solution_dkl_correlations = corr(solution,[cosd((0:23)*15); sind((0:23)*15)]');
if abs(solution_dkl_correlations(1,1))<abs(solution_dkl_correlations(2,1))
    solution = [solution(:,2),solution(:,1)]; %flip dims
end
solution_dkl_correlations = corr(solution,[cosd((0:23)*15); sind((0:23)*15)]');
flip_x = 0; flip_y = 0;
if solution_dkl_correlations(1,1)<0
    flip_x = 1; %will flip after conversion to polar coords
end
if solution_dkl_correlations(2,2)<0
    flip_y = 1; %will flip after conversion to polar coords
end
%convert solution to polar coordinates 
solution(:,1) = solution(:,1) - mean(solution(:,1));
solution(:,2) = solution(:,2) - mean(solution(:,2));
solution_theta = zeros(24,1);
solution_rho = zeros(24,1);
for color = 1:24
    [solution_theta(color),solution_rho(color)] = cart2pol(solution(color,1),solution(color,2));
end

solution_theta_rot = solution_theta - solution_theta(1); %shift circle to align 0 deg points with DKL space
proj_rad = max(solution_rho);
%keep max rho and convert projection to cartesian coordinates
solution_projected = zeros(24,2);
solution_rotated = zeros(24,2);
for color = 1:24
    [solution_projected(color,1),solution_projected(color,2)] = pol2cart(solution_theta_rot(color),proj_rad);
    [solution_rotated(color,1),solution_rotated(color,2)] = pol2cart(solution_theta_rot(color),solution_rho(color));
end
% flip solutions that need flipping
if flip_x
    solution_projected(:,1) = -solution_projected(:,1);
    solution_rotated(:,1) = -solution_rotated(:,1);
end
if flip_y
    solution_projected(:,2) = -solution_projected(:,2);
    solution_rotated(:,2) = -solution_rotated(:,2);
end

%% plot circular rotation only of MDS solution
figure
hold on
for i = 1:24
    scat = scatter(solution_rotated(i,1),solution_rotated(i,2),200,rgb_dkl(i,:),'filled');
    scat2 =  scatter(.8*proj_rad*cosd((i-1)*15),.8*proj_rad*sind((i-1)*15),200,rgb_dkl(i,:),'filled');
end
whitebg('white')
circ = plot([solution_rotated(:,1);solution_rotated(1,1)],[solution_rotated(:,2);solution_rotated(1,2)],'black');
circ2 = plot(.8*proj_rad*cosd((0:24)*15),.8*proj_rad*sind((0:24)*15),'black');
axis equal
xlabel('MDS dimension 2');
ylim([-1.1*proj_rad, 1.1*proj_rad])
ylabel('MDS dimension 1');
% set(gca,'Ydir','reverse')
title(strcat('Sub',num2str(subject)))
% view(15,90)
% set(gca,'Xdir','reverse')
hold off
