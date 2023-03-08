function matrix_0_T_1 = homogeneous_translation_matrix_along_axis_by_d(axis, d)
    
    switch axis
        
        case 'x'
        % Around the x-axis
        matrix_0_T_1 = [[1, 0, 0, d]
                        [0, 1, 0, 0]
                        [0, 0, 1, 0]
                        [0, 0, 0, 1]];
        case 'y'
        % Around the y-axis
        matrix_0_T_1 = [[1, 0, 0, 0]
                        [0, 1, 0, d]
                        [0, 0, 1, 0]
                        [0, 0, 0, 1]];
        case 'z'
        % Around the z-axis
        matrix_0_T_1 = [[1, 0, 0, 0]
                        [0, 1, 0, 0]
                        [0, 0, 1, d]
                        [0, 0, 0, 1]];
    end


end