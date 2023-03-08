function m_0_T_i = matrix_0_T_i(joint_num, theta, d, a, alpha)

    % definitions
    % theta_i: joint angle
    % d_i: link offset
    % a_i: link length
    % alpha_i: link twist  - this is the angle between z_i-1 and z_i.
    
    if(joint_num == 1)
        matrix_1 = DH_transformation_matrix(theta(1), d(1), a(1), alpha(1));
    
        m_0_T_i = matrix_1;
    
    elseif(joint_num == 2)
    
        matrix_1 = DH_transformation_matrix(theta(1), d(1), a(1), alpha(1));
        matrix_2 = DH_transformation_matrix(theta(2), d(2), a(2), alpha(2));
    
        m_0_T_i = matrix_1 * matrix_2;
    
    elseif(joint_num == 3)
    
        matrix_1 = DH_transformation_matrix(theta(1), d(1), a(1), alpha(1));
        matrix_2 = DH_transformation_matrix(theta(2), d(2), a(2), alpha(2));
        matrix_3 = DH_transformation_matrix(theta(3), d(3), a(3), alpha(3));
    
        m_0_T_i = matrix_1 * matrix_2 * matrix_3;
    
    elseif(joint_num == 4)
    
        matrix_1 = DH_transformation_matrix(theta(1), d(1), a(1), alpha(1));
        matrix_2 = DH_transformation_matrix(theta(2), d(2), a(2), alpha(2));
        matrix_3 = DH_transformation_matrix(theta(3), d(3), a(3), alpha(3));
        matrix_4 = DH_transformation_matrix(theta(4), d(4), a(4), alpha(4));
    
        m_0_T_i = matrix_1 * matrix_2 * matrix_3 * matrix_4;
    
    elseif(joint_num == 5)
    
        matrix_1 = DH_transformation_matrix(theta(1), d(1), a(1), alpha(1));
        matrix_2 = DH_transformation_matrix(theta(2), d(2), a(2), alpha(2));
        matrix_3 = DH_transformation_matrix(theta(3), d(3), a(3), alpha(3));
        matrix_4 = DH_transformation_matrix(theta(4), d(4), a(4), alpha(4));
        matrix_5 = DH_transformation_matrix(theta(5), d(5), a(5), alpha(5));
    
        m_0_T_i = matrix_1 * matrix_2 * matrix_3 * matrix_4 * matrix_5;
    
    elseif(joint_num == 6)
    
        matrix_1 = DH_transformation_matrix(theta(1), d(1), a(1), alpha(1));
        matrix_2 = DH_transformation_matrix(theta(2), d(2), a(2), alpha(2));
        matrix_3 = DH_transformation_matrix(theta(3), d(3), a(3), alpha(3));
        matrix_4 = DH_transformation_matrix(theta(4), d(4), a(4), alpha(4));
        matrix_5 = DH_transformation_matrix(theta(5), d(5), a(5), alpha(5));
        matrix_6 = DH_transformation_matrix(theta(6), d(6), a(6), alpha(6));
    
        m_0_T_i = matrix_1 * matrix_2 * matrix_3 * matrix_4 * matrix_5 * matrix_6;
    
    else

        m_0_T_i = 0;
    
    end

end