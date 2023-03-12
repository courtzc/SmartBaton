%% set up

function Read_IMU_And_LeapDevice


    % IMU config
    if (~isempty(instrfindall))
        fclose(instrfindall);
        delete(instrfindall);
    end
    
    s = serial('COM3'); % change this to desired Arduino board port
    set(s,'BaudRate',115200); % baud rate for communication
    fopen(s); % open the comm between Arduino and MATLAB
    FUSE = imufilter();
        


    %% inputs
    baton_length = 50;
    
    %% plot
    % exit once a key is pressed
    KEY_IS_PRESSED = 0;
    gcf
    set(gcf, 'KeyPressFcn', @myKeyPressFcn)
    % rest of plot set up
    hold on;
    axis equal;
    title("Leap Palm Positional Data & Baton Tip Pos from IMU 12/03/23")
    view([0,90])
    colourAlt = {'#FF6633', '#B33300', '#00B3E6',  '#E6B333', '#80B300', '#3366E6', '#FF99E6', '#33FFCC', '#B366CC', '#4D8000', '#66664D', '#991AFF', '#E666FF', '#4DB3FF', '#1AB399', '#E666B3', '#33991A', '#CC9999', '#B3B31A', '#00E680',  '#4D8066', '#809980', '#E6FF80', '#1AFF33', '#999933', '#FF3380', '#CCCC00', '#66E64D', '#4D80CC', '#9900B3',  '#E64D66', '#4DB380', '#FF4D4D', '#99E6E6', '#6666FF'};
    
    
    while(~KEY_IS_PRESSED)
        [IMU_reading, Leap_reading] = get_frame(s);
        [baton_tip_pos, imu_exists] = manipulate_imu(IMU_reading, FUSE, baton_length);
        [palm_pos, leap_exists] = manipulate_leap(Leap_reading);
        if (imu_exists + leap_exists == 2)
            
            % attempt1: x y z -> x y z
            new_baton_tip_pos = [baton_tip_pos(1) + palm_pos(1); baton_tip_pos(2) + palm_pos(2); baton_tip_pos(3) + palm_pos(3)];
            plot_frame(palm_pos, new_baton_tip_pos, colourAlt{3})
    
            % attempt2: x y z -> x z y
    %         new_baton_tip_pos = [baton_tip_pos(1) + palm_pos(1); baton_tip_pos(3) + palm_pos(2); baton_tip_pos(2) + palm_pos(3)];
    %         plot_frame(palm_pos, palm_pos+baton_tip_pos, colourAlt{4})
            
            % attempt3: x y z -> x z y
            
            % attempt4: x y z -> x z y
            % attempt5: x y z -> x z y
            % attempt6: x y z -> x z y
    
    %         plot_frame(palm_pos, palm_pos+baton_tip_pos)
        end
    end

    funct

    function myKeyPressFcn(hObject, event)
        KEY_IS_PRESSED  = 1;
        disp('key is pressed')
    end

end


function [IMU_reading, Leap_reading] = get_frame(s)
    % get IMU data
    IMU_reading = fscanf(s);
    
    % get Leap frame
    Leap_reading = matleap(1);
end

function [baton_tip_pos, imu_exists] = manipulate_imu(IMU_reading, FUSE, baton_length)

    [out_array, status] = str2num(IMU_reading);

    if (status)

        %% get orientation quarternion
        accelReadings = out_array(1,:);
        gyroReadings = out_array(2,:);
        imu_exists = 1;

        orientation_quarternion = FUSE(accelReadings,gyroReadings);
        

        %% transform baton tip pose
        % All of these will remain the same every time.
        alpha = [deg2rad(-90), deg2rad(90), 0];
        d = [0, 0, baton_length];
        a = [0, 0, 0];

        eul_angles = quat2eul(orientation_quarternion);  % get next orientations from quarternion, convert to eul for theta
        theta = [eul_angles(3), eul_angles(2), eul_angles(1)];
        matrix_1 = DH_transformation_matrix(theta(1), d(1), a(1), alpha(1));
        matrix_2 = DH_transformation_matrix(theta(2), d(2), a(2), alpha(2));
        matrix_3 = DH_transformation_matrix(theta(3), d(3), a(3), alpha(3));
        m_0_T_i = matrix_1 * matrix_2 * matrix_3;
        baton_tip_pos = m_0_T_i(1:3,4); % extract pose
        disp("baton_tip_pos")
        disp(baton_tip_pos)
    else
        imu_exists = 0;
        baton_tip_pos = [0;0;0];
    end



end

function [palm_pos, leap_exists] = manipulate_leap(Leap_reading)
    hands = Leap_reading.hands;
    if (~isempty(hands))
        palm = hands(1).palm;
        palm_pos = palm.position;
        leap_exists = 1;
    else
        leap_exists = 0;
        palm_pos = [0;0;0];
    end
end

function plot_frame(palm_pos, baton_tip_pos, colour)
    plot3(palm_pos(1),palm_pos(2),palm_pos(3), 'marker', 'o', 'color', 'r', LineWidth=2) ;
    plot3(baton_tip_pos(1),baton_tip_pos(2),baton_tip_pos(3), 'marker', 'o', 'color', colour, LineWidth=2) ;
    drawnow
end