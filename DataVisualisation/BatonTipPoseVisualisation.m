






batonTipData = load('DataManipulation\BatonTipPose_08_03_23.mat').batonTipData;
myGuidController = GUID_Controller;
close all;
% plot the baton tip pose
basepoint = [0,0,0];

figure;
hold on;
view(-37.5, 30)
title("Baton Tip Pose from IMU Orientation")
plot3(basepoint(1), basepoint(2), basepoint(3), 'Color', 'k', 'Marker','x', 'LineWidth',8)
plot3(squeeze(batonTipData(1,1,:)), squeeze(batonTipData(2,1,:)), squeeze(batonTipData(3,1,:)), 'Color', 'b', 'Marker','o')


% get graph details
graphDetails = 'Baton Tip Pose Transformation - IMU CJMCU-20948 Data Reading - Fused with imufilter - transformed with BatonTip_Transformation';
dataset = "IMU data: IMU_Orientation_Reading_08_03_23. Transformed Baton tip data: BatonTipPose_08_03_23.";
folderToSaveIn = 'Visualisations/IMU_TransformedBatonTipPose';   % Your destination folder

% add to GUID directory
descriptionToUse = sprintf("Details: %s. Script used: %s.  Dataset used: %s. File Location: %s. Date Generated: %s", graphDetails, mfilename, dataset, folderToSaveIn, datetime('now'));
GUIDToAppend = myGuidController.updateGuidDirectory(descriptionToUse).currGUID;

% save all figures
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
myGuidController.saveFigures(graphDetails, GUIDToAppend, FigList, folderToSaveIn);

