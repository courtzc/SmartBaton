  
function Step4_ScaleToMotiveSize
      
%     system_data_file_name = "Data/Session04_ManipulatedData/SavedCycles_Resampled/RelativeTime_Smooth_Baton_Pos_B1_011_System_SavedCycle_8_Resampled.mat";
    system_data_file_name_short = "RelativeTime_Smooth_Baton_Pos_B1_021_System_SavedCycle_3_Resampled";
    system_data_file_name = sprintf("Data/Session04_ManipulatedData/SavedCycles_Resampled/%s.mat", system_data_file_name_short);


 
    %% input desired experiment
%     filenameCheck = theFiles(i).name;
%     expID = filenameCheck(5:7);
    
    %% calcs
    % get the file of the desired experiment
    fprintf(1, 'Now reading %s\n', system_data_file_name)

    
    motive_data_file_name_short = "Session01_Exp_A1_All_Resampled_Average";
    motive_data_file_name = sprintf("Data/Session01_ManipulatedData/SavedCycles_Resampled/%s.mat", motive_data_file_name_short);
    
    
    motive_data = load(motive_data_file_name, 'tXYZ_Average').tXYZ_Average;
    lengthData = length(motive_data(:,2));
%     lengthData = length(system_data(:,2));

    tXYZ_System = zeros(lengthData,4);

    try 
        system_data = load(system_data_file_name).tXYZ_System;
        fprintf("length system: %d", length(system_data))
        fprintf("length mtoive: %d", length(motive_data))
        largest_system_distance = get_largest_system_distance(system_data);
        largest_motive_distance = get_largest_motive_distance(motive_data);

        fprintf("largest system distance: %.3f\n", largest_system_distance);
        fprintf("largest motive distance: %.3f\n", largest_motive_distance);

        scaling_factor = largest_motive_distance / largest_system_distance; % Calculate the scaling factor
        fprintf("scaling factor: %.4f\n", scaling_factor);

        tXYZ_System(:,2:4) = system_data(:,2:4) * scaling_factor; 
        tXYZ_System(:,1) = system_data(:,1); 

        largest_system_distance_check = get_largest_system_distance(tXYZ_System);
        fprintf("largest system distance now: %.4f\n", largest_system_distance_check);

    
        fprintf(1, 'Now saving %s\n', system_data_file_name)
        fileName = sprintf("Data/Session04_ManipulatedData/SavedCycles_Resampled_Scaled/%s_Scaled.mat", system_data_file_name_short);
        save(fileName, 'tXYZ_System');
    catch
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
