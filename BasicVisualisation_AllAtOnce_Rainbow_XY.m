% Visualisation Basic Centroid
%% input - uncomment relevant view

% front view (X and Y)
viewPoint = [0, 90];

% side view (Y and Z)
% viewPoint = [90, 0];

%% calculation
% this has been calculated from trial and error, and DistanceChecking.m

% set up the feature and habit names
features = ["Normal", "Accelerando", "Ritardando", "Lead in", "Cut off", "Crescendo", "Diminuendo", "Marcato", "Legato"];
habits = ["Textbook", "Knee movement", "Waist movement", "Feet movement", "Wrist movement", "Upper arm movement"];

% set up the colour range
colormap = jet(501);
% disp(colourMap(1,:))
% colormap([colourMap(1,:); colourMap(end,:)]/255);


% set up the distance thresholds
minDistance = 0.00004;
maxDistance = 0.05;

% get time stamp for saving figures
% figureTimeTemp = datetime('now','Format','DD-MM-yy_HH-MM-SS');

% change j for which features features should exist
for j = 1:1

    figureTime = sprintf("Feature-%s-Habit-all",features(j));
    figureSaveTitles = strings(length(features));

    % one conducting movement
    miniPattern = "*Session01_Exp_*" + j + "_*_GHI_BlanksRemoved_SimpleCentroid.csv";
    filePattern = fullfile("Experiment_SimpleCentroidTrackingData/", miniPattern);
    
    % collect the files
    theFiles = dir(filePattern);
    

    
    figure;

    for k = 1:length(theFiles)
    
        % get the file name
        baseFileName = theFiles(k).name;
        fullFileName = fullfile(theFiles(k).folder, baseFileName);
        relativeFileName = "Experiment_SimpleCentroidTrackingData\" + baseFileName;
    
        % read in the file
        fprintf(1, 'Now reading %s\n', baseFileName);
        PosData = readmatrix(relativeFileName);
        
        % plot!
        subplot(2,3,k)
        hold on
        xlim([-1.2,0])
        ylim([0.8,2.2])
        title (habits(k))
        c=colorbar;
        c.Ticks = [0 0.5 1];
        c.TickLabels = {'Slow','Medium','Fast'};
        view (viewPoint(1),viewPoint(2))
        
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
    
    
    titleName = sprintf('60bpm, mf, 4/4 path.',  features(j));
    figureSaveTitles(j) = titleName;
    sgtitle(titleName)
    hold off

end

FolderName = "Experiment_SimpleCentroid_Figures";   % Your destination folder
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for iFig = 1:length(FigList)
  FigHandle = FigList(iFig);
  FigName   = figureSaveTitles(iFig);
  saveas(FigHandle, fullfile(FolderName, FigName, '.png'));
end