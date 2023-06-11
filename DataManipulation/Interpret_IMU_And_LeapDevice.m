%% note
% press and hold key to finish the data capture and visualisation

function Read_IMU_And_LeapDevice
    myGuidController = GUID_Controller;
    close all;

    sample_rate = 5000; % this is a weird number and seems to need to be 1000 times more than the Hz.
    FUSE = imufilter('SampleRate',sample_rate);
    rotm0_known = load('Data\IMU_rotm0.mat').averages;
    setGlobalRotm(rotm0_known)

    %% file load
    IMU_and_Leap_filename = "Data\Session02_RawData\IMU_Leap_Data\Raw_IMU_and_Leap_Exp_1.1.B_8-59-10-59-25.mat";
    exp = "1.1.B";

    IMU_Readings = load(IMU_and_Leap_filename).IMU_readings;
    Leap_Readings = load(IMU_and_Leap_filename).Leap_readings;
    Times = load(IMU_and_Leap_filename).Times;


    %% inputs
    % how long is your baton?
    baton_length = 100;


    % how much of a tail would you like?
    data_array_size = 500;

    % how much of a fade out would you like on the tail?
    fade_out_size = 300; % the earliest n bits of data that aren't zero get faded out. the nth onwards, from the nonzero index, is plotted normally.
    
    %% plot

    % get handles to figure
    fig_handle=subplot(1,1,1);
    plts = cell(1,6);

    % initialise plot
    hold on;
    axis equal;
    titleName = sprintf("Leap Palm Positional Data & Baton Tip Pos from Calibration Exp %s", exp);
    title(titleName)
    view(2)
    colourAlt = {'#5A5A5A', '#B33300', '#00B3E6',  '#E6B333', '#80B300', '#3366E6', '#FF99E6', '#33FFCC', '#B366CC', '#4D8000', '#66664D', '#991AFF', '#E666FF', '#4DB3FF', '#1AB399', '#E666B3', '#33991A', '#CC9999', '#B3B31A', '#00E680',  '#4D8066', '#809980', '#E6FF80', '#1AFF33', '#999933', '#FF3380', '#CCCC00', '#66E64D', '#4D80CC', '#9900B3',  '#E64D66', '#4DB380', '#FF4D4D', '#99E6E6', '#6666FF'};
    colourAlt1Fade = '#BEBEBE'; % checked by making a lighter version of #5A5A5A in word
    colourAlt3Fade = '#A3EBFF'; % checked by making a lighter version of #00B3E6 in word
    colourAlt6Fade = '#C4D3F8'; % checked by making a lighter version of #3366E6 in word

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

    for i = 1:length(Times)
        tic
        total_duration = 0;
    
        % get frames
        [IMU_reading, Leap_reading] = get_frame(i, IMU_Readings, Leap_Readings);
%         [IMU_reading, Leap_reading] = get_frame(t);
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
%                 disp("sliding now")
                % raw baton tip
                transformed_baton_tip_pos_raw_array(:,1:end-1) = transformed_baton_tip_pos_raw_array(:,2:end);
                transformed_baton_tip_pos_raw_array(:,end) = transformed_baton_tip_pos;
                % smoothed baton tip (different process)
                transformed_baton_tip_pos_smoothed_array = smoothdata(transformed_baton_tip_pos_raw_array,2,"gaussian",10);
                % palm
                palm_pos_whole_array(:,1:end-1) = palm_pos_whole_array(:,2:end);
                palm_pos_whole_array(:,end) = palm_pos;
%                 fprintf("[Raw  Array X] first: %.2f \t\t last: %.2f\n", transformed_baton_tip_pos_raw_array(1, 1), transformed_baton_tip_pos_raw_array(1, end));
%                 fprintf("[Palm Array X] first: %.2f \t\t last: %.2f\n", palm_pos_whole_array(1, 1), palm_pos_whole_array(1, end));
%                 fprintf("[Last palm non zero] %d\n",lastNonzeroPalmIndex);
                %% update plot data

                firstNonzeroPalmIndex = find(palm_pos_whole_array(1,:), 1, 'first');
                firstNonzeroBatonSmoothIndex = find(transformed_baton_tip_pos_smoothed_array(1,:), 1, 'first');
                firstNonzeroBatonRawIndex = find(transformed_baton_tip_pos_raw_array(1,:), 1, 'first');
%                 disp("updating data!")


                
                % note: fade data first so it's at the back
                % earliest little bit of data to fade
                set(plts{3}, 'XData', transformed_baton_tip_pos_smoothed_array(1,firstNonzeroBatonSmoothIndex:(firstNonzeroBatonSmoothIndex+fade_out_size)), 'YData', transformed_baton_tip_pos_smoothed_array(2,firstNonzeroBatonSmoothIndex:(firstNonzeroBatonSmoothIndex+fade_out_size)), 'ZData',  transformed_baton_tip_pos_smoothed_array(3,firstNonzeroBatonSmoothIndex:(firstNonzeroBatonSmoothIndex+fade_out_size)));
                set(plts{2}, 'XData', transformed_baton_tip_pos_raw_array(1,firstNonzeroBatonRawIndex:(firstNonzeroBatonRawIndex+fade_out_size)), 'YData', transformed_baton_tip_pos_raw_array(2,firstNonzeroBatonRawIndex:(firstNonzeroBatonRawIndex+fade_out_size)), 'ZData',  transformed_baton_tip_pos_raw_array(3,firstNonzeroBatonRawIndex:(firstNonzeroBatonRawIndex+fade_out_size)));
                set(plts{1}, 'XData', palm_pos_whole_array(1,firstNonzeroPalmIndex:(firstNonzeroPalmIndex+fade_out_size)), 'YData', palm_pos_whole_array(2,firstNonzeroPalmIndex:(firstNonzeroPalmIndex+fade_out_size)), 'ZData',  palm_pos_whole_array(3,firstNonzeroPalmIndex:(firstNonzeroPalmIndex+fade_out_size)));
                

                % latest 90% ish of data
                set(plts{6}, 'XData', transformed_baton_tip_pos_smoothed_array(1,(firstNonzeroBatonSmoothIndex+fade_out_size):end), 'YData', transformed_baton_tip_pos_smoothed_array(2,(firstNonzeroBatonSmoothIndex+fade_out_size):end), 'ZData',  transformed_baton_tip_pos_smoothed_array(3,(firstNonzeroBatonSmoothIndex+fade_out_size):end));
                set(plts{5}, 'XData', transformed_baton_tip_pos_raw_array(1,(firstNonzeroBatonRawIndex+fade_out_size):end), 'YData', transformed_baton_tip_pos_raw_array(2,(firstNonzeroBatonRawIndex+fade_out_size):end), 'ZData',  transformed_baton_tip_pos_raw_array(3,(firstNonzeroBatonRawIndex+fade_out_size):end));
                set(plts{4}, 'XData', palm_pos_whole_array(1,(firstNonzeroPalmIndex+fade_out_size):end), 'YData', palm_pos_whole_array(2,(firstNonzeroPalmIndex+fade_out_size):end), 'ZData',  palm_pos_whole_array(3,(firstNonzeroPalmIndex+fade_out_size):end));
                

                drawnow
            % but at the beginning, we need to build up the arrays
            else
                transformed_baton_tip_pos_raw_array(:,(successful_loops+smooth_starting_buffer)) = transformed_baton_tip_pos;
                palm_pos_whole_array(:,(successful_loops+smooth_starting_buffer)) = palm_pos;

                cols_with_all_zeros = find(all(transformed_baton_tip_pos_raw_array(:, (smooth_starting_buffer+1):end)==0), 1);
    
                % smooth the raw data array
                transformed_baton_tip_pos_smoothed_array = smoothdata(transformed_baton_tip_pos_raw_array(:,1:(cols_with_all_zeros+smooth_starting_buffer)),2,"gaussian",10);

%                 fprintf("[Raw  Array X] first: %.2f \t\t last: %.2f\n", transformed_baton_tip_pos_raw_array(1, (smooth_starting_buffer+1)), transformed_baton_tip_pos_raw_array(1, (end-smooth_starting_buffer-1)));
%                 fprintf("[Palm Array X] first: %.2f \t\t last: %.2f\n", palm_pos_whole_array(1, (smooth_starting_buffer+1)), palm_pos_whole_array(1, (end-smooth_starting_buffer-1)));
%                 fprintf("[Last palm non zero] %d\n",lastNonzeroPalmIndex);
% %                 sprintf("[Raw Array] first: %.2f \t\t last: %.2f", transformed_baton_tip_pos_raw_array(1, smooth_starting_buffer), transformed_baton_tip_pos_raw_array(1, (end-smooth_starting_buffer)));

                % only plot non zero bits
                firstNonzeroPalmIndex = find(palm_pos_whole_array(1,:), 1, 'first');
                firstNonzeroBatonSmoothIndex = find(transformed_baton_tip_pos_smoothed_array(1,:), 1, 'first')+smooth_starting_buffer;
                firstNonzeroBatonRawIndex = find(transformed_baton_tip_pos_raw_array(1,:), 1, 'first');

                lastNonzeroPalmIndex = find(palm_pos_whole_array(1,:), 1, 'last');
                lastNonzeroBatonSmoothIndex = find(transformed_baton_tip_pos_smoothed_array(1,:), 1, 'last');
                lastNonzeroBatonRawIndex = find(transformed_baton_tip_pos_raw_array(1,:), 1, 'last');
                
                lastNonzeroBatonSmoothIndex = lastNonzeroBatonSmoothIndex - smooth_starting_buffer;


                % start after a bit of time
                if (successful_loops > smooth_starting_buffer)
%                     disp("updating data!")
                    set(plts{6}, 'XData', transformed_baton_tip_pos_smoothed_array(1,firstNonzeroBatonSmoothIndex:lastNonzeroBatonSmoothIndex), 'YData', transformed_baton_tip_pos_smoothed_array(2,firstNonzeroBatonSmoothIndex:lastNonzeroBatonSmoothIndex), 'ZData',  transformed_baton_tip_pos_smoothed_array(3,firstNonzeroBatonSmoothIndex:lastNonzeroBatonSmoothIndex));
                    set(plts{5}, 'XData', transformed_baton_tip_pos_raw_array(1,firstNonzeroBatonRawIndex:lastNonzeroBatonRawIndex), 'YData', transformed_baton_tip_pos_raw_array(2,firstNonzeroBatonRawIndex:lastNonzeroBatonRawIndex), 'ZData',  transformed_baton_tip_pos_raw_array(3,firstNonzeroBatonRawIndex:lastNonzeroBatonRawIndex));
                    set(plts{4}, 'XData', palm_pos_whole_array(1,firstNonzeroPalmIndex:lastNonzeroPalmIndex), 'YData', palm_pos_whole_array(2,firstNonzeroPalmIndex:lastNonzeroPalmIndex), 'ZData',  palm_pos_whole_array(3,firstNonzeroPalmIndex:lastNonzeroPalmIndex));
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
    legend('Palm Position', 'Baton Tip Position', 'Smoothed Baton Tip Position', Location='best')
    save_graph(myGuidController)

    figure();
    hold on;
    plot(get_frame_durations)
    plot(manipulate_imu_durations)
    plot(manipulate_leap_durations)
    plot(plot_durations)
    plot(total_durations)
    legend('get frame', 'manipulate imu', 'manipulate leap', 'plot', 'total')

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

function [IMU_reading, Leap_reading] = get_frame(i, IMU_readings, Leap_readings)
    % get IMU data
%     IMU_reading = fscanf(s);
%     IMU_reading = read(t);

    IMU_reading = IMU_readings{i};
    
    
    % get Leap frame
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
%     IMU_reading_str = char(IMU_reading);
%     disp("maniuplating imu")
%     [out_array, status] = str2num(IMU_reading_str);
    try
        [out_array, status] = str2num(IMU_reading);
    catch
        status = 0;
    end
    
%     disp(status)

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
%             setGlobalRotm(rotmToSet)
            disp('found a quarternion')
            baton_tip_pos = rotm0(:,2) .* baton_length;
        else
            %% transform baton tip pose
            rotm = rotm0\quat2rotm(orientation_quarternion);
            baton_tip_pos = rotm(:,2) .* baton_length;
        end


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