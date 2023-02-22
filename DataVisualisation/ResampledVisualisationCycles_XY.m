close all;

myGuidController = GUID_Controller;

theFiles = [];
for j = 4:6
    miniPattern = "C:\Users\Courtney\source\repos\ThesisProject\" + ...
        "Data\Session01_ManipulatedData\SavedCycles_Resampled\" + ...
        "Session01_*_00"+j+"_SavedCycle_*.mat";
    
    % collect the files
    theFiles = [theFiles; dir(miniPattern)];
    
end

figure;
hold on;
title("")

% do for every file in the files
for k = 1:length(theFiles)

    currFileName = theFiles(k).name;
    withFolders = "Data\Session01_ManipulatedData\SavedCycles_Resampled\"+currFileName;
    fprintf(1, 'Now reading %s\n', currFileName)
    resampledData = load(withFolders).tXYZ;
    
    plot(resampledData(:,2), resampledData(:,3), 'LineWidth',0.2, 'Color','#808080')

end



% get all open figures
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');

% save all open figures
for iFig = 1:length(FigList)
  FigHandle = FigList(iFig);
  FigName   = figureSaveTitle;
  fprintf("now saving: %s\n", FigName)
  saveas(FigHandle, fullfile(folderToSaveIn, FigName));
end
