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
    set(s,'BaudRate',115200); % baud rate for communication
    fopen(s); % open the comm between Arduino and MATLAB

    sample_rate = 1000; % Hz
    FUSE = imufilter('SampleRate',sample_rate);
%     FUSE = imufilter();
        
    setGlobalRotm(zeros(3,3))


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
    view(3)
    colourAlt = {'#FF6633', '#B33300', '#00B3E6',  '#E6B333', '#80B300', '#3366E6', '#FF99E6', '#33FFCC', '#B366CC', '#4D8000', '#66664D', '#991AFF', '#E666FF', '#4DB3FF', '#1AB399', '#E666B3', '#33991A', '#CC9999', '#B3B31A', '#00E680',  '#4D8066', '#809980', '#E6FF80', '#1AFF33', '#999933', '#FF3380', '#CCCC00', '#66E64D', '#4D80CC', '#9900B3',  '#E64D66', '#4DB380', '#FF4D4D', '#99E6E6', '#6666FF'};
    plot3([0,20], [0,0], [0,0], 'color', 'b')
    plot3([0,0], [0,20], [0,0], 'color', 'r')
    plot3([0,0], [0,0], [0,20], 'color', 'g')
    xlabel('x')
    ylabel('y')
    zlabel('z')

    prev_transformed_baton_tip_pos = [0;0;0];
    prev_palm_pos = [0;0;0];

    % we're going to smooth the data. observation says that about 20 data
    % points are used in the smoothdata() sliding window. we'll have a
    % sliding array of 30 to give it a fair go.
    transformed_baton_tip_pos_raw_array = zeros(3,60);
     i = 1;

    tic;
    while(~KEY_IS_PRESSED)
        toc
        [IMU_reading, Leap_reading] = get_frame(s);
        [baton_tip_pos, imu_exists] = manipulate_imu(IMU_reading, FUSE, baton_length);
        [palm_pos, leap_exists] = manipulate_leap(Leap_reading);

        % #TOCHANGE i think we could try removing a chunk of old data from
        % the array every 1000 i or so (and bring i down by 1000), so that
        % we can preallocate the smooth array. It needs to be long enough
        % that matlab can choose the window helpfully.
        if (imu_exists + leap_exists == 2)
            
            % transform the baton tip (add the leap translation) assuming axes are lined up?: x y z -> x y z
            % i think they are (for right hands found in leap), based on: 
            % this pic https://littlebirdelectronics.com.au/products/9-axis-compass-module-cjmcu-mpu9150
            % and this pic https://developer.unigine.com/en/docs/latest/code/plugins/leapmotion/?rlang=cpp
            transformed_baton_tip_pos = [baton_tip_pos(1) + palm_pos(1); baton_tip_pos(2) + palm_pos(2); baton_tip_pos(3) + palm_pos(3)];
%             transformed_baton_tip_pos = baton_tip_pos;

            % remove the first (oldest) element of the array, add the new one
%             transformed_baton_tip_pos_raw_array(:,1:end-1) = transformed_baton_tip_pos_raw_array(:,2:end);
%             transformed_baton_tip_pos_raw_array(:,end) = transformed_baton_tip_pos;
            transformed_baton_tip_pos_raw_array = [transformed_baton_tip_pos_raw_array, transformed_baton_tip_pos];

            % smooth the raw data array with whatever window matlab deems best
            [transformed_baton_tip_pos_smoothed_array] = smoothdata(transformed_baton_tip_pos_raw_array,2);
%             window_array = [window_array, window];
%             if (window > 27)
%                 disp('large window detected')
%             elseif (window <10)
%                 disp('small window detected')
%             else
%                 disp('normal window detected')
%             end



            plot_frame(palm_pos, prev_palm_pos, transformed_baton_tip_pos, prev_transformed_baton_tip_pos, colourAlt{3})
            
            if (i > 20)
                w = i + 5; % number of points we're plotting at once for the smoothed array
                plot3(transformed_baton_tip_pos_smoothed_array(1,i:w),transformed_baton_tip_pos_smoothed_array(2,i:w),transformed_baton_tip_pos_smoothed_array(3,i:w),'color', 'b', LineWidth=4) ;
            end

            prev_transformed_baton_tip_pos = transformed_baton_tip_pos;
            prev_palm_pos = palm_pos;
            i = i + 1;

            if (i == 500)
                disp('break')
            end
        end

         java.lang.Thread.sleep((i-toc)*0.01);
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

    if (status)

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

        %% transform baton tip pose
        % All of these will remain the same every time.
%         alpha = [deg2rad(-90), deg2rad(90), 0];
%         d = [0, 0, baton_length];
%         a = [0, 0, 0];
% 
%         eul_angles = quat2eul(orientation_quarternion);  % get next orientations from quarternion, convert to eul for theta
%         theta = [eul_angles(3), eul_angles(2), eul_angles(1)];
%         matrix_1 = DH_transformation_matrix(theta(1), d(1), a(1), alpha(1));
%         matrix_2 = DH_transformation_matrix(theta(2), d(2), a(2), alpha(2));
%         matrix_3 = DH_transformation_matrix(theta(3), d(3), a(3), alpha(3));
%         m_0_T_i = matrix_1 * matrix_2 * matrix_3;
%         baton_tip_pos = m_0_T_i(1:3,4); % extract pose
%         disp("baton_tip_pos")
%         disp(baton_tip_pos)
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
    drawnow
end