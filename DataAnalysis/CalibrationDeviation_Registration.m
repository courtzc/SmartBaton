% initialise GUID controller
myGuidController = GUID_Controller;
close all;
isSaving = 1;

%% file load
expID = "51A";
Smooth_Baton_filename = sprintf("Data/Session03_ManipulatedData/Time_SmoothBatonPosition/Time_Smooth_Baton_Pos_%s.mat", expID);
% just scaled
% Motive_filename = sprintf("Data/Session03_ManipulatedData/TrackingData_SimpleCentroid_CutWithAbsolute_Scaled_Resampled_Rotated/EXP_%s_BBaton_BlanksRemoved_SimpleCentroid_CutWithAbsolute_Scaled_Resampled_Rotated.mat",expID);
Motive_filename = sprintf("Data/Session03_ManipulatedData/TrackingData_SimpleCentroid_CutWithAbsolute_Scaled_Resampled/EXP_%s_BBaton_BlanksRemoved_SimpleCentroid_CutWithAbsolute_Scaled_Resampled.mat",expID);
Motive_Readings = load(Motive_filename).tXYZ_Motive;
% Motive_Readings = readmatrix(Motive_filename);
Motive_Readings = Motive_Readings(:,3:5);
Smooth_Baton_Readings = load(Smooth_Baton_filename).tXYZ_System;
Smooth_Baton_Readings = Smooth_Baton_Readings(:,2:4);


% do registration
fixed = Motive_Readings;
moving = Smooth_Baton_Readings;
tform = pcregistericp(pointCloud(moving),pointCloud(fixed));

scaleFactor = mean(sqrt(sum(fixed.^2,2))) / mean(sqrt(sum(moving.^2,2)));
% moving = moving * scaleFactor;
% transform the 'moving' points
movingReg = pctransform(pointCloud(moving),tform);
movingRegScaled = movingReg.Location;
% movingRegScaled = movingReg.Location * scaleFactor;

handle1 = figure;
handle1.Position = [600,100,600,700];
               % Enable overlaying plots

% set(gca, 'xtick', [], 'ytick', [])

% Define subplot positions as percentages
pos1 = [0.1 0.35 0.8 0.55];  % [left bottom width height]
pos2 = [0.1 0.05 0.8 0.2];

subplot('Position', pos1)
axis equal
hold on;    
view(2)
titleName = "Registration";
% titleName = sprintf("PCR ", amountCutIMUBeginning, amountCutIMUEnd, amountCutMotiveBeginning, amountCutMotiveEnd);
title(titleName)

plot3(fixed(:, 1), fixed(:, 2), fixed(:, 3),'Color', '#656565' ,'LineWidth', 2.5);
plot3(movingRegScaled(:, 1), movingRegScaled(:, 2), movingRegScaled(:, 3),'Color', '#7F58AF','LineWidth', 2.5);
legend({'Motive Reading', 'System Reading'}, 'Location','best')

% get distances
dists = vecnorm(fixed - movingRegScaled, 2, 2);
legendDeviation = sprintf("Deviation (max: %.2f)", max(dists));


subplot('Position', pos2)
hold on; 
title("Deviation Point to Point")
ylim([0,1000])
xlabel("Time")
ylabel("Deviation")
plot(dists, 'Color', '#64C5EB', 'LineWidth', 2.5)
legend({legendDeviation}, 'Location','northeast')

sgTitleName = sprintf("Rigid Registration and Deviation of Experiment %s", expID);
sgtitle(sgTitleName)


% disp("maximum deviation")
% fprintf("max: %.2f\n", max(dists))


if (isSaving)
    % get graph details
    graphDetails = sprintf('Rigid Registration %s - Session03_SmoothBatonPosition and Motive - %s - Euclidean distance underneath', titleName, expID);
    dataset = sprintf("reference: Session03_ManipulatedData/TrackingDataTime_Resampled_Scaled_Rotated/Session03_Exp%s_BBaton_etc. data: Session03_SmoothBatonPosition/Smooth_Baton_Pos_%s", expID, expID);
    folderToSaveIn = 'Visualisations/CalibrationAnalysis';   % Your destination folder
    
    % add to GUID directory
    descriptionToUse = sprintf("Details: %s. Script used: %s.  Dataset used: %s. File Location: %s. Date Generated: %s", graphDetails, mfilename, dataset, folderToSaveIn, datetime('now'));
    GUIDToAppend = myGuidController.updateGuidDirectory(descriptionToUse).currGUID;
    
    % save all figures
    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
    myGuidController.saveFigures(graphDetails, GUIDToAppend, FigList, folderToSaveIn);
end