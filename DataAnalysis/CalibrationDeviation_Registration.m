% initialise GUID controller
myGuidController = GUID_Controller;
close all;

%% file load
expID = "13A";
Smooth_Baton_filename = sprintf("Data/Session02_SmoothBatonPosition/Smooth_Baton_Pos_%s.mat",expID);
Motive_filename = sprintf("Data/Session02_ManipulatedData/TrackingDataTime_Resampled_Scaled_Rotated/Session02_Exp_%s_BBaton_BlanksRemoved_SimpleCentroid_Resampled_Scaled_Rotated.mat",expID);

amountCutBeginning = 40;
amountCutEnd = 30;

Motive_Readings = load(Motive_filename).rotated_tracking_data;
Motive_Readings = Motive_Readings(:,2:4);
Motive_Readings = Motive_Readings(10:end,:);
Smooth_Baton_Readings = load(Smooth_Baton_filename).transformed_baton_tip_pos_smoothed_array;
Smooth_Baton_Readings = Smooth_Baton_Readings(:,amountCutBeginning:(end-amountCutEnd));

desired_num_points = length(Smooth_Baton_Readings(1,:));

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
movingReg = pctransform(pointCloud(moving),tform).Location;

handle1 = figure
handle1.Position = [300,200,600,700]
               % Enable overlaying plots

% set(gca, 'xtick', [], 'ytick', [])

% Define subplot positions as percentages
pos1 = [0.1 0.35 0.8 0.55];  % [left bottom width height]
pos2 = [0.1 0.05 0.8 0.2];

subplot('Position', pos1)
axis equal
hold on;    
view(2)
titleName = sprintf("Point Cloud Registration (first %d and last %d points not included)", amountCutBeginning, amountCutEnd);
title(titleName)

plot3(fixed(:, 1), fixed(:, 2), fixed(:, 3),'Color', '#656565' ,'LineWidth', 2.5);
plot3(movingReg(:, 1), movingReg(:, 2), movingReg(:, 3),'Color', '#7F58AF','LineWidth', 2.5);
legend({'Motive Reading', 'System Reading'}, 'Location','best')

% get distances
dists = vecnorm(fixed - movingReg, 2, 2);
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
graphDetails = sprintf('Rigid Registration - Session02_SmoothBatonPosition - %s - Euclidean distance underneath', expID);
dataset = sprintf("reference: Session02_ManipulatedData/TrackingDataTime_Resampled_Scaled_Rotated/Session02_Exp%s_BBaton_etc. data: Session02_SmoothBatonPosition/SavedCycles_Resampled/Smooth_Baton_Pos_%s", expID, expID);
folderToSaveIn = 'Visualisations/CalibrationAnalysis';   % Your destination folder

% add to GUID directory
descriptionToUse = sprintf("Details: %s. Script used: %s.  Dataset used: %s. File Location: %s. Date Generated: %s", graphDetails, mfilename, dataset, folderToSaveIn, datetime('now'));
GUIDToAppend = myGuidController.updateGuidDirectory(descriptionToUse).currGUID;

% save all figures
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
myGuidController.saveFigures(graphDetails, GUIDToAppend, FigList, folderToSaveIn);