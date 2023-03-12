% we do three transforms, one for each degree of freedom of the IMU

%% inputs
orientation_quarternion = load('IMU_Orientation_Reading_08_03_23.mat').orientation;
baton_length = 0.2;


%% info
% table like this (think of the baton base as a spherical wrist):
% ----------------------------------
%  i | theta_i | d_i | a_i | alpha_i
% ----------------------------------
%  4 |    xx   |  0  |  0  |  -90
% ----------------------------------
%  5 |    xx   |  0  |  0  |   90
% ----------------------------------
%  6 |    xx   |  d1 |  0  |   0
% ----------------------------------

% All of these will remain the same every time.
alpha = [deg2rad(-90), deg2rad(90), 0];
d = [0, 0, baton_length];
a = [0, 0, 0];


%% calculations

for i = 1:length(orientation_quarternion)
    %% method 1
    eul_angles = quat2eul(orientation_quarternion(i));  % get next orientations from quarternion, convert to eul for theta
    theta = [eul_angles(3), eul_angles(2), eul_angles(1)];
    matrix_1 = DH_transformation_matrix(theta(1), d(1), a(1), alpha(1));
    matrix_2 = DH_transformation_matrix(theta(2), d(2), a(2), alpha(2));
    matrix_3 = DH_transformation_matrix(theta(3), d(3), a(3), alpha(3));
    m_0_T_i = matrix_1 * matrix_2 * matrix_3;
    p0 = m_0_T_i(1:3,4); % extract pose

    %% method 2
    rotm = quat2rotm(orientation_quarternion(i));
    p0_alt = rotm(:,3) .* baton_length;

    %% check
    if (~isequal(p0, p0_alt))
        disp("did not match")
    end
end
