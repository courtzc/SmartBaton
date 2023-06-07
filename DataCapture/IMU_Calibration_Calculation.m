
a(:,:,1:10) = load("IMU_Calibration_7-Jun-2023-20-46-05.mat").IMU_readings
a(:,:,11:20) = load("IMU_Calibration_7-Jun-2023-20-46-07.mat").IMU_readings
a(:,:,21:30) = load("IMU_Calibration_7-Jun-2023-20-46-09.mat").IMU_readings
a(:,:,31:40) = load("IMU_Calibration_7-Jun-2023-20-46-38.mat").IMU_readings
a(:,:,41:50) = load("IMU_Calibration_7-Jun-2023-20-46-50.mat").IMU_readings
a(:,:,51:60) = load("IMU_Calibration_7-Jun-2023-20-46-53.mat").IMU_readings

% 
disp(size(a))
averages = zeros(3,3);
stddevs = zeros(3,3);

for i = 1:3
    for j = 1:3
        averages(i,j) = mean(a(i,j,:));
        stddevs(i,j) = std(a(i,j,:));
    end
end

disp("averages:")
disp(averages)
disp("deviations: ")
disp(stddevs)

save('IMU_rotm0.mat', "averages");