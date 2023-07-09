  
function Step4_Resample_ScaledTrackingData_AbsoluteTime
      
    miniPattern = "C:\Users\Courtney\source\repos\ThesisProject\" + ...
        "Data\Session03_ManipulatedData\TrackingData_SimpleCentroid_CutWithAbsolute_Scaled\*.mat";

    theFiles = dir(miniPattern);
    
    for i = 1:length(theFiles)
        %% input desired experiment
        filenameCheck = theFiles(i).name;
        expID = filenameCheck(5:7);


        
        % calcs
        fprintf(1, 'Now reading %s\n', expID)

        % get the file of the desired experiment
%         fprintf(1, 'Now reading %s\n', expID)
        trackingDataShortFileName = sprintf("EXP_%s_BBaton_BlanksRemoved_SimpleCentroid_CutWithAbsolute_Scaled", expID);
        trackingDataFileName = sprintf("Data/Session03_ManipulatedData/TrackingData_SimpleCentroid_CutWithAbsolute_Scaled/%s.mat", trackingDataShortFileName);
        rawTrackingData = load(trackingDataFileName).tXYZ_Motive;
        trackingData = rawTrackingData;

        TimesFileName = sprintf("Data/Session03_ManipulatedData/Time_SmoothBatonPosition/Time_Smooth_Baton_Pos_%s.mat", expID);
        timesData = load(TimesFileName).tXYZ_System;
        desiredLength = length(timesData(:,1));

        % resample the motive data
        newTime = linspace(min(trackingData(:, 2)), max(trackingData(:, 2)), desiredLength);
        
        resampled_tracking_data = zeros(desiredLength, 4);
        
        for col = 3:5
            resampled_tracking_data(:, col) = interp1(trackingData(:, 2), trackingData(:, col), newTime, 'linear');
        end
        
        resampled_tracking_data(:, 1) = newTime;
        tXYZ_Motive = resampled_tracking_data;
        tXYZ_Motive(:,2) =  tXYZ_Motive(:,1);
        
        figure();
        hold on;
        title(expID)
        plot(rawTrackingData(:,3), rawTrackingData(:,4), 'Color','b')
        plot(tXYZ_Motive(:,3), tXYZ_Motive(:,4), 'Color','r')
        legend('rawTrackingData', 'resampled_tracking_data')

        % save new data
        fileName = sprintf("Data/Session03_ManipulatedData/TrackingData_SimpleCentroid_CutWithAbsolute_Scaled_Resampled/%s_Resampled.mat", trackingDataShortFileName);

%         fileName = sprintf("Data/Session02_ManipulatedData/TrackingData_AbsoluteTime_Resampled/%s_Resampled.mat", trackingDataShortFileName);
        save(fileName, 'tXYZ_Motive')


% 
% 
%         TimesFileName = sprintf("Data/Session03_ManipulatedData/Time_SmoothBatonPosition/Time_Smooth_Baton_Pos_%s.mat", expID);
%         try 
%             system_data = load(TimesFileName).tXYZ_System;
% 
%             largest_system_distance = get_largest_system_distance(system_data);
%             largest_motive_distance = get_largest_motive_distance(trackingData);
%         
%             scalingFactor = largest_system_distance / largest_motive_distance; % Calculate the scaling factor
%         
%             tXYZ_Motive = trackingData * scalingFactor; 
%         
%             fileName = sprintf("Data/Session03_ManipulatedData/TrackingData_SimpleCentroid_CutWithAbsolute_Scaled/%s_Scaled.mat", trackingDataShortFileName);
%             save(fileName, 'tXYZ_Motive');
%         catch
%         end


    end
end

function largest_system_distance = get_largest_system_distance (System_readings)

    numberOfCoords = length(System_readings(:,1));
    x = System_readings(:,2);
    y = System_readings(:,3);
    z = System_readings(:,4);


    largest_system_distance = 0;

    for i = 1 : numberOfCoords
        for j = i+1 : numberOfCoords
            distance = sqrt((x(i)-x(j))^2 + (y(i)-y(j))^2 + (z(i)-z(j))^2);
            if distance > largest_system_distance
                largest_system_distance = distance;
            end
        end
    end

end

function largest_motive_distance = get_largest_motive_distance (Motive_readings)

    numberOfCoords = length(Motive_readings(:,1));
    x = Motive_readings(:,3);
    y = Motive_readings(:,4);
    z = Motive_readings(:,5);


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
