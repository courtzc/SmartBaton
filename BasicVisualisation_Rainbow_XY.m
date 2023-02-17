% Visualisation Basic Centroid

%% input - uncomment relevant pattern

% all
% filePattern = fullfile("Experiment_SimpleCentroidTrackingData/", '*_SimpleCentroid.csv'); % Change to whatever pattern you need.

% one conducting movement
filePattern = fullfile("Experiment_SimpleCentroidTrackingData/", '*Session01_Exp_*1_*_GHI_BlanksRemoved_SimpleCentroid.csv'); % Change to whatever pattern you need.

% one habit
% filePattern = fullfile("Experiment_SimpleCentroidTrackingData/", '*Session01_Exp_A*_GHI_BlanksRemoved_SimpleCentroid.csv'); % Change to whatever pattern you need.

%% input - uncomment relevant view

% front view (X and Y)
viewPoint = [0, 90];

% side view (Y and Z)
% viewPoint = [90, 0];


%% calculation
% collect the files
theFiles = dir(filePattern);

% set up the colour (this will change when heatmap is used)
colourMap = jet(501);

habits = ["Textbook", "Knee movement", "Waist movement", "Feet movement", "Wrist movement", "Upper arm movement"];
features = ["Normal", "Accelerando", "Ritardando", "Lead in", "Cut off", "Crescendo", "Diminuendo", "Marcato", "Legato"];
figure;



for k = 1:length(theFiles)

    % get the file name
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(theFiles(k).folder, baseFileName);
    relativeFileName = "Experiment_SimpleCentroidTrackingData\" + baseFileName;
    titleName = "Habit: " + habits(k);


    % read in the file
    fprintf(1, 'Now reading %s\n', baseFileName);
    PosData = readmatrix(relativeFileName);
    
    
    % plot!
    subplot(2,3,k)
    hold on
    xlim([-1.2,0])
    ylim([0.8,2.2])
    title (titleName)
    view (viewPoint(1),viewPoint(2))
    
    for i = 1:length(PosData(:,1))-1
       j = mod(i,500) + 1;
       plot3(PosData((i:i+1),1), PosData((i:i+1),2), PosData((i:i+1),3), 'color', colourMap(j,:))
    end
    
    
end

sgtitle('Overall Title')
hold off