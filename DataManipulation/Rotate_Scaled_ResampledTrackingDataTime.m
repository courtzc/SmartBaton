  
  
miniPattern = "C:\Users\Courtney\source\repos\ThesisProject\" + ...
    "Data\Session02_ManipulatedData\TrackingDataTime_Resampled_Scaled\*.mat";

theFiles = dir(miniPattern);

for i = 1:length(theFiles)
    %% input desired experiment
    filenameCheck = theFiles(i).name;
    expID = filenameCheck(15:17);
    
    %% calcs
    % get the file of the desired experiment
    fprintf(1, 'Now reading %s\n', expID)
    trackingDataShortFileName = sprintf("Session02_Exp_%s_BBaton_BlanksRemoved_SimpleCentroid_Resampled_Scaled", expID);
    trackingDataFileName = sprintf("Data/Session02_ManipulatedData/TrackingDataTime_Resampled_Scaled/%s.mat", trackingDataShortFileName);

    trackingData = load(trackingDataFileName, 'scaled_tracking_data').scaled_tracking_data;
    rotated_tracking_data = trackingData;

%     matrix_to_rotate = trackingData(:,2:4).';
% 
%     R = [0  -1  0;    1  0  0;     0  0  1];
%     rotated_points_transposed = R * matrix_to_rotate;
% 
%     rotated_tracking_data(:,2:4) = rotated_points_transposed.';

    % save new data
    fileName = sprintf("Data/Session02_ManipulatedData/TrackingDataTime_Resampled_Scaled_Rotated/%s_Rotated.mat", trackingDataShortFileName);
    save(fileName, 'rotated_tracking_data');

end
