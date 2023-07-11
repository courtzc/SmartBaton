% initialise GUID controller
myGuidController = GUID_Controller;
close all;
isSaving = 1;

%% file load
expID = "51B";
% expIDTest = "51A";
Smooth_Baton_filename = sprintf("Data/Session03_ManipulatedData/Time_SmoothBatonPosition/Time_Smooth_Baton_Pos_%s.mat", expID);
% just scaled
Motive_filename = sprintf("Data/Session03_ManipulatedData/TrackingData_SimpleCentroid_CutWithAbsolute_Scaled_Resampled_Rotated/EXP_%s_BBaton_BlanksRemoved_SimpleCentroid_CutWithAbsolute_Scaled_Resampled_Rotated.mat",expID);
% Motive_filename = sprintf("Data/Session03_ManipulatedData/TrackingData_SimpleCentroid_CutWithAbsolute_Scaled_Resampled/EXP_%s_BBaton_BlanksRemoved_SimpleCentroid_CutWithAbsolute_Scaled_Resampled.mat",expID);
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
% 
% handle1 = figure;
% handle1.Position = [600,100,600,700];
               % Enable overlaying plots

% set(gca, 'xtick', [], 'ytick', [])
%% adjustment 
% Define the translation vector
translation_vector = [0; 75; 0]; % Translation of 20cm lower on the Y axis
rotation_angle = 123; % in degrees


matrix_to_rotate = fixed.';

centroid = mean(matrix_to_rotate,2);
translated_points = matrix_to_rotate - centroid;


% reflection_matrix = [-1 0 0; 0 1 0; 0 0 1];

R = [cosd(rotation_angle) sind(rotation_angle) 0; -sind(rotation_angle) cosd(rotation_angle) 0; 0 0 1]; % clockwise rotation

rotated_points = R * translated_points;
moved_rotated_points = rotated_points + centroid;

translated_points = moved_rotated_points + translation_vector;
% rotated_points_transposed = R * matrix_to_rotate;
fixed = translated_points.';

%% Plotting the point clouds
figure('Color','white');
set(gcf,'units','points','position',[87.75,36.75,450,500])

% Define subplot positions as percentages
pos1 = [0.1 0.37 0.8 0.4];  % [left bottom width height]
pos2 = [0.15 0.08 0.7 0.2];
    

subplot('Position', pos1)
axis equal
hold on;    
view(2)
% titleName = "Registration";
% titleName = sprintf("PCR ", amountCutIMUBeginning, amountCutIMUEnd, amountCutMotiveBeginning, amountCutMotiveEnd);
% title(titleName)

plot3(fixed(:, 1), fixed(:, 2), fixed(:, 3),'Color', '#656565' ,'LineWidth', 2.5);
plot3(movingRegScaled(:, 1), movingRegScaled(:, 2), movingRegScaled(:, 3),'Color', '#64C5EB','LineWidth', 2.5);
legend({'Motive Reading, Exp 51B', 'System Reading, Exp 51B'}, 'Location','northeast')

%% get distances
dists = vecnorm(fixed - movingRegScaled, 2, 2);
legendDeviation = sprintf("Deviation (max: %.2f)", max(dists));


subplot('Position', pos2)
hold on; 
ylim([0,1200])
xlabel("Time")
ylabel("Deviation")
% title("Deviation Point to Point")
plot(dists, 'Color', '#64C5EB', 'LineWidth', 2.5)
legend({legendDeviation}, 'Location','northeast')

% sgTitleName = 
% sgtitle(sgTitleName)

niceTitle{1} = {sprintf("Registration & Deviation of Exp. 51B against Exp. 51B", expID)};
    niceTitle{2} = {sprintf("Triangular movement along X-Y plane")};
%     niceTitle{3} = {sprintf("Average extraneous movement: %s", movementsShort{expMovement})};
%     niceTitle{4} = {sprintf("Reference average extraneous movement: %s", movementsShort{j})};

    % overall title
    axes('Position', [0, 0.87, 1, 0.13] ) ;
    set( gca, 'Color', 'None', 'XColor', 'White', 'YColor', 'White' ) ;
    text( 0.5, 0.65, niceTitle{1}, 'FontName', 'Arial', 'FontSize', 17', 'FontWeight', 'bold', ...
      'HorizontalAlignment', 'Center', 'VerticalAlignment', 'middle' ) ;
    text( 0.5, 0.2, niceTitle{2}, 'FontName', 'Arial', 'FontSize', 15', 'FontWeight', 'normal', ...
      'HorizontalAlignment', 'Center', 'VerticalAlignment', 'middle' ) ;
%     text( 0.5, 0.17, niceTitle{3}, 'FontName', 'Arial', 'FontSize', 10', 'FontWeight', 'normal', ...
%       'HorizontalAlignment', 'Center', 'VerticalAlignment', 'middle' ) ;
%     text( 0.5, 0.02, niceTitle{4}, 'FontName', 'Arial', 'FontSize', 10', 'FontWeight', 'normal', ...
%       'HorizontalAlignment', 'Center', 'VerticalAlignment', 'middle' ) ;

    % regstration title
    axes('Position', [0, 0.76, 1, 0.1] ) ;
    set( gca, 'Color', 'None', 'XColor', 'None', 'YColor', 'None','Box', 'off' ) ;
    text( 0.5, 0.6, "Registration", 'FontName', 'Arial', 'FontSize', 14', 'FontWeight', 'bold', ...
      'HorizontalAlignment', 'Center', 'VerticalAlignment', 'middle' ) ; 
    
    % deviation title
    axes('Position', [0, 0.25, 1, 0.1] ) ;
    set( gca, 'Color', 'None', 'XColor', 'None', 'YColor', 'None','Box', 'off' ) ;
    text( 0.5, 0.6, "Deviation", 'FontName', 'Arial', 'FontSize', 14', 'FontWeight', 'bold', ...
      'HorizontalAlignment', 'Center', 'VerticalAlignment', 'middle' ) ;


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