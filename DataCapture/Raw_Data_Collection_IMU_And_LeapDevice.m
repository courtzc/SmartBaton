%% note
% press and hold key to finish the data capture

function Raw_Data_Collection_IMU_And_LeapDevice

    % IMU config
    if (~isempty(instrfindall))
        fclose(instrfindall);
        delete(instrfindall);
    end
    
    s = serialport('COM12', 115200); % change this to desired Arduino board port
    set(s,'BaudRate',115200); % baud rate for communication

    fopen(s); % open the comm between Arduino and MATLAB

    sample_rate = 5000; % this is a weird number and seems to need to be 1000 times more than the Hz.
    FUSE = imufilter('SampleRate',sample_rate);

    %% data array size - how many loops?
    data_array_size = 400;

    ExperimentCode = "Exp_4.2.E";

    %% initialise arrays
    IMU_readings = cell(data_array_size, 1);
    Leap_readings = cell(data_array_size, 1);
    Times = zeros(data_array_size, 1);

    % how often the loop runs
    loop_time = 20; %ms
    num_loops = 1;

    javaStartTime = java.lang.System.currentTimeMillis();

    for i = 1:data_array_size
        fprintf("loop number: %d\n", num_loops);
        tic
        
        [IMU_reading, Leap_reading] = get_frame(s);
        IMU_readings{num_loops} = IMU_reading;
        Leap_readings{num_loops} = Leap_reading;
        Times(num_loops) = java.lang.System.currentTimeMillis();
        
        get_frame_duration = toc*1000; 
        fprintf("duration: %.2f", get_frame_duration)
        time_left_in_loop = loop_time-get_frame_duration;

        if (time_left_in_loop > 0)
            java.lang.Thread.sleep(time_left_in_loop);
        end

        num_loops = num_loops + 1;
    end
    timeNow = datetime('now','TimeZone','local','Format','d-mm-HH-mm-ss-SSS');
    filename = sprintf("Raw_IMU_and_Leap_%s_%s.mat", ExperimentCode, string(timeNow));
    save(filename, 'Times', 'IMU_readings', 'Leap_readings');

end

function [IMU_reading, Leap_reading] = get_frame(s)
    
    % get IMU data
    IMU_reading = fscanf(s);
    disp(IMU_reading);

    % get Leap frame
    Leap_reading = matleap(1);

end

