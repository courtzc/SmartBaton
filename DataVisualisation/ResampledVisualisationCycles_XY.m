close all;

myGuidController = GUID_Controller;

theFiles = [];
for j = 1:3
    miniPattern = "C:\Users\Court\source\repos\ThesisProject\" + ...
        "Data\Session01_ManipulatedData\SavedCycles_Resampled\" + ...
        "Session01_Exp_F1_*_SavedCycle_"+j+"*.mat";
    
    % collect the files
    theFiles = [theFiles; dir(miniPattern)];
    
end

figure;
hold on;
axis equal;


% do for every file in the files
for k = 1:length(theFiles)

    currFileName = theFiles(k).name;
    withFolders = "Data\Session01_ManipulatedData\SavedCycles_Resampled\"+currFileName;
    fprintf(1, 'Now reading %s\n', currFileName)
    resampledData = load(withFolders).tXYZ;
    
    plot(resampledData(:,2), resampledData(:,3), 'LineWidth',0.3, 'Color','#808080')

end

averageFile = "Data\Session01_ManipulatedData\SavedCycles_Resampled\Session01_Exp_F1_All_Resampled_Average.mat";
resampledAverageData = load(averageFile).tXYZ_Average;
plot(resampledAverageData(:,2), resampledAverageData(:,3), 'LineWidth',4, 'Color','k')


% get graph details
graphDetails = sprintf('60bpm_mf_44path_Normal_SplitCycles_TimeBased_Upper_Arm');

% save in GUID directory, get GUID
folderToSaveIn = 'Visualisations/Session01_Resampled_Average_Figures';   % Your destination folder
descriptionToUse = sprintf("Details: %s. Script used: %s.  Dataset used: %s. File Location: %s. Date Generated: %s", graphDetails, mfilename, currFileName, folderToSaveIn, datetime('now'));
GUIDToAppend = myGuidController.updateGuidDirectory(descriptionToUse).currGUID;

% set title
sgtitle(strrep(graphDetails, '_', ' '))

% get all open figures
figureSaveTitle = sprintf('%s_%s.fig', graphDetails, GUIDToAppend);
pngSaveTitle = sprintf('%s_%s.png', graphDetails, GUIDToAppend);


% save all figures
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
myGuidController.saveFigures(graphDetails, GUIDToAppend, FigList, folderToSaveIn);

