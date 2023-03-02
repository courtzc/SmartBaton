## Data Viz GUID System
For everything that's making a visualisation: 

1. Add this to the top of the file:
```
close all;
myGuidController = GUID_Controller;
```

2. Add this to the loop of plot generation:
```
% set graph details
graphDetails = sprintf('your_stuff_here_%s',  changingfeatureinloop(j));

% save in GUID directory, get GUID
folderToSaveIn = 'Visualisations/Session01_SimpleCentroid_Figures';   % Your destination folder
descriptionToUse = sprintf("Details: %s. Script used: %s.  Dataset used: %s. File Location: %s. Date Generated: %s", graphDetails, mfilename, fullFileName, folderToSaveIn, datetime('now'));
GUIDToAppend = myGuidController.updateGuidDirectory(descriptionToUse).currGUID;

% add GUID to title 
figureSaveTitles{j} = sprintf('%s_%s.fig', strrep(graphDetails, ' ', '_'), GUIDToAppend);
pngSaveTitles{j} = sprintf('%s_%s.png', strrep(graphDetails, ' ', '_'), GUIDToAppend);
```

3. Add this to after you've generated the plots/end of file
```
% get all open figures
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');

% save all open figures
for iFig = 1:length(FigList)
  FigHandle = FigList(iFig);
  FigName   = figureSaveTitles{iFig};
  pngName   = pngSaveTitles{iFig};
  fprintf("now saving: %s\n", FigName)
  saveas(FigHandle, fullfile(folderToSaveIn, FigName));
  saveas(FigHandle, fullfile(folderToSaveIn, pngName));
end
```