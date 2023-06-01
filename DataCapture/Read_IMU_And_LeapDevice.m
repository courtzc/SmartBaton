%% note
% press and hold key to finish the data capture and visualisation

function Read_IMU_And_LeapDevice
    myGuidController = GUID_Controller;
    close all;

    IPAddress = '192.168.1.199'; % Replace with the IP address of the Wi-Fi device
    PortNumber = 23; % Replace with the port number of the Wi-Fi device
    t = tcpclient(IPAddress, PortNumber);
    disp(t)
% 
%     % IMU config
%     if (~isempty(instrfindall))
%         fclose(instrfindall);
%         delete(instrfindall);
%     end
%     
%     s = serial('COM3'); % change this to desired Arduino board port
%     set(s,'BaudRate',250000); % baud rate for communication
%     fopen(s); % open the comm between Arduino and MATLAB

    sample_rate = 5000; % this is a weird number and seems to need to be 1000 times more than the Hz.
    FUSE = imufilter('SampleRate',sample_rate);
    setGlobalRotm(zeros(3,3))



    %% inputs
    % how long is your baton?
    baton_length = 200;

    % how much of a tail would you like?
    data_array_size = 500;

    % how big will your arrays be?
    save_array_size = 5000;
    
    %% plot

    % setup exit key
    KEY_IS_PRESSED = 0;
    gcf;
    set(gcf, 'KeyPressFcn', @myKeyPressFcn)
    set(gcf,'pos',[300 100 1000 800])




    % get handles to figure
    fig_handle=subplot(1,1,1);
    plts = cell(1,3);

    % initialise plot
    hold on;
    axis equal;
    titleName = sprintf("Leap Palm Positional Data & Baton Tip Pos from IMU %s", datetime('now'));
    title(titleName)
    view(2)
    colourAlt = {'#FF6633', '#B33300', '#00B3E6',  '#E6B333', '#80B300', '#3366E6', '#FF99E6', '#33FFCC', '#B366CC', '#4D8000', '#66664D', '#991AFF', '#E666FF', '#4DB3FF', '#1AB399', '#E666B3', '#33991A', '#CC9999', '#B3B31A', '#00E680',  '#4D8066', '#809980', '#E6FF80', '#1AFF33', '#999933', '#FF3380', '#CCCC00', '#66E64D', '#4D80CC', '#9900B3',  '#E64D66', '#4DB380', '#FF4D4D', '#99E6E6', '#6666FF'};

    xlabel('x')
    ylabel('y (leap z)')
    zlabel('z (leap y)')

    % set up the three plot3s of the palm data, baton tip data, and smoothed baton tip data.
    plts{1} = plot3(fig_handle,[0,1],[0,1],[0,1],'color','#5A5A5A','linewidth',2);
    plts{2} = plot3(fig_handle,[0,1],[0,1],[0,1],'color',colourAlt{3});
    plts{3} = plot3(fig_handle,[0,1],[0,1],[0,1],'color', colourAlt{6}, LineWidth=4);




    % smooth data buffer
    smooth_starting_buffer = 10;

    % initialise arrays
    transformed_baton_tip_pos_raw_array = zeros(3,data_array_size);
    palm_pos_whole_array = zeros(3,data_array_size);

    palm_pos_array_save = zeros(3, save_array_size);
    transformed_baton_tip_pos_raw_array_save = zeros(3, save_array_size);
    transformed_baton_tip_pos_smoothed_array_save = zeros(3, save_array_size);

    % how often the loop runs
    loop_time = 20; %ms
    
    % loop counters
    successful_loops = 1;
    all_loops = 0;

    get_frame_durations = zeros(500);
    manipulate_imu_durations = zeros(500);
    manipulate_leap_durations = zeros(500);
    plot_durations = zeros(500);
    total_durations = zeros(500);

    get_frame_duration = 0;
    manipulate_imu_duration = 0;
    manipulate_leap_duration = 0;
    plot_duration = 0;

    while(~KEY_IS_PRESSED)
        tic
        total_duration = 0;
    
        % get frames
%         [IMU_reading, Leap_reading] = get_frame(s);
        [IMU_reading, Leap_reading] = get_frame(t);
            get_frame_duration = toc*1000;
            total_duration = total_duration + get_frame_duration;
            fprintf("get_frame: %.2fms\t", get_frame_duration) % it's the IMU frame that's occasionally slow. leap is consistently under 0.1ms. IMU is usually ~0.4ms, sometimes randomly 10 or 20ms.
            tic
        
        % extract IMU data
        [baton_tip_pos, imu_exists] = manipulate_imu(IMU_reading, FUSE, baton_length);
            manipulate_imu_duration = toc*1000;
            total_duration = total_duration + manipulate_imu_duration;
            fprintf("manipulate_imu: %.2fms\t", manipulate_imu_duration)
            tic
        
        % extract Leap data
        [palm_pos, leap_exists] = manipulate_leap(Leap_reading);
            manipulate_leap_duration = toc*1000;
            total_duration = total_duration + manipulate_leap_duration;
            fprintf("manipulate_leap: %.2fms\t", manipulate_leap_duration)
            tic
        
        if (imu_exists + leap_exists == 2)

            % transform baton tip
            transformed_baton_tip_pos = [baton_tip_pos(1) + palm_pos(1); baton_tip_pos(2) + palm_pos(2); baton_tip_pos(3) + palm_pos(3)];

            % once we get to the sliding window size point, we can slide along the smoothed window.
            if (successful_loops > (data_array_size - smooth_starting_buffer - 1))              
                %% remove the first (oldest) element of the array, add the new one
                % raw baton tip
                transformed_baton_tip_pos_raw_array(:,1:end-1) = transformed_baton_tip_pos_raw_array(:,2:end);
                transformed_baton_tip_pos_raw_array(:,end) = transformed_baton_tip_pos;
                % smoothed baton tip (different process)
                transformed_baton_tip_pos_smoothed_array = smoothdata(transformed_baton_tip_pos_raw_array,2,"gaussian",10);
                % palm
                palm_pos_whole_array(:,1:end-1) = palm_pos_whole_array(:,2:end);
                palm_pos_whole_array(:,end) = palm_pos;

                %% save overall data
                start_of_smoothed_data = successful_loops - length(transformed_baton_tip_pos_raw_array);
                palm_pos_array_save(:,successful_loops) = palm_pos;
                transformed_baton_tip_pos_raw_array_save(:, successful_loops) = transformed_baton_tip_pos;
                transformed_baton_tip_pos_smoothed_array_save(:, start_of_smoothed_data:successful_loops) = transformed_baton_tip_pos_smoothed_array;


                %% update plot data
                set(plts{3}, 'XData', transformed_baton_tip_pos_smoothed_array(1,:), 'YData', transformed_baton_tip_pos_smoothed_array(2,:), 'ZData',  transformed_baton_tip_pos_smoothed_array(3,:));
                set(plts{2}, 'XData', transformed_baton_tip_pos_raw_array(1,:), 'YData', transformed_baton_tip_pos_raw_array(2,:), 'ZData',  transformed_baton_tip_pos_raw_array(3,:));
                set(plts{1}, 'XData', palm_pos_whole_array(1,:), 'YData', palm_pos_whole_array(2,:), 'ZData',  palm_pos_whole_array(3,:));
                

            % but at the beginning, we need to build up the arrays
            else
                transformed_baton_tip_pos_raw_array(:,(successful_loops+smooth_starting_buffer)) = transformed_baton_tip_pos;
                palm_pos_whole_array(:,(successful_loops+smooth_starting_buffer)) = palm_pos;

                cols_with_all_zeros = find(all(transformed_baton_tip_pos_raw_array(:, (smooth_starting_buffer+1):end)==0), 1);
    
                % smooth the raw data array
                transformed_baton_tip_pos_smoothed_array = smoothdata(transformed_baton_tip_pos_raw_array(:,1:(cols_with_all_zeros+smooth_starting_buffer)),2,"gaussian",10);
                
                % start after a bit of time
                if (successful_loops > smooth_starting_buffer)
                    set(plts{3}, 'XData', transformed_baton_tip_pos_smoothed_array(1,smooth_starting_buffer:(end-smooth_starting_buffer)), 'YData', transformed_baton_tip_pos_smoothed_array(2,smooth_starting_buffer:(end-smooth_starting_buffer)), 'ZData',  transformed_baton_tip_pos_smoothed_array(3,smooth_starting_buffer:(end-smooth_starting_buffer)));
                    set(plts{2}, 'XData', transformed_baton_tip_pos_raw_array(1,smooth_starting_buffer:(end-smooth_starting_buffer)), 'YData', transformed_baton_tip_pos_raw_array(2,smooth_starting_buffer:(end-smooth_starting_buffer)), 'ZData',  transformed_baton_tip_pos_raw_array(3,smooth_starting_buffer:(end-smooth_starting_buffer)));
                    set(plts{1}, 'XData', palm_pos_whole_array(1,smooth_starting_buffer:(end-smooth_starting_buffer)), 'YData', palm_pos_whole_array(2,smooth_starting_buffer:(end-smooth_starting_buffer)), 'ZData',  palm_pos_whole_array(3,smooth_starting_buffer:(end-smooth_starting_buffer)));
                    drawnow
                end
            end


                plot_duration = toc*1000;
                total_duration = total_duration + plot_duration;
                fprintf("plot: %.2fms\t", plot_duration)
                tic

            
            get_frame_durations(all_loops) = get_frame_duration;
            manipulate_imu_durations(all_loops) = manipulate_imu_duration;
            manipulate_leap_durations(all_loops) = manipulate_leap_duration;
            plot_durations(all_loops) = plot_duration;
            total_durations(all_loops) = total_duration;
            successful_loops = successful_loops + 1;
            
        end
        fprintf("total_duration: %.2fms\n", total_duration)
        time_left_in_loop = loop_time-total_duration;
%         fprintf("time left before sleep: %.2fms\t", loop_time-total_duration)
        tic
        if (time_left_in_loop > 0)
            java.lang.Thread.sleep(time_left_in_loop);
        end

        all_loops = all_loops + 1;
    end


    clear t;
    legend('Palm Position', 'Baton Tip Position', 'Smoothed Baton Tip Position', Location='northeast')
    save_graph(myGuidController)
    save_data(palm_pos_array_save, transformed_baton_tip_pos_raw_array_save, transformed_baton_tip_pos_smoothed_array_save)


    figure();
    hold on;
    plot(get_frame_durations)
    plot(manipulate_imu_durations)
    plot(manipulate_leap_durations)
    plot(plot_durations)
    plot(total_durations)
    legend('get frame', 'manipulate imu', 'manipulate leap', 'plot', 'total')

    function myKeyPressFcn(hObject, event)
        KEY_IS_PRESSED  = 1;
        disp('key is pressed')
    end

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

function save_data(palm_pos_array_save, transformed_baton_tip_pos_raw_array_save, transformed_baton_tip_pos_smoothed_array_save)
    % get graph details
    save('palm_pos_array_save_1', "palm_pos_array_save");
    save('transformed_baton_tip_pos_raw_array_save_1', "transformed_baton_tip_pos_raw_array_save");
    save('transformed_baton_tip_pos_smoothed_array_save_1', "transformed_baton_tip_pos_smoothed_array_save");

end

function [IMU_reading, Leap_reading] = get_frame(t)
    % get IMU data
%     IMU_reading = fscanf(s);
    IMU_reading = read(t);
    
    
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

function [baton_tip_pos, imu_exists] = manipulate_imu(IMU_reading, FUSE, baton_length)
    IMU_reading_str = char(IMU_reading);
    [out_array, status] = str2num(IMU_reading_str);
%     disp(out_array)

    if (status && isequal(size(out_array), [3,3]))
        %% get orientation quarternion
        accelReadings = out_array(1,:);
        gyroReadings = out_array(2,:);
        imu_exists = 1;

        orientation_quarternion = FUSE(accelReadings,gyroReadings);

        rotm0 = getGlobalRotm();

        % if rotm0 hasn't been set, set it now
        if (~any(rotm0))
            rotmToSet = quat2rotm(orientation_quarternion);
            setGlobalRotm(rotmToSet)
            disp('found a quarternion')
        end

        %% transform baton tip pose
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
        palm_pos = (palm.position)'; % making this a column vector to match others
%         disp("palm pos")
%         disp(palm_pos)
        leap_exists = 1;
    else
        leap_exists = 0;
        palm_pos = [0;0;0];
    end
end