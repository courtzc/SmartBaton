%% note
% press and hold key to finish the data capture and visualisation

function Read_And_Save_IMU_And_LeapDevice_System_Data
    myGuidController = GUID_Controller;
    close all;

    expID = "B1_023_System";

    % IMU config
    if (~isempty(instrfindall))
        fclose(instrfindall);
        delete(instrfindall);
    end
    
    s = serial('COM3'); % change this to desired Arduino board port
    set(s,'BaudRate',115200); % baud rate for communication
    set(s, 'Terminator', 'LF');
    fopen(s); % open the comm between Arduino and MATLAB

    sample_rate = 5000;
    FUSE = imufilter('SampleRate',sample_rate);
    rotm0_known = load('Data/IMU_rotm0.mat').averages;
    setGlobalRotm(rotm0_known)

    %% inputs
    % how long is your baton?
    baton_length = 100;

    % how much of a tail would you like?
    data_array_size = 5000;

    % how much of a fade out would you like on the tail?
    fade_out_size = 50; % the earliest n bits of data that aren't zero get faded out. the nth onwards, from the nonzero index, is plotted normally.
    
    %% plot

    % setup exit key
    KEY_IS_PRESSED = 0;
    gcf;
    set(gcf, 'KeyPressFcn', @myKeyPressFcn)
    set(gcf,'pos',[300 100 1000 800])


    % get handles to figure
    fig_handle=subplot(1,1,1);
    plts = cell(1,6);

    % initialise plot
    hold on;
    axis equal;
    titleName = sprintf("Leap Palm Positional Data & Baton Tip Pos from IMU %s", datetime('now'));
    title(titleName)
    view(2)
    colourAlt = {'#5A5A5A', '#B33300', '#00B3E6',  '#E6B333', '#80B300', '#3366E6', '#FF99E6', '#33FFCC', '#B366CC', '#4D8000', '#66664D', '#991AFF', '#E666FF', '#4DB3FF', '#1AB399', '#E666B3', '#33991A', '#CC9999', '#B3B31A', '#00E680',  '#4D8066', '#809980', '#E6FF80', '#1AFF33', '#999933', '#FF3380', '#CCCC00', '#66E64D', '#4D80CC', '#9900B3',  '#E64D66', '#4DB380', '#FF4D4D', '#99E6E6', '#6666FF'};
    colourAlt1Fade = '#BEBEBE'; % lighter version of #5A5A5A
    colourAlt3Fade = '#A3EBFF'; % lighter version of #00B3E6
    colourAlt6Fade = '#C4D3F8'; % lighter version of #3366E6

    xlabel('x')
    ylabel('y (leap z)')
    zlabel('z (leap y)')

    %% set up the plot3s of the palm data, baton tip data, and smoothed baton tip data.
    % set up the fade plots - must go first to be at the back
    plts{1} = plot3(fig_handle,[0,1],[0,1],[0,1],'color', colourAlt1Fade,'linewidth',2);
    plts{2} = plot3(fig_handle,[0,1],[0,1],[0,1],'color', colourAlt3Fade);
    plts{3} = plot3(fig_handle,[0,1],[0,1],[0,1],'color', colourAlt6Fade, LineWidth=4);

    % set up the main plots
    plts{4} = plot3(fig_handle,[0,1],[0,1],[0,1],'color', colourAlt{1},'linewidth',2);
    plts{5} = plot3(fig_handle,[0,1],[0,1],[0,1],'color', colourAlt{3});
    plts{6} = plot3(fig_handle,[0,1],[0,1],[0,1],'color', colourAlt{6}, LineWidth=4);


    % smooth data buffer
    smooth_starting_buffer = 10;

    % initialise arrays
    transformed_baton_tip_pos_raw_array = zeros(3,data_array_size);
    palm_pos_whole_array = zeros(3,data_array_size);
    raw_array_times = zeros(1,data_array_size);

    % how often the loop runs
    loop_time = 20; %ms
    
    % loop counters
    successful_loops = 1;
    all_loops = 0;
    total_duration = 0;

    while(total_duration < 30000)
        tic
    
        % get frames
        [IMU_reading, Leap_reading, time_stamp] = get_frame(s);
        
        % extract IMU data
        [baton_tip_pos, imu_exists] = manipulate_imu(IMU_reading, FUSE, baton_length);
        
        % extract Leap data
        [palm_pos, leap_exists] = manipulate_leap(Leap_reading);

        gather_duration = toc*1000;
        plot_duration = 0;
        tic
        
        if (imu_exists + leap_exists == 2)

            % transform baton tip
            transformed_baton_tip_pos = [baton_tip_pos(1) + palm_pos(1); baton_tip_pos(2) + palm_pos(2); baton_tip_pos(3) + palm_pos(3)];
            transformed_baton_tip_pos_raw_array(:,(successful_loops+smooth_starting_buffer)) = transformed_baton_tip_pos;
            raw_array_times(successful_loops+smooth_starting_buffer) = time_stamp;
            palm_pos_whole_array(:,(successful_loops+smooth_starting_buffer)) = palm_pos;

            cols_with_all_zeros = find(all(transformed_baton_tip_pos_raw_array(:, (smooth_starting_buffer+1):end)==0), 1);

            % smooth the raw data array
            transformed_baton_tip_pos_smoothed_array = smoothdata(transformed_baton_tip_pos_raw_array(:,1:(cols_with_all_zeros+smooth_starting_buffer)),2,"gaussian",10);
            smoothed_array_times = raw_array_times(1:(cols_with_all_zeros+smooth_starting_buffer));

            % only plot non zero bits
            firstNonzeroPalmIndex = find(palm_pos_whole_array(1,:), 1, 'first');
            lastNonzeroPalmIndex = find(palm_pos_whole_array(1,:), 1, 'last');

            firstNonzeroBatonRawIndex = find(transformed_baton_tip_pos_raw_array(1,:), 1, 'first');
            lastNonzeroBatonRawIndex = find(transformed_baton_tip_pos_raw_array(1,:), 1, 'last');

            firstNonzeroBatonSmoothIndex = find(transformed_baton_tip_pos_smoothed_array(1,:), 1, 'first')+smooth_starting_buffer;
            lastNonzeroBatonSmoothIndex = find(transformed_baton_tip_pos_smoothed_array(1,:), 1, 'last');
            lastNonzeroBatonSmoothIndex = lastNonzeroBatonSmoothIndex - smooth_starting_buffer;


            % start when smoothing buffer allows
            if (successful_loops > smooth_starting_buffer)
                set(plts{6}, 'XData', transformed_baton_tip_pos_smoothed_array(1,firstNonzeroBatonSmoothIndex:lastNonzeroBatonSmoothIndex), 'YData', transformed_baton_tip_pos_smoothed_array(2, firstNonzeroBatonSmoothIndex:lastNonzeroBatonSmoothIndex), 'ZData',  transformed_baton_tip_pos_smoothed_array(3, firstNonzeroBatonSmoothIndex:lastNonzeroBatonSmoothIndex));
                set(plts{5}, 'XData', transformed_baton_tip_pos_raw_array(1,firstNonzeroBatonRawIndex:lastNonzeroBatonRawIndex), 'YData', transformed_baton_tip_pos_raw_array(2,firstNonzeroBatonRawIndex:lastNonzeroBatonRawIndex), 'ZData', transformed_baton_tip_pos_raw_array(3,firstNonzeroBatonRawIndex:lastNonzeroBatonRawIndex));
                set(plts{4}, 'XData', palm_pos_whole_array(1, firstNonzeroPalmIndex:lastNonzeroPalmIndex), 'YData', palm_pos_whole_array(2,firstNonzeroPalmIndex:lastNonzeroPalmIndex), 'ZData',  palm_pos_whole_array(3, firstNonzeroPalmIndex:lastNonzeroPalmIndex));
                drawnow
            end
            
            plot_duration = toc*1000;
            successful_loops = successful_loops + 1;
            
        end

        time_left_in_loop = loop_time-plot_duration-gather_duration;
        total_duration = total_duration + plot_duration + gather_duration;

        if (time_left_in_loop > 0)
            java.lang.Thread.sleep(time_left_in_loop);
        end

        all_loops = all_loops + 1;
    end


    clear t;
    save_system_data(expID, transformed_baton_tip_pos_smoothed_array, smoothed_array_times, firstNonzeroBatonSmoothIndex, lastNonzeroBatonSmoothIndex)
    legend('Palm Position', 'Baton Tip Position', 'Smoothed Baton Tip Position', Location='northeast')
    save_graph(myGuidController)

end

function myKeyPressFcn(~, ~)
    KEY_IS_PRESSED  = 1;
    disp('key is pressed')
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

function save_graph(myGuidController)
    % get graph details
    graphDetails = 'Palm Position and Baton tip position - transformed IMU CJMCU-20948 Data Reading and single hand Leap LM-010 Reading';
    dataset = "Live test data from raw imu reading and raw leap reading. Loop every 20ms, imufilter sample rate 5000. arduino internal delay 200. only plotting last 500 values";
    folderToSaveIn = 'Visualisations/IMU_Leap_CombinedData';   % Your destination folder
    
    % add to GUID directory
    descriptionToUse = sprintf("Details: %s. Script used: %s.  Dataset used: %s. File Location: %s. Date Generated: %s", graphDetails, mfilename, dataset, folderToSaveIn, datetime('now'));
    GUIDToAppend = myGuidController.updateGuidDirectory(descriptionToUse).currGUID;
    
    % save all figures
    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
    myGuidController.saveFigures(graphDetails, GUIDToAppend, FigList, folderToSaveIn);

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

function setGlobalRotm(val)
    global rotmGlobal
    rotmGlobal = val;
end

function r = getGlobalRotm
    global rotmGlobal
    r = rotmGlobal;
end

function [baton_tip_pos, imu_exists] = manipulate_imu(IMU_reading, FUSE, baton_length)

    % process IMU reading into array
    [out_array, status] = str2num(IMU_reading);

    if (status && isequal(size(out_array), [3,3]))
        imu_exists = 1;

        % get orientation quarternion
        accelReadings = out_array(1,:);
        gyroReadings = out_array(2,:);
        orientation_quarternion = FUSE(accelReadings,gyroReadings);

        % transform baton tip pose
        rotm0 = getGlobalRotm();
        rotm = rotm0\quat2rotm(orientation_quarternion);
        baton_tip_pos = rotm(:,2) .* baton_length;

    else
        imu_exists = 0;
        baton_tip_pos = [0;0;0];
    end
end

function [palm_pos, leap_exists] = manipulate_leap(Leap_reading)
    
    % extract hands struct
    hands = Leap_reading.hands;
    
    if (~isempty(hands))
        leap_exists = 1;

        % extract palm pos
        palm = hands(1).palm;
        palm_pos = (palm.position)'; 
        
    else
        leap_exists = 0;
        palm_pos = [0;0;0];
    end
end