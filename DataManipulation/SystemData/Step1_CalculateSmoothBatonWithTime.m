function Step1_CalculateSmoothBatonWithTime

    sample_rate = 5000; % this is a weird number and seems to need to be 1000 times more than the Hz.
    FUSE = imufilter('SampleRate',sample_rate);
    rotm0_known = load('Data/IMU_rotm0.mat').averages;
    setGlobalRotm(rotm0_known)

    %% file load
    expID = "A1_001_System";
    
    IMU_and_Leap_filename = sprintf("Data/Session04_RawData/Raw_IMU_and_Leap_Exp_%s.mat", expID);

    IMU_Readings = load(IMU_and_Leap_filename).IMU_readings;
    Leap_Readings = load(IMU_and_Leap_filename).Leap_readings;
    Times = load(IMU_and_Leap_filename).Times;
    

    %% inputs
    % how long is your baton?
    baton_length = 120;

    % this is high for now
    data_array_size = 10000;

    % smooth data buffer
    smooth_starting_buffer = 10;

    % initialise arrays
    transformed_baton_tip_pos_raw_array = zeros(3,data_array_size);
    raw_array_times = zeros(1,data_array_size);
    
    % loop counters
    successful_loops = 1;
    all_loops = 0;

    disp(length(Times))

    for i = 1:length(Times)
    
        % get frames
        [IMU_reading, Leap_reading] = get_frame(i, IMU_Readings, Leap_Readings);

        % extract IMU data
        [baton_tip_pos, imu_exists] = manipulate_imu(IMU_reading, FUSE, baton_length);

        % extract Leap data
        [palm_pos, leap_exists] = manipulate_leap(Leap_reading);


        if (imu_exists + leap_exists == 2)
            
            % transform baton tip
            transformed_baton_tip_pos = [baton_tip_pos(1) + palm_pos(1); baton_tip_pos(2) + palm_pos(2); baton_tip_pos(3) + palm_pos(3)];

            transformed_baton_tip_pos_raw_array(:,(successful_loops+smooth_starting_buffer)) = transformed_baton_tip_pos;
            raw_array_times(successful_loops+smooth_starting_buffer) = Times(i);

            cols_with_all_zeros = find(all(transformed_baton_tip_pos_raw_array(:, (smooth_starting_buffer+1):end)==0), 1);

            % smooth the raw data array
            transformed_baton_tip_pos_smoothed_array = smoothdata(transformed_baton_tip_pos_raw_array(:,1:(cols_with_all_zeros+smooth_starting_buffer)),2,"gaussian",10);
            smoothed_array_times = raw_array_times(1:(cols_with_all_zeros+smooth_starting_buffer));
            fprintf("size of array: %d, ", length(transformed_baton_tip_pos_smoothed_array))
            fprintf("smoothed_array_times: %d, ", length(smoothed_array_times))

            % only take non zero bits
            firstNonzeroBatonSmoothIndex = find(transformed_baton_tip_pos_smoothed_array(1,:), 1, 'first')+smooth_starting_buffer;
            lastNonzeroBatonSmoothIndex = find(transformed_baton_tip_pos_smoothed_array(1,:), 1, 'last');
            lastNonzeroBatonSmoothIndex = lastNonzeroBatonSmoothIndex - smooth_starting_buffer;

            fprintf("size of nonzero array: %d \n", length(transformed_baton_tip_pos_smoothed_array(1,firstNonzeroBatonSmoothIndex:lastNonzeroBatonSmoothIndex)));

            successful_loops = successful_loops + 1;
            
        end

        all_loops = all_loops + 1;
    end


    clear t;

    save_system_data(expID, transformed_baton_tip_pos_smoothed_array, smoothed_array_times, firstNonzeroBatonSmoothIndex, lastNonzeroBatonSmoothIndex)


end

function save_system_data(expID, transformed_baton_tip_pos_smoothed_array, smoothed_array_times, firstNonzeroBatonSmoothIndex, lastNonzeroBatonSmoothIndex)
    fileName = sprintf("Data/Session04_ManipulatedData/AbsoluteTime_SystemPos/AbsoluteTime_Smooth_Baton_Pos_%s.mat", expID);
    transformed_baton_tip_pos_smoothed_array = transformed_baton_tip_pos_smoothed_array(:,firstNonzeroBatonSmoothIndex:lastNonzeroBatonSmoothIndex);
    smoothed_array_times = smoothed_array_times(firstNonzeroBatonSmoothIndex:lastNonzeroBatonSmoothIndex);

    timeFirst = datetime(smoothed_array_times(1),'ConvertFrom','epochtime','TicksPerSecond',1000,'Format', 'MM/dd/yy HH:mm:ss.SSS' );
    timeLast = datetime(smoothed_array_times(end),'ConvertFrom','epochtime','TicksPerSecond',1000,'Format', 'MM/dd/yy HH:mm:ss.SSS');
%     timeFirst = datetime(smoothed_array_times(1), 'convertfrom', 'posixtime', 'Format', 'MM/dd/yy HH:mm:ss.SSS');
%     timeLast = datetime(smoothed_array_times(end), 'convertfrom', 'posixtime', 'Format', 'MM/dd/yy HH:mm:ss.SSS');

    disp(timeFirst)
    disp(timeLast)

%     fprintf("First timestamp: %s\n", timeFirst);
%     fprintf("Last timestamp: %s\n", timeLast);

    tXYZ_System = [smoothed_array_times; transformed_baton_tip_pos_smoothed_array(1,:); transformed_baton_tip_pos_smoothed_array(2,:); transformed_baton_tip_pos_smoothed_array(3,:)]';
    save(fileName, 'tXYZ_System');
end

function [IMU_reading, Leap_reading] = get_frame(i, IMU_readings, Leap_readings)

    IMU_reading = IMU_readings{i};
    Leap_reading = Leap_readings{i};

end

function setGlobalRotm(val)
    global rotmGlobal
    rotmGlobal = val;
end

function r = getGlobalRotm
    global rotmGlobal
    r = rotmGlobal;
end

function [baton_tip_pos, imu_exists] = manipulate_imu(IMU_reading, FUSE, baton_length)

    try
        [out_array, status] = str2num(IMU_reading);
    catch
        status = 0;
    end

    if (status && isequal(size(out_array), [3,3]))
        % get orientation quarternion
        accelReadings = out_array(1,:);
        gyroReadings = out_array(2,:);
        imu_exists = 1;

        orientation_quarternion = FUSE(accelReadings,gyroReadings);

        rotm0 = getGlobalRotm();

        % transform baton tip pose
        rotm = rotm0\quat2rotm(orientation_quarternion);
        baton_tip_pos = rotm(:,2) .* baton_length;

    else
        imu_exists = 0;
        baton_tip_pos = [0;0;0];
    end

end

function [palm_pos, leap_exists] = manipulate_leap(Leap_reading)
    hands = Leap_reading.hands;
    if (~isempty(hands))
        palm = hands(1).palm;
        palm_pos = (palm.position)';
        leap_exists = 1;
    else
        leap_exists = 0;
        palm_pos = [0;0;0];
    end
end