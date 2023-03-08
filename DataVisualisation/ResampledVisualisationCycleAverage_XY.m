% initialise GUID controller
myGuidController = GUID_Controller;

close all
miniPattern = "C:\Users\Courtney\source\repos\ThesisProject\" + ...
    "Data\Session01_ManipulatedData\SavedCycles_Resampled\Session01_ExpA1_All*.mat";
    
% collect the files
theFiles = dir(miniPattern);

% initialise 
figureSaveTitles = cell(1,length(theFiles));
    






for k = 1:length(theFiles)

    % get the file name + read in the file
    simpleFileName = theFiles(k).name;
    fullFileName = fullfile(theFiles(k).folder, simpleFileName);
    
%     fprintf(1, 'Now reading %s\n', simpleFileName);
    withFolders = "Data\Session01_ManipulatedData\SavedCycles_Resampled\"+simpleFileName;
    fprintf('Now reading %s\n', withFolders)
    clear tXYZ;
    tXYZ = load(withFolders).tXYZ_Average;


   
   

    %% plot!
    figure
    hold on;
    title(strrep(simpleFileName, '_', ' '));
    
    axis equal
    set(gca, 'Visible', 'off')
    plot(tXYZ(:,2), tXYZ(:,3), 'LineWidth',8, 'Color','k')


    % get graph details
    graphDetails = sprintf('60bpm_mf_44path_Normal_SplitCycles_TimeBased_%s',  simpleFileName);
    
    % save in GUID directory, get GUID
    folderToSaveIn = 'Visualisations/Session01_Resampled_Average_Figures';   % Your destination folder
    descriptionToUse = sprintf("Details: %s. Script used: %s.  Dataset used: %s. File Location: %s. Date Generated: %s", graphDetails, mfilename, fullFileName, folderToSaveIn, datetime('now'));
    GUIDToAppend = myGuidController.updateGuidDirectory(descriptionToUse).currGUID;
    
    % add GUID to title 
    figureSaveTitles{k} = sprintf('%s_%s.fig', graphDetails, GUIDToAppend);
    pngSaveTitle{k} = sprintf('%s_%s.png', graphDetails, GUIDToAppend);

end

% get all open figures
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');


% save all open figures
for iFig = 1:length(FigList)
  FigHandle = FigList(iFig);
  FigName   = figureSaveTitles{iFig};
  PngName   = pngSaveTitle{iFig};
  fprintf("now saving: %s\n", FigName)
  saveas(FigHandle, fullfile(folderToSaveIn, FigName));
  saveas(FigHandle, fullfile(folderToSaveIn, PngName));
end




