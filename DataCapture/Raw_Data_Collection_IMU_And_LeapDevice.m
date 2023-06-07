%% note
% press and hold key to finish the data capture

function Raw_Data_Collection_IMU_And_LeapDevice

    % IMU config
    if (~isempty(instrfindall))
        fclose(instrfindall);
        delete(instrfindall);
    end
    
    s = serial('COM8'); % change this to desired Arduino board port
    set(s,'BaudRate',115200); % baud rate for communication
    set(s, 'Terminator', 'LF');
    fopen(s); % open the comm between Arduino and MATLAB

    sample_rate = 5000; % this is a weird number and seems to need to be 1000 times more than the Hz.
    FUSE = imufilter('SampleRate',sample_rate);
    setGlobalRotm(zeros(3,3))


    % setup exit key
    KEY_IS_PRESSED = 0;
    gcf;
    set(gcf, 'KeyPressFcn', @myKeyPressFcn)
    set(gcf,'pos',[300 100 1000 800])

    % data array size - how many loops?
    data_array_size = 2000;

    % initialise arrays
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
        Times(num_loops) = (java.lang.System.currentTimeMillis() - javaStartTime) / 1000;
        
        get_frame_duration = toc*1000; 
        fprintf("duration: %.2f", get_frame_duration)
        time_left_in_loop = loop_time-get_frame_duration;

        if (time_left_in_loop > 0)
            java.lang.Thread.sleep(time_left_in_loop);
        end

        num_loops = num_loops + 1;
    end
    timeNow = datetime('now','TimeZone','local','Format','d-MMM-y-HH-mm-ss');
    filename = sprintf("Raw_IMU_and_Leap_%s.mat", string(timeNow));
    save(filename, 'IMU_readings', 'Leap_readings');

end

function [IMU_reading, Leap_reading] = get_frame(s)
    
    % get IMU data
    IMU_reading = fscanf(s);
    disp(IMU_reading);

    % get Leap frame
    Leap_reading = matleap(1);

end

function setGlobalRotm(val)
    global rotmGlobal
    rotmGlobal = val;
end

function r = getGlobalRotm
    global rotmGlobal
    r = rotmGlobal;
end