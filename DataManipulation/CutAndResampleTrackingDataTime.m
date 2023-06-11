  
miniPattern = "C:\Users\Courtney\source\repos\ThesisProject\" + ...
    "Data\Session02_SimpleCentroidTrackingDataTime\*.csv";

theFiles = dir(miniPattern);

for i = 1:length(theFiles)
    %% input desired experiment
    filenameCheck = theFiles(i).name;
    expID = filenameCheck(15:17);
    
    %% calcs
    % get the file of the desired experiment
    fprintf(1, 'Now reading %s\n', expID)
    trackingDataShortFileName = sprintf("Session02_Exp_%s_BBaton_BlanksRemoved_SimpleCentroid", expID);
    trackingDataFileName = sprintf("Data/Session02_SimpleCentroidTrackingDataTime/%s.csv", trackingDataShortFileName);
    rawTrackingData = readmatrix(trackingDataFileName);
    trackingData = readmatrix(trackingDataFileName);
    
    % get time data - how many data points, last point in time
    TimesFileName = sprintf("Data/Session02_RawData/IMU_Leap_Data/Raw_IMU_and_Leap_Exp_%s.mat", expID);
    timesData = load(TimesFileName).Times;
    desiredLength = length(timesData);
    lastDataPointTime = timesData(end);
    
    % cut the motive data to finish at the same time as the other data
    trackingDataTimes = trackingData(:,1);
    indices = find(trackingDataTimes > lastDataPointTime);
    
    if ~isempty(indices)
        finalDataPoint = indices(1)
        trackingData = trackingData(1:finalDataPoint, :);
    end
    
    % resample the motive data
    newTime = linspace(min(trackingData(:, 1)), max(trackingData(:, 1)), desiredLength);
    
    resampled_tracking_data = zeros(desiredLength, 4);
    
    for col = 2:4
        resampled_tracking_data(:, col) = interp1(trackingData(:, 1), trackingData(:, col), newTime, 'linear');
    end
    
    resampled_tracking_data(:, 1) = newTime;
    
    figure();
    hold on;
    plot(rawTrackingData(:,2), rawTrackingData(:,3), 'Color','b')
    plot(resampled_tracking_data(:,2), resampled_tracking_data(:,3), 'Color','r')
    legend('rawTrackingData', 'resampled_tracking_data')
    
    % save new data
    fileName = sprintf("Data/Session02_ManipulatedData/TrackingDataTime_Resampled/%s_Resampled.mat", trackingDataShortFileName);
    save(fileName, 'resampled_tracking_data');
end
