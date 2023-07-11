  
function Step4_Rotate_Scaled_ResampledTrackingData_AbsoluteTime
    miniPattern = "C:\Users\Courtney\source\repos\ThesisProject\" + ...
        "Data\Session03_ManipulatedData\TrackingData_SimpleCentroid_CutWithAbsolute_Scaled_Resampled\*51A*.mat";
%     Session03_ManipulatedData/TrackingData_SimpleCentroid_CutWithAbsolute_Scaled_Resampled/%s_Resampled.mat"
    theFiles = dir(miniPattern);
    
    for i = 1:length(theFiles)
        %% input desired experiment
        filenameCheck = theFiles(i).name;
        expID = filenameCheck(5:7);
        
        %% calcs
        % get the file of the desired experiment
        fprintf(1, 'Now reading %s\n', expID)
        trackingDataShortFileName = sprintf("EXP_%s_BBaton_BlanksRemoved_SimpleCentroid_CutWithAbsolute_Scaled_Resampled", expID);
    %     trackingDataShortFileNameNew = sprintf("Session02_Exp_%s_BBaton_BlanksRemoved_SimpleCentroid_AbsoluteTimeCut_Resampled_Scaled", expID);
        trackingDataFileName = sprintf("Data/Session03_ManipulatedData/TrackingData_SimpleCentroid_CutWithAbsolute_Scaled_Resampled/%s.mat", trackingDataShortFileName);
    
        trackingData = load(trackingDataFileName, 'tXYZ_Motive').tXYZ_Motive;
        rotated_tracking_data = trackingData;
    
        matrix_to_rotate = trackingData(:,3:5).';
    
        reflection_matrix = [-1 0 0; 0 1 0; 0 0 1];
%         R = [0  1  0;    -1  0  0;     0  0  1]; % 90 degrees clockwise rotation
    %     R = [cosd(45) -sind(45) 0; sind(45)  cosd(45) 0; 0 0 1]; % 45 degrees anti-clockwise rotation
    %     R = [cosd(45)  sind(45) 0; -sind(45) cosd(45) 0; 0 0 1]; % 45 degrees clockwise rotation
        rotation_angle = 120; % in degrees
%         R = [cosd(rotation_angle) -sind(rotation_angle) 0; sind(rotation_angle) cosd(rotation_angle) 0; 0 0 1]; % anticlockwise rotation
        R = [cosd(rotation_angle) sind(rotation_angle) 0; -sind(rotation_angle) cosd(rotation_angle) 0; 0 0 1]; % clockwise rotation
        
        figure 
        hold on
        axis equal
        plot3(matrix_to_rotate(1,:), matrix_to_rotate(2,:), matrix_to_rotate(3,:), 'Color', 'g')

%         rotated_points_transposed = reflection_matrix * matrix_to_rotate;
%         plot3(rotated_points_transposed(1,:), rotated_points_transposed(2,:), rotated_points_transposed(3,:), 'Color', 'r')
%         rotated_points_transposed = R * rotated_points_transposed;
        rotated_points_transposed = R * matrix_to_rotate;
        plot3(rotated_points_transposed(1,:), rotated_points_transposed(2,:), rotated_points_transposed(3,:), 'Color', 'b')

        rotated_tracking_data(:,3:5) = rotated_points_transposed.';

        tXYZ_Motive = rotated_tracking_data;
    
        % save new data
        fileName = sprintf("Data/Session03_ManipulatedData/TrackingData_SimpleCentroid_CutWithAbsolute_Scaled_Resampled_Rotated/%s_Rotated.mat", trackingDataShortFileName);
        save(fileName, 'tXYZ_Motive');
    
    end
end