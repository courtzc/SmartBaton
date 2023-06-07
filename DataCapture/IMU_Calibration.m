%% note
% press and hold key to finish the data capture

function IMU_Calibration

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
%     setGlobalRotm(zeros(3,3))

    % data array size - how many loops?
    data_array_size = 10;

    % initialise arrays
    IMU_readings = zeros(3,3,data_array_size);
%     Leap_readings = cell(data_array_size, 1);

    % how often the loop runs
%     loop_time = 20; %ms
    num_loops = 1;
    

    for i = 1:data_array_size
        fprintf("loop number: %d\n", num_loops);
%         tic
        IMU_reading = fscanf(s);
        a = str2num(IMU_reading);
        IMU_readings(:,:,i) = a
        disp(a)
%         [IMU_reading, Leap_reading] = get_frame(s);
%         IMU_readings{num_loops} = IMU_reading;
%         Leap_readings{num_loops} = Leap_reading;
% 
%         get_frame_duration = toc*1000; 
%         fprintf("duration: %.2f", get_frame_duration)
%         time_left_in_loop = loop_time-get_frame_duration;

%         if (time_left_in_loop > 0)
%             java.lang.Thread.sleep(time_left_in_loop);
%         end

        num_loops = num_loops + 1;
    end
    timeNow = datetime('now','TimeZone','local','Format','d-MMM-y-HH-mm-ss');
    filename = sprintf("IMU_Calibration_%s.mat", string(timeNow));
    save(filename, 'IMU_readings');

end

% function IMU_reading = get_frame(s)
%     
%     % get IMU data
%     IMU_reading = fscanf(s);
%     disp(IMU_reading);
% 
%     % get Leap frame
% %     Leap_reading = matleap(1);
% 
% end

% function setGlobalRotm(val)
%     global rotmGlobal
%     rotmGlobal = val;
% end
% 
% function r = getGlobalRotm
%     global rotmGlobal
%     r = rotmGlobal;
% end