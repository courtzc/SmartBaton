function matrix_0_R_1 = homogeneous_rotation_matrix_around_axis_by_theta(axis, theta)
    
    switch axis
        
        case 'x'
        % Around the x-axis
        matrix_0_R_1 = [[1,  0,          0,           0]
                        [0,  cos(theta), -sin(theta), 0]
                        [0,  sin(theta), cos(theta),  0]
                        [0,  0,          0,           1]];
        case 'y'
        % Around the y-axis
        matrix_0_R_1 = [[cos(theta),   0, sin(theta), 0]
                        [0,            1, 0         , 0]
                        [-sin(theta),  0, cos(theta), 0]
                        [0,            0, 0,          1]];
        case 'z'
        % Around the z-axis
        matrix_0_R_1 = [[cos(theta), -sin(theta),0, 0]
                        [sin(theta), cos(theta), 0, 0]
                        [0,          0,          1, 0]
                        [0,          0,          0, 1]];
    end


end