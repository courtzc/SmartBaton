% MATLAB data for reading Arduino serial prinout data
% reset
if (~isempty(instrfindall))
    fclose(instrfindall);
    delete(instrfindall);
end

close all;
myGuidController = GUID_Controller;

% start
s = serial('COM3'); % change this to desired Arduino board port
set(s,'BaudRate',115200); % baud rate for communication
fopen(s); % open the comm between Arduino and MATLAB


% read in 100 lines of IMU data
IMU_data = zeros(3,3,1000);
i = 1;
while i < 1000
    out = fscanf(s);
    disp("------- line of data --------")
    disp("out:")
    disp(out)
    [out_array, status] = str2num(out);

    if (status)
        IMU_data(:,:,i) = out_array;
        i = i + 1;
    end

end

% close connection to serial port
fclose(s)
delete(s)

% plot data
figure('Position', [100 100 1400 420]);
hold on;

% sgtitle("IMU Data Reading - Raw Plots")

subplot(1,3,1)
hold on;
title("IMU Data - Accelerometer")
view(-37.5, 30)
plot3(squeeze(IMU_data(1,1,:)), squeeze(IMU_data(1,2,:)), squeeze(IMU_data(1,3,:)))

subplot(1,3,2)
hold on;
title("IMU Data - Gyrometer")
view(-37.5, 30)
plot3(squeeze(IMU_data(2,1,:)), squeeze(IMU_data(2,2,:)), squeeze(IMU_data(2,3,:)))

subplot(1,3,3)
hold on;
title("IMU Data - Magnometer")
view(-37.5, 30)
plot3(squeeze(IMU_data(3,1,:)), squeeze(IMU_data(3,2,:)), squeeze(IMU_data(3,3,:)))


% get graph details
graphDetails = 'IMU CJMCU-20948 Raw Data Reading - Raw Plots of 100 points of Accel Gyro and Magnometer data separately';

% save in GUID directory, get GUID
folderToSaveIn = 'Visualisations/IMU_RealRawData';   % Your destination folder
descriptionToUse = sprintf("Details: %s. Script used: %s.  Dataset used: Arduino Serial Output of IMU CJMCU-20948. File Location: %s. Date Generated: %s", graphDetails, mfilename, folderToSaveIn, datetime('now'));
GUIDToAppend = myGuidController.updateGuidDirectory(descriptionToUse).currGUID;


% set title
sgtitle(strrep(graphDetails, '_', ' '))

% get all open figures, add GUID to file name 
figureSaveTitle = sprintf('%s_%s.fig', strrep(graphDetails, ' ', '_'), GUIDToAppend);
pngSaveTitle = sprintf('%s_%s.png', strrep(graphDetails, ' ', '_'), GUIDToAppend);

FigList = findobj(allchild(0), 'flat', 'Type', 'figure');

% save all open figures
for iFig = 1:length(FigList)
  FigHandle = FigList(iFig);
  FigName   = figureSaveTitle;
  pngName   = pngSaveTitle;
  fprintf("now saving: %s\n", FigName)
  saveas(FigHandle, fullfile(folderToSaveIn, FigName));
  saveas(FigHandle, fullfile(folderToSaveIn, pngName));
end
