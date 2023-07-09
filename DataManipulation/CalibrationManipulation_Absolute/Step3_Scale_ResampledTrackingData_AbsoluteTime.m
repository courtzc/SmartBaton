  
function Step3_Scale_ResampledTrackingData_AbsoluteTime
      
    miniPattern = "C:\Users\Courtney\source\repos\ThesisProject\" + ...
        "Data\Session03_ManipulatedData\TrackingData_SimpleCentroid_CutWithAbsolute\*.csv";

    theFiles = dir(miniPattern);
    
    for i = 1:length(theFiles)
        %% input desired experiment
        filenameCheck = theFiles(i).name;
        expID = filenameCheck(5:7);
        
        %% calcs
        % get the file of the desired experiment
        fprintf(1, 'Now reading %s\n', expID)
        trackingDataShortFileName = sprintf("EXP_%s_BBaton_BlanksRemoved_SimpleCentroid_CutWithAbsolute", expID);
        trackingDataFileName = sprintf("Data/Session03_ManipulatedData/TrackingData_SimpleCentroid_CutWithAbsolute/%s.csv", trackingDataShortFileName);
        rawTrackingData = readmatrix(trackingDataFileName);
        trackingData = rawTrackingData;
        lengthData = length(trackingData(:,2));
        tXYZ_Motive = zeros(lengthData,5);

        TimesFileName = sprintf("Data/Session03_ManipulatedData/Time_SmoothBatonPosition/Time_Smooth_Baton_Pos_%s.mat", expID);
        try 
            system_data = load(TimesFileName).tXYZ_System;

            largest_system_distance = get_largest_system_distance(system_data);
            largest_motive_distance = get_largest_motive_distance(trackingData);
        
            scalingFactor = largest_system_distance / largest_motive_distance; % Calculate the scaling factor
        
            tXYZ_Motive(:,3:5) = trackingData(:,3:5) * scalingFactor; 
            tXYZ_Motive(:,1:2) = trackingData(:,1:2); 
        
            fprintf(1, 'Now saving %s\n', expID)
            fileName = sprintf("Data/Session03_ManipulatedData/TrackingData_SimpleCentroid_CutWithAbsolute_Scaled/%s_Scaled.mat", trackingDataShortFileName);
            save(fileName, 'tXYZ_Motive');
        catch
        end


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
