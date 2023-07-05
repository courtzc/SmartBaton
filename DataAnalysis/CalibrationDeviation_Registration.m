% initialise GUID controller
myGuidController = GUID_Controller;
close all;

%% file load
expID = "11B";
Smooth_Baton_filename = sprintf("Data/Session02_SmoothBatonPosition/Smooth_Baton_Pos_%s.mat",expID);
% just scaled
Motive_filename = sprintf("Data/Session02_ManipulatedData/TrackingData_ManualTime_Scaled/Session02_Exp_%s_BBaton_BlanksRemoved_SimpleCentroid_Scaled.mat",expID);
Motive_Readings = load(Motive_filename).scaled_tracking_data;

% rotated as well
% Motive_filename = sprintf("Data/Session02_ManipulatedData/TrackingData_ManualTime_Scaled_Rotated/Session02_Exp_%s_BBaton_BlanksRemoved_SimpleCentroid_Scaled_Rotated.mat",expID);
% Motive_Readings = load(Motive_filename).rotated_tracking_data;

% IMU_and_Leap_filename = sprintf("Data/Session02_RawData/IMU_Leap_Data/Raw_IMU_and_Leap_Exp_%s.mat",expID);
% Motive_filename = sprintf("Data/Session02_ManipulatedData/TrackingData_ManualTime_Scaled/Session02_Exp_%s_BBaton_BlanksRemoved_SimpleCentroid_Scaled.mat",expID);
amountCutMotiveBeginning = 50;
amountCutMotiveEnd = 150;

amountCutIMUBeginning = 20;
amountCutIMUEnd = 50;



% read in data
% Motive_Readings = load(Motive_filename).scaled_tracking_data;
Motive_Readings = Motive_Readings(:,2:4);
lengthbefore = length(Motive_Readings);
Smooth_Baton_Readings = load(Smooth_Baton_filename).transformed_baton_tip_pos_smoothed_array;

% cut data up
Motive_Readings = Motive_Readings(amountCutMotiveBeginning:(end-amountCutMotiveEnd),:);
Smooth_Baton_Readings = Smooth_Baton_Readings(:,amountCutIMUBeginning:(end-amountCutIMUEnd));
lengthafter = length(Motive_Readings);
desired_num_points = length(Smooth_Baton_Readings(1,:));
fprintf("before: %d. after: %d\n", lengthbefore, lengthafter);

% Calculate the resampling factor
resampling_factor = size(Motive_Readings, 1) / desired_num_points;

% Preallocate the resampled array
Motive_Readings_Resampled = zeros(desired_num_points, 3);

% Resample each dimension of the array

for i = 1:3
    Motive_Readings_Resampled(:, i) = interp1(1:size(Motive_Readings, 1), Motive_Readings(:, i), ...
        linspace(1, size(Motive_Readings, 1), desired_num_points), 'linear');
end

% do registration
fixed = Motive_Readings_Resampled;
moving = Smooth_Baton_Readings';
tform = pcregistericp(pointCloud(moving),pointCloud(fixed));

scaleFactor = mean(sqrt(sum(fixed.^2,2))) / mean(sqrt(sum(moving.^2,2)))
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
titleName = sprintf("PCR (without 1st %d and last %d points of IMU - 1st %d and last %d points of Motive)", amountCutIMUBeginning, amountCutIMUEnd, amountCutMotiveBeginning, amountCutMotiveEnd);
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
plot(dists, 'Color', '#64C5EB', 'LineWidth', 2.5)
legend({legendDeviation}, 'Location','best')

sgTitleName = sprintf("Rigid Registration and Deviation of Experiment %s", expID);
sgtitle(sgTitleName)


% disp("maximum deviation")
% fprintf("max: %.2f\n", max(dists))



% get graph details
graphDetails = sprintf('Rigid Registration %s - Session02_SmoothBatonPosition - %s - Euclidean distance underneath', titleName, expID);
dataset = sprintf("reference: Session02_ManipulatedData/TrackingDataTime_Resampled_Scaled_Rotated/Session02_Exp%s_BBaton_etc. data: Session02_SmoothBatonPosition/SavedCycles_Resampled/Smooth_Baton_Pos_%s", expID, expID);
folderToSaveIn = 'Visualisations/CalibrationAnalysis';   % Your destination folder

% add to GUID directory
descriptionToUse = sprintf("Details: %s. Script used: %s.  Dataset used: %s. File Location: %s. Date Generated: %s", graphDetails, mfilename, dataset, folderToSaveIn, datetime('now'));
GUIDToAppend = myGuidController.updateGuidDirectory(descriptionToUse).currGUID;

% save all figures
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
myGuidController.saveFigures(graphDetails, GUIDToAppend, FigList, folderToSaveIn);