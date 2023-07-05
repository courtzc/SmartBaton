
expID = "A1_System";


fileName = sprintf("Data/Session03_ManipulatedData/Time_SmoothBatonPosition/Time_Smooth_Baton_Pos_%s.mat", expID);
tXYZ_System = load(fileName).tXYZ_System;
figure
hold on
view(2)
% plot3(tXYZ_System(2,:), tXYZ_System(3,:), tXYZ_System(4,:))
plot3(tXYZ_System(:,2), tXYZ_System(:,3), tXYZ_System(:,4))
