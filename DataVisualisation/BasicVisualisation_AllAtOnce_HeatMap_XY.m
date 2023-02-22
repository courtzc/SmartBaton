%% Visualisation Basic Centroid
% clear workspace and close all figures (so that the fig list works)
clear
close all

%% saving setup
% set up GUID controller for unique graph names
myGuidController = GUID_Controller;

% initialise 
figureSaveTitles = cell(1,6);

%% colour setup
% set up the colour range
colormap(jet(501));
colourMap = jet(501);

% set up the distance thresholds for speed heat
minDistance = 0.00004;
maxDistance = 0.05;


%% feature setup
% uncomment relevant view
viewPoint = [0, 90]; % front view (X and Y)
% viewPoint = [90, 0]; % side view (Y and Z)

% set up the feature and habit names
features = ["Normal", "Accelerando", "Ritardando", "Lead in", "Cut off", "Crescendo", "Diminuendo", "Marcato", "Legato"];
habits = ["Textbook", "Knee movement", "Waist movement", "Feet movement", "Wrist movement", "Upper arm movement"];


% change j range for which features should exist
for j = 1:6    

    % Get all files of the jth feature
    miniPattern = "C:\Users\Courtney\source\repos\ThesisProject\" + ...
        "Data\Session01_SimpleCentroidTrackingData\" + ...
        "Session01_Exp_*" + j + "_*_GHI_BlanksRemoved_SimpleCentroid.csv";
    
    % collect the files
    theFiles = dir(miniPattern);
    
    figure;

    for k = 1:length(theFiles)
    
        % get the file name + read in the file
        simpleFileName = theFiles(k).name;
        fullFileName = fullfile(theFiles(k).folder, simpleFileName);

        fprintf(1, 'Now reading %s\n', simpleFileName);
        PosData = readmatrix(fullFileName);
        
        % set up subplot
        subplot(2,3,k)
        hold on
        xlim([-1.6,0.7])
        ylim([0.3,2.7])
        title (habits(k))
        colorbar
        c.Ticks = [0 0.5 1];
        c.TickLabels = {'Slow','Medium','Fast'};
        view (viewPoint(1),viewPoint(2))
        
        % plot data
        for i = 1:length(PosData(:,1))-1

           % get distance travelled for heatmap
            pointDistance = norm(PosData(i,:) - PosData(i+1,:));

           % calculate distance 
           if pointDistance > maxDistance
                % disp("probably a glitch/missing data")
           elseif pointDistance < minDistance
               pointColour = 1;
           else
               range = maxDistance - minDistance;
               pointColour = ((pointDistance - minDistance) / range) * 500;
               pointColour = ceil(pointColour);
           end

           plot3(PosData((i:i+1),1), PosData((i:i+1),2), PosData((i:i+1),3), 'color', colourMap(pointColour,:))

        end
    
    end

    % get graph details
    graphDetails = sprintf('60bpm_mf_44path_%s_AllHabits',  features(j));
    
    % save in GUID directory, get GUID
    folderToSaveIn = 'Visualisations/Session01_SimpleCentroid_Figures';   % Your destination folder
    descriptionToUse = sprintf("Details: %s. Script used: %s.  Dataset used: %s. File Location: %s. Date Generated: %s", graphDetails, mfilename, fullFileName, folderToSaveIn, datetime('now'));
    GUIDToAppend = myGuidController.updateGuidDirectory(descriptionToUse).currGUID;
    
    % add GUID to title 
    figureSaveTitles{j} = sprintf('%s_%s.png', graphDetails, GUIDToAppend);

    % set title
    sgtitle(strrep(graphDetails, '_', ' '))

    hold off
end

% get all open figures
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');

% save all open figures
for iFig = 1:length(FigList)
  FigHandle = FigList(iFig);
  FigName   = figureSaveTitles{iFig};
  fprintf("now saving: %s\n", FigName)
  saveas(FigHandle, fullfile(folderToSaveIn, FigName));
end