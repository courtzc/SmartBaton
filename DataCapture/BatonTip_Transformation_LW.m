% we do three transforms, one for each degree of freedom of the IMU

%% inputs
orientation_quarternion = load('IMU_Orientation_Reading_17_03_23_2.mat').orientation;
baton_length = 0.2;

rotm0 = quat2rotm(orientation_quarternion(1));
% rotm0 = [
% 
%     0.9939    0.1095    0.0158
%     0.0034    0.1119   -0.9937
%    -0.1105    0.9877    0.1108
% ];

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

p0_alt = zeros(3,length(orientation_quarternion));


%% calculations

for i = 1:length(orientation_quarternion)

    rotm = rotm0\quat2rotm(orientation_quarternion(i));
    p0_alt(:,i) = rotm(:,2) .* baton_length;

end
figure
hold on
view(2)
plot3(p0_alt(1,:),p0_alt(2,:),p0_alt(3,:));
axis equal;