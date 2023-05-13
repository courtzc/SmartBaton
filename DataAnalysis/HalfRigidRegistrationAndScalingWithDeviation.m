% initialise GUID controller
myGuidController = GUID_Controller;
close all;

fixedFile = "Data\\Session01_ManipulatedData\\"+ ...
    "SavedCycles_Resampled\\Session01_ExpA1_All_Resampled_Average.mat";

movingFile = "Data\\Session01_ManipulatedData\\"+ ...
    "SavedCycles_Resampled\\Session01_Exp_D1_002_SavedCycle_3_Resampled.mat";

% get in data
moving = load(movingFile).tXYZ;
fixed = load(fixedFile).tXYZ_Average;


moving = moving(:,2:4);
fixed = fixed(:,2:4);

% shift movingRegScaled and fixed so the array starts at the highest point:
movingShifted = rearrangePoints(moving);
fixedShifted = rearrangePoints(fixed);

% get beats 1 and 3 (good for upper ar

% Perform rigid registration comparison on those 3D arrays
tform = pcregistericp(pointCloud(movingShifted),pointCloud(fixedShifted))

% Scale the 'moving' points to the size of the 'fixed' points
scaleFactor = mean(sqrt(sum(fixedShifted.^2,2))) / mean(sqrt(sum(movingShifted.^2,2)));
movingShifted = movingShifted * scaleFactor;

% transform the 'moving' points
movingReg = pctransform(pointCloud(movingShifted),tform);
movingRegScaled = movingReg.Location * scaleFactor;



% get the distances
dists = vecnorm(fixedShifted - movingRegScaled, 2, 2);

numElements = numel(movingRegScaled(:,1));
quarter = ceil(numElements/4);
q1 = quarter;
q2 = q1 + quarter;
q3 = q2 + quarter;

beat1 = movingRegScaled(1:q1,:);
beat2 = movingRegScaled(q1:q2,:);
beat3 = movingRegScaled(q2:q3,:);
beat4 = movingRegScaled(q3:end,:);

beat1dists = dists(1:q1);
beat2dists = dists(q1:q2);
beat3dists = dists(q2:q3);
beat4dists = dists(q3:end);

%% Plotting the point clouds
figure('Color','white');
set(gcf,'units','points','position',[200, 200, 700,500])

% Define subplot positions as percentages
pos1 = [0.1 0.35 0.8 0.55];  % [left bottom width height]
pos2 = [0.1 0.1 0.8 0.2];

% E84D8A = pink, 64C5EB = blue, 7F58AF = purple, FEB326 = orange
beat1Colour = '#E84D8A';
beat2Colour = '#64C5EB';
beat3Colour = '#7F58AF';
beat4Colour = '#FEB326';

% point clouds
subplot('Position', pos1, 'Color', 'white');
hold on;                   % Enable overlaying plots
axis equal
set(gca, 'xtick', [], 'ytick', [])
% reference
plot3(fixed(:, 1), fixed(:, 2), fixed(:, 3),'Color', '#656565' ,'LineWidth', 2.5);
% data
plot3(beat1(:, 1), beat1(:, 2), beat1(:, 3),'Color', beat1Colour,'LineWidth', 2.5);
plot3(beat2(:, 1), beat2(:, 2), beat2(:, 3),'Color', beat2Colour,'LineWidth', 2.5);
plot3(beat3(:, 1), beat3(:, 2), beat3(:, 3),'Color', beat3Colour, 'LineWidth', 2.5);
plot3(beat4(:, 1), beat4(:, 2), beat4(:, 3),'Color', beat4Colour,'LineWidth', 2.5);
legend({'Reference', 'Beat 1', 'Beat 2', 'Beat 3', 'Beat 4'});
hold off;

% distances
subplot('Position', pos2);
hold on;
plot((1:q1), beat1dists, 'Color',beat1Colour, 'LineWidth', 2.5)
plot((q1:q2), beat2dists, 'Color',beat2Colour, 'LineWidth', 2.5)
plot((q2:q3), beat3dists, 'Color',beat3Colour, 'LineWidth', 2.5)
plot((q3:numElements), beat4dists, 'Color',beat4Colour, 'LineWidth', 2.5)
ylim([0,0.6]);
ylabel("Deviation")

% Set the background color of the thirds
ax = gca;  % Get current axes handle
ylim_vals = get(ax, 'YLim');  % Get y-axis limits
ytick = get(ax, 'YTick');  % Get y-axis tick locations

% Define the ranges for the colored areas
top_third = [ylim_vals(2) * (2/3), ylim_vals(2)];  % Red area
middle_third = [ylim_vals(2)/3, ylim_vals(2) * (2/3)];  % Yellow area
bottom_third = [ylim_vals(1), ylim_vals(2)/3];  % Green area

% Create patch objects with respective colors
patch([xlim fliplr(xlim)], [top_third(1) top_third(1) top_third(2) top_third(2)], [0.7255 0.0549 0.0392], 'EdgeColor', 'none', 'FaceAlpha', 0.05);
patch([xlim fliplr(xlim)], [middle_third(1) middle_third(1) middle_third(2) middle_third(2)], [0.9882 0.8196 0.1647], 'EdgeColor', 'none', 'FaceAlpha', 0.05);
patch([xlim fliplr(xlim)], [bottom_third(1) bottom_third(1) bottom_third(2) bottom_third(2)], [0.4549 0.7176 0.1804], 'EdgeColor', 'none', 'FaceAlpha', 0.05);

% Set the y-axis ticks to their original values
set(ax, 'YTick', ytick);
movingFile = strtrim(movingFile);  
movingFileLength = strlength(movingFile)
startIndex = movingFileLength - 46

movingFileShort = extractAfter(movingFile, strlength(movingFile) - 47);
movingFileShort = extractBefore(movingFileShort, strlength(movingFileShort) - 13);
movingFileShort = strrep(movingFileShort, '_', ' ')
% movingFileShort = movingFile(end-46:end);

titleName = sprintf("Rigid Registration and Scaling, with Deviation | %s", movingFileShort);
sgtitle(titleName)


% get graph details
graphDetails = 'Rigid Registration + Scaling - Session01_ManipulatedData - Euclidean distance underneath. Arrays shifted to start at highest point.';
dataset = sprintf("reference: Session01_ManipulatedData/SavedCycles_Resampled/Session01_ExpA1_All_Resampled_Average. data: Session01_ManipulatedData/SavedCycles_Resampled/%s", movingFileShort);
folderToSaveIn = 'Visualisations/RegistrationAnalysis';   % Your destination folder

% add to GUID directory
descriptionToUse = sprintf("Details: %s. Script used: %s.  Dataset used: %s. File Location: %s. Date Generated: %s", graphDetails, mfilename, dataset, folderToSaveIn, datetime('now'));
GUIDToAppend = myGuidController.updateGuidDirectory(descriptionToUse).currGUID;

% save all figures
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
myGuidController.saveFigures(graphDetails, GUIDToAppend, FigList, folderToSaveIn);


function rearrangedArray = rearrangePoints(points)
    % Find the highest XY point
    [~, maxIdx] = max(points(:,2))
    
    % Rearrange the array
    rearrangedArray = circshift(points, [-maxIdx, 0]);
end