  
  
miniPattern = "C:\Users\Courtney\source\repos\ThesisProject\" + ...
    "Data\Session02_ManipulatedData\TrackingDataTime_Resampled\*.mat";

theFiles = dir(miniPattern);

for i = 1:length(theFiles)
    %% input desired experiment
    filenameCheck = theFiles(i).name;
    expID = filenameCheck(15:17);
    
    %% calcs
    % get the file of the desired experiment
    fprintf(1, 'Now reading %s\n', expID)
    trackingDataShortFileName = sprintf("Session02_Exp_%s_BBaton_BlanksRemoved_SimpleCentroid_Resampled", expID);
    trackingDataFileName = sprintf("Data/Session02_ManipulatedData/TrackingDataTime_Resampled/%s.mat", trackingDataShortFileName);
%     rawTrackingData = readmatrix(trackingDataFileName);
    trackingData = load(trackingDataFileName, 'resampled_tracking_data').resampled_tracking_data;


%     % get time data - how many data points, last point in time
    TimesFileName = sprintf("Data/Session02_RawData/IMU_Leap_Data/Raw_IMU_and_Leap_Exp_%s.mat", expID);
%     timesData = load(TimesFileName).Times;
     leapData = load(TimesFileName).Leap_readings;
%     desiredLength = length(timesData);
%     lastDataPointTime = timesData(end);
    largest_leap_distance = get_largest_leap_distance(leapData);
    largest_motive_distance = get_largest_motive_distance(trackingData);

    scalingFactor = largest_leap_distance / largest_motive_distance; % Calculate the scaling factor

    scaled_tracking_data = trackingData * scalingFactor; % Scale up ArrayB

    % save new data
    fileName = sprintf("Data/Session02_ManipulatedData/TrackingDataTime_Resampled_Scaled/%s_Scaled.mat", trackingDataShortFileName);
    save(fileName, 'scaled_tracking_data');

%     
%     % cut the motive data to finish at the same time as the other data
%     trackingDataTimes = trackingData(:,1);
%     indices = find(trackingDataTimes > lastDataPointTime);
%     
%     if ~isempty(indices)
%         finalDataPoint = indices(1)
%         trackingData = trackingData(1:finalDataPoint, :);
%     end
%     
%     % resample the motive data
%     newTime = linspace(min(trackingData(:, 1)), max(trackingData(:, 1)), desiredLength);
%     
%     resampled_tracking_data = zeros(desiredLength, 4);
%     
%     for col = 2:4
%         resampled_tracking_data(:, col) = interp1(trackingData(:, 1), trackingData(:, col), newTime, 'linear');
%     end
%     
%     resampled_tracking_data(:, 1) = newTime;
%     
%     figure();
%     hold on;
%     plot(rawTrackingData(:,2), rawTrackingData(:,3), 'Color','b')
%     plot(resampled_tracking_data(:,2), resampled_tracking_data(:,3), 'Color','r')
%     legend('rawTrackingData', 'resampled_tracking_data')
%     
%     save new data
%     fileName = sprintf("Data/Session02_ManipulatedData/TrackingDataTime_Resampled/%s_Resampled.mat", trackingDataShortFileName);
%     save(fileName, 'resampled_tracking_data');
end

function largest_leap_distance = get_largest_leap_distance (Leap_readings)

    largest_leap_distance = 0;
    numberOfCoords = length(Leap_readings);

    palm_pos = zeros(numberOfCoords, 3);

    for k = 1 : numberOfCoords
        hands = Leap_readings{k}.hands;
        if (~isempty(hands))
            palm = hands(1).palm;
            palm_pos(k,:) = (palm.position);
        else
            palm_pos(k,:) = [0,0,0];
        end
    end

    x = palm_pos(:,1);
    y = palm_pos(:,2);
    z = palm_pos(:,3);



    for i = 1 : numberOfCoords
        if (~isequal(palm_pos(i,:), [0, 0, 0]))
            for j = i+1 : numberOfCoords
                if (~isequal(palm_pos(j,:), [0, 0, 0]))
                    distance = sqrt((x(i)-x(j))^2 + (y(i)-y(j))^2 + (z(i)-z(j))^2);
                    if distance > largest_leap_distance
                        largest_leap_distance = distance;
                    end
                end
            end
        end
    end

end

function largest_motive_distance = get_largest_motive_distance (Motive_readings)

    numberOfCoords = length(Motive_readings(:,1));
    x = Motive_readings(:,2);
    y = Motive_readings(:,3);
    z = Motive_readings(:,4);


    largest_motive_distance = 0;

    for i = 1 : numberOfCoords
        for j = i+1 : numberOfCoords
            distance = sqrt((x(i)-x(j))^2 + (y(i)-y(j))^2 + (z(i)-z(j))^2);
            if distance > largest_motive_distance
                largest_motive_distance = distance;
            end
        end
    end

end
