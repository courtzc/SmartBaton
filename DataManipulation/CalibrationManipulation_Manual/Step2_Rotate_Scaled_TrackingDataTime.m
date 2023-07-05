  
  
miniPattern = "C:\Users\Courtney\source\repos\ThesisProject\" + ...
    "Data\Session02_ManipulatedData\TrackingData_ManualTime_Scaled\*13A*.mat";

theFiles = dir(miniPattern);

for i = 1:length(theFiles)
    %% input desired experiment
    filenameCheck = theFiles(i).name;
    expID = filenameCheck(15:17);
    
    %% calcs
    % get the file of the desired experiment
    fprintf(1, 'Now reading %s\n', expID)
    trackingDataShortFileName = sprintf("Session02_Exp_%s_BBaton_BlanksRemoved_SimpleCentroid_Scaled", expID);
    trackingDataFileName = sprintf("Data/Session02_ManipulatedData/TrackingData_ManualTime_Scaled/%s.mat", trackingDataShortFileName);

    trackingData = load(trackingDataFileName, 'scaled_tracking_data').scaled_tracking_data;
%     trackingData = load(trackingDataFileName, 'rotated_tracking_data').rotated_tracking_data;
    rotated_tracking_data = trackingData;

    matrix_to_rotate = trackingData(:,2:4).';

    R = [-1  0  0; 0 -1  0; 0  0  1]; % 180 degrees rotation
%     R = [0  1  0;    -1  0  0;     0  0  1]; % 90 degrees clockwise rotation
%     R = [cosd(45) -sind(45) 0; sind(45)  cosd(45) 0; 0 0 1]; % 45 degrees anti-clockwise rotation
%     R = [cosd(45)  sind(45) 0; -sind(45) cosd(45) 0; 0 0 1]; % 45 degrees clockwise rotation


    rotated_points_transposed = R * matrix_to_rotate;

    rotated_tracking_data(:,2:4) = rotated_points_transposed.';

    % save new data
    fileName = sprintf("Data/Session02_ManipulatedData/TrackingData_ManualTime_Scaled_Rotated/%s_Rotated.mat", trackingDataShortFileName);
    save(fileName, 'rotated_tracking_data');

end
