%% note
% press and hold key to finish the data capture and visualisation

function Read_IMU_And_LeapDevice
    myGuidController = GUID_Controller;
    close all;

    % IMU config
    if (~isempty(instrfindall))
        fclose(instrfindall);
        delete(instrfindall);
    end
    
    s = serial('COM3'); % change this to desired Arduino board port
    set(s,'BaudRate',250000); % baud rate for communication
    fopen(s); % open the comm between Arduino and MATLAB

    sample_rate = 5000; % Hz
    FUSE = imufilter('SampleRate',sample_rate);
%     FUSE = imufilter();
        
    setGlobalRotm(zeros(3,3))
    duration = 0.2; % duration of each loop, in seconds


    %% inputs
    baton_length = 200;
    
    %% plot
    % exit once a key is pressed
    KEY_IS_PRESSED = 0;
    gcf;
    set(gcf, 'KeyPressFcn', @myKeyPressFcn)
    set(gcf,'pos',[300 100 1000 800])
    % rest of plot set up
    hold on;
    axis equal;
    title("Leap Palm Positional Data & Baton Tip Pos from IMU 17/03/23")
    view(2)
    colourAlt = {'#FF6633', '#B33300', '#00B3E6',  '#E6B333', '#80B300', '#3366E6', '#FF99E6', '#33FFCC', '#B366CC', '#4D8000', '#66664D', '#991AFF', '#E666FF', '#4DB3FF', '#1AB399', '#E666B3', '#33991A', '#CC9999', '#B3B31A', '#00E680',  '#4D8066', '#809980', '#E6FF80', '#1AFF33', '#999933', '#FF3380', '#CCCC00', '#66E64D', '#4D80CC', '#9900B3',  '#E64D66', '#4DB380', '#FF4D4D', '#99E6E6', '#6666FF'};
    plot3([0,20], [0,0], [0,0], 'color', 'b')
    plot3([0,0], [0,20], [0,0], 'color', 'r')
    plot3([0,0], [0,0], [0,20], 'color', 'g')
    xlabel('x')
    ylabel('y')
    zlabel('z')

    prev_transformed_baton_tip_pos = [0;0;0];
    prev_palm_pos = [0;0;0];

    % smooth data parameters
    smooth_array_size = 2000;
    transformed_baton_tip_pos_raw_array = zeros(3,smooth_array_size);
    smooth_starting_buffer = 10;

    % duration checks
    loop_time = 200; %ms
    

    % loop counters
    successful_loops = 1;
    all_loops = 0;

%     tic;
    while(~KEY_IS_PRESSED)
        tic
        total_duration = 0;
        [IMU_reading, Leap_reading] = get_frame(s);
        duration = toc*1000;
        total_duration = total_duration + duration;
        fprintf("get_frame: %.2fms\t", duration)
        tic
        [baton_tip_pos, imu_exists] = manipulate_imu(IMU_reading, FUSE, baton_length);
        duration = toc*1000;
        total_duration = total_duration + duration;
        fprintf("manipulate_imu: %.2fms\t", duration)
        tic
        [palm_pos, leap_exists] = manipulate_leap(Leap_reading);
        duration = toc*1000;
        total_duration = total_duration + duration;
        fprintf("manipulate_leap: %.2fms\t", duration)
        
        % #TOCHANGE i think we could try removing a chunk of old data from
        % the array every 1000 i or so (and bring i down by 1000), so that
        % we can preallocate the smooth array. It needs to be long enough
        % that matlab can choose the window helpfully.
        if (imu_exists + leap_exists == 2)
            tic
            % transform the baton tip (add the leap translation) assuming axes are lined up?: x y z -> x y z
            % i think they are (for right hands found in leap), based on: 
            % this pic https://littlebirdelectronics.com.au/products/9-axis-compass-module-cjmcu-mpu9150
            % and this pic https://developer.unigine.com/en/docs/latest/code/plugins/leapmotion/?rlang=cpp
            transformed_baton_tip_pos = [baton_tip_pos(1) + palm_pos(1); baton_tip_pos(2) + palm_pos(2); baton_tip_pos(3) + palm_pos(3)];
%             transformed_baton_tip_pos = baton_tip_pos;


            % once we get to this point, we can slide along the smoothed window.
            if (successful_loops > (smooth_array_size - smooth_starting_buffer - 1))
                % remove the first (oldest) element of the array, add the new one
                transformed_baton_tip_pos_raw_array(:,1:end-1) = transformed_baton_tip_pos_raw_array(:,2:end);
                transformed_baton_tip_pos_raw_array(:,end) = transformed_baton_tip_pos;

                transformed_baton_tip_pos_smoothed_array = smoothdata(transformed_baton_tip_pos_raw_array,2,"gaussian",10);
                plot3(transformed_baton_tip_pos_smoothed_array(1,(end-5):end),transformed_baton_tip_pos_smoothed_array(2,(end-5):end),transformed_baton_tip_pos_smoothed_array(3,(end-5):end),'color', colourAlt{6}, LineWidth=4) ;


            % but at the beginning, we need to build up the smooth array
            else
                transformed_baton_tip_pos_raw_array(:,(successful_loops+smooth_starting_buffer)) = transformed_baton_tip_pos;
                cols_with_all_zeros = find(all(transformed_baton_tip_pos_raw_array(:, (smooth_starting_buffer+1):end)==0), 1);
%                 fprintf("first column: %d; ", cols_with_all_zeros)
    
                % smooth the raw data array with whatever window matlab deems best
                transformed_baton_tip_pos_smoothed_array = smoothdata(transformed_baton_tip_pos_raw_array(:,1:(cols_with_all_zeros+smooth_starting_buffer)),2,"gaussian",10);
                if (successful_loops > 40)
                    w = successful_loops + 5; % number of points we're plotting at once for the smoothed array
                    plot3(transformed_baton_tip_pos_smoothed_array(1,successful_loops:w),transformed_baton_tip_pos_smoothed_array(2,successful_loops:w),transformed_baton_tip_pos_smoothed_array(3,successful_loops:w),'color', colourAlt{6}, LineWidth=4) ;
                end
            end
            duration = toc*1000;
            total_duration = total_duration + duration;
            fprintf("plot smooth: %.2fms\t", duration)
            tic
            plot_frame(palm_pos, prev_palm_pos, transformed_baton_tip_pos, prev_transformed_baton_tip_pos, colourAlt{3})
            


            prev_transformed_baton_tip_pos = transformed_baton_tip_pos;
            prev_palm_pos = palm_pos;
            successful_loops = successful_loops + 1;

            duration = toc*1000;
            total_duration = total_duration + duration;
            fprintf("plot: %.2fms\t", duration)
            
        end
        fprintf("\n\ttotal_duration: %.2fms\t", total_duration)
        time_left_in_loop = loop_time-total_duration;
        fprintf("time left before sleep: %.2fms\t", loop_time-total_duration)
        tic
        if (time_left_in_loop > 0)
            java.lang.Thread.sleep(time_left_in_loop);
        end
        duration = toc*1000;
        total_duration = total_duration + duration;
        fprintf("time left after sleep: %.2fms\n", loop_time-total_duration)
%          error = abs(toc-duration);
%          fprintf('Time left to wait after %d, which is successful loop %d: %f ms\n', all_loops, successful_loops, time_left_in_loop)
         all_loops = all_loops + 1;
    end

    legend('x','y (leap z)','z (leap y)','Palm Position', 'Baton Tip Position', 'Smoothed Baton Tip Position', Location='northeast')
    save_graph(myGuidController)


    function myKeyPressFcn(hObject, event)
        KEY_IS_PRESSED  = 1;
        disp('key is pressed')
    end

end

function save_graph(myGuidController)
    % get graph details
    graphDetails = 'Palm Position and Baton tip position - transformed IMU CJMCU-20948 Data Reading and single hand Leap LM-010 Reading';
    dataset = "Live test data from raw imu reading and raw leap reading. baton length of 50 - transforming along z axis now.";
    folderToSaveIn = 'Visualisations/IMU_Leap_CombinedData';   % Your destination folder
    
    % add to GUID directory
    descriptionToUse = sprintf("Details: %s. Script used: %s.  Dataset used: %s. File Location: %s. Date Generated: %s", graphDetails, mfilename, dataset, folderToSaveIn, datetime('now'));
    GUIDToAppend = myGuidController.updateGuidDirectory(descriptionToUse).currGUID;
    
    % save all figures
    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
    myGuidController.saveFigures(graphDetails, GUIDToAppend, FigList, folderToSaveIn);

end

function [IMU_reading, Leap_reading] = get_frame(s)
    % get IMU data
    IMU_reading = fscanf(s);
    
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

    [out_array, status] = str2num(IMU_reading);
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

function plot_frame(palm_pos, prev_palm_pos, baton_tip_pos, prev_baton_tip_pos, colour)

    palm_pos_array = [palm_pos, prev_palm_pos];
    baton_tip_pos_array = [baton_tip_pos, prev_baton_tip_pos];
    % check IMU hasn't gone haywire. If it has, we'll plot it differently.
    distance_change = norm(baton_tip_pos - prev_baton_tip_pos);

    
    
    % plot leap data
    plot3(palm_pos_array(1,:),palm_pos_array(2,:),palm_pos_array(3,:),'color', '#5A5A5A', LineWidth=1) ;


    % conditionally plot IMU data.
    if(distance_change > 30)
        plot3(baton_tip_pos_array(1,:),baton_tip_pos_array(2,:),baton_tip_pos_array(3,:), 'color', 'r', LineWidth=0.1) ;
    else
        plot3(baton_tip_pos_array(1,:),baton_tip_pos_array(2,:),baton_tip_pos_array(3,:), 'color', colour, LineWidth=0.5) ;
    end

%     fprintf("plot_frame: %.2fms\t", toc*1000)
%     tic
%     
    drawnow
%     fprintf("drawnow: %.2fms\t", toc*1000)
%     tic
    

end