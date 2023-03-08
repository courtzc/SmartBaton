function matrix = DH_transformation_matrix(theta_i, d_i, a_i, alpha_i)
    
    matrix = [[cos(theta_i), (-sin(theta_i)*cos(alpha_i)),  (sin(theta_i)*sin(alpha_i)),    (a_i*cos(theta_i))]
              [sin(theta_i), (cos(theta_i)*cos(alpha_i)),   (-cos(theta_i)*sin(alpha_i)),   (a_i*sin(theta_i))]
              [0,             sin(alpha_i),                 cos(alpha_i),                   d_i               ]
              [0,             0,                            0,                              1                 ]];

end