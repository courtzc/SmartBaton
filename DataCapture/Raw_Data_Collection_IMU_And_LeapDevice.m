%% note
% press and hold key to finish the data capture

function Raw_Data_Collection_IMU_And_LeapDevice

    % IMU config
    if (~isempty(instrfindall))
        fclose(instrfindall);
        delete(instrfindall);
    end
    
    s = serialport('COM3', 115200); % change this to desired Arduino board port
    set(s,'BaudRate',115200); % baud rate for communication

    fopen(s); % open the comm between Arduino and MATLAB

    sample_rate = 5000; % this is a weird number and seems to need to be 1000 times more than the Hz.
    FUSE = imufilter('SampleRate',sample_rate);

    %% data array size - how many milliseconds?
    desiredTimeInMillis = 20000;

    ExperimentCode = "A1_001_System";


    %% calcs

    javaStartTime = java.lang.System.currentTimeMillis();
    time_stamp = javaStartTime;
    fprintf("%.8f", javaStartTime)
    num_loops = 1;

    while ((time_stamp - javaStartTime) < desiredTimeInMillis)
    
        [IMU_reading, Leap_reading, time_stamp] = get_frame(s);
        Times(num_loops) = time_stamp;
        IMU_readings{num_loops} = IMU_reading;
        Leap_readings{num_loops} = Leap_reading;
        

        num_loops = num_loops + 1;
    end
    
    filename = sprintf("Data/Session04_RawData/Raw_IMU_and_Leap_Exp_%s.mat", ExperimentCode);
%     filename = sprintf("Data/Session03_RawData/IMU_Leap_Data/Raw_IMU_and_Leap_Exp_%s.mat", ExperimentCode);
    timeFirst = datetime(javaStartTime, 'ConvertFrom','epochtime','TicksPerSecond',1000,'Format', 'MM/dd/yy HH:mm:ss.SSS' );
    timeLast = datetime(time_stamp,'ConvertFrom','epochtime','TicksPerSecond',1000,'Format', 'MM/dd/yy HH:mm:ss.SSS');
%     timeFirst = datetime(smoothed_array_times(1), 'convertfrom', 'posixtime', 'Format', 'MM/dd/yy HH:mm:ss.SSS');
%     timeLast = datetime(smoothed_array_times(end), 'convertfrom', 'posixtime', 'Format', 'MM/dd/yy HH:mm:ss.SSS');

    disp(timeFirst)
    disp(timeLast)
    save(filename, 'Times', 'IMU_readings', 'Leap_readings');

end

function [IMU_reading, Leap_reading, time_stamp] = get_frame(s)

    % get Leap frame
    Leap_reading = matleap(1);

    % get time
    time_stamp = java.lang.System.currentTimeMillis();

    % get IMU data
    IMU_reading = fscanf(s);
    
    disp(IMU_reading);
    disp(size(Leap_reading.hands))

end

