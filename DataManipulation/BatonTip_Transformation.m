% we do three transforms, one for each degree of freedom of the IMU

%% inputs
orientation_quarternion = load('IMU_Orientation_Reading_08_03_23.mat').orientation;
baton_length = 0.2;


%% info
% table like this (think of the baton base as a spherical wrist): all numbers will be the same, only those 4 variables
% will change
% ----------------------------------
%  i | theta_i | d_i | a_i | alpha_i
% ----------------------------------
%  4 |    xx   |  0  |  0  |  -90
% ----------------------------------
%  5 |    xx   |  0  |  0  |   90
% ----------------------------------
%  6 |    xx   |  d1 |  0  |   0
% ----------------------------------

% NOTE: DEG2RAD FOR ALL ALPHAS PLEASE
% NOTE: FOR ALPHA, IF ROTATING CLOCKWISE, IS -X DEG (E.G. -90 DEG)


% All of these will remain the same every time.
alpha = [deg2rad(-90), deg2rad(90), 0];
d = [0, 0, baton_length];
a = [0, 0, 0];

% assuming zero translation until we have that information
pose_init = [0; 0; 0];
basepoint = [0,0,0];

%% calculations


batonTipPose = zeros(3,1,length(orientation_quarternion));

for i = 1:length(orientation_quarternion)

    % get next orientations from quarternion, convert to eul for theta
    example_eul = quat2eul(orientation_quarternion(i));
    theta = [example_eul(3), example_eul(2), example_eul(1)];

    % perform the 3 transformations for the spherical wrist of baton base
    m_0_T_i = matrix_0_T_i(3, theta, d, a, alpha);

    % extract resulting pose
    p0 = m_0_T_i(1:3,4);
    batonTipPose(:,:,i) = p0;

    rotm = quat2rotm(orientation_quarternion(i));

    p02 = baton_length * rotm(:,3);

    if (p0 ~= p02)
        disp("did not match")
    end


end
