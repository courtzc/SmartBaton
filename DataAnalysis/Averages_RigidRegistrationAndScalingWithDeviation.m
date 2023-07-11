% initialise GUID controller
myGuidController = GUID_Controller;
close all;



expMovement = 6; % knees is 2 etc.

isSaving =1; % t/f boolean

letters = {'A', 'B', 'C', 'D', 'E', 'F'};
movements = {'No Extraneous Movement (Control)', 'Extraneous Knee Movement', 'Extraneous Waist Movement', 'Extraneous Feet Movement', 'Extraneous Wrist Movement', 'Extraneous Upper Arm Movement'};
movementsShort = {'None (Control)', 'Knees', 'Waist', 'Feet', 'Wrist', 'Upper Arm'};

positions = [
[87.75,36.75,450,500];
[537.75,36.75,450,500];
[989.25,36.75,450,500];
[87.75,36.75,450,500];
[538.5,36.75,450,500];
[989.25,36.75,450,500];
];

for j = expMovement:expMovement


    movingFile = "Data\\Session01_ManipulatedData\\"+ ...
    "SavedCycles_Resampled\\Session01_Exp_"+letters{j}+"1_All_Resampled_Average.mat";

%     movingFile = "Data\\Session01_ManipulatedData\\"+ ...
%     "SavedCycles_Resampled\\Session01_Exp_A1_005_SavedCycle_3_Resampled.mat";
    
    fixedFile = "Data\\Session01_ManipulatedData\\"+ ...
        "SavedCycles_Resampled\\Session01_Exp_A1_All_Resampled_Average.mat";
    
    
    
    % get in data
%     moving = load(movingFile).tXYZ_Average;
    moving = load(movingFile).tXYZ_Average;
    fixed = load(fixedFile).tXYZ_Average;
    
    
    moving = moving(:,2:4);
    fixed = fixed(:,2:4);
    
    % Perform rigid registration comparison on those 3D arrays
    tform = pcregistericp(pointCloud(moving),pointCloud(fixed))
    
    % Scale the 'moving' points to the size of the 'fixed' points
    scaleFactor = mean(sqrt(sum(fixed.^2,2))) / mean(sqrt(sum(moving.^2,2)));
    moving = moving * scaleFactor;
    
    % transform the 'moving' points
    movingReg = pctransform(pointCloud(moving),tform);
%     movingRegScaled = movingReg.Location * scaleFactor;
    movingRegScaled = movingReg.Location;
    % shift movingRegScaled and fixed so the array starts at the highest point:
    movingRegScaledShifted = rearrangePoints(movingRegScaled);
    translation_vector = [-0.15; 0; 0]; % Translation of 20cm lower on the Y axis
    translated_points = movingRegScaledShifted.' + translation_vector;
    movingRegScaledShifted = translated_points.';
    fixedShifted = rearrangePoints(fixed);
    
    
    % get the distances
    dists = vecnorm(fixedShifted - movingRegScaledShifted, 2, 2);
    
    numElements = numel(movingRegScaled(:,1));
    quarter = ceil(numElements/4);
    q1 = quarter;
    q2 = q1 + quarter;
    q3 = q2 + quarter;
    
    beat1 = movingRegScaledShifted(1:q1,:);
    beat2 = movingRegScaledShifted(q1:q2,:);
    beat3 = movingRegScaledShifted(q2:q3,:);
    beat4 = movingRegScaledShifted(q3:end,:);
    
    beat1dists = dists(1:q1);
    beat2dists = dists(q1:q2);
    beat3dists = dists(q2:q3);
    beat4dists = dists(q3:end);
    
    %% Plotting the point clouds
    figure('Color','white');
    set(gcf,'units','points','position',positions(j,:))

    % Define subplot positions as percentages
    pos1 = [0.1 0.37 0.8 0.4];  % [left bottom width height]
    pos2 = [0.15 0.08 0.7 0.2];
    
    % E84D8A = pink, 64C5EB = blue, 7F58AF = purple, FEB326 = orange
    beat1Colour = '#E84D8A';
    beat2Colour = '#64C5EB';
    beat3Colour = '#7F58AF';
    beat4Colour = '#FEB326';
    
    % point clouds
    subplot('Position', pos1, 'Color', 'white');
    hold on;                   % Enable overlaying plots
    axis equal
    set(gca, 'xtick', [], 'ytick', [])
    % reference
    plot3(fixed(:, 1), fixed(:, 2), fixed(:, 3),'Color', '#656565' ,'LineWidth', 2.5);
    % data
    plot3(beat1(:, 1), beat1(:, 2), beat1(:, 3),'Color', beat1Colour,'LineWidth', 2.5);
    plot3(beat2(:, 1), beat2(:, 2), beat2(:, 3),'Color', beat2Colour,'LineWidth', 2.5);
    plot3(beat3(:, 1), beat3(:, 2), beat3(:, 3),'Color', beat3Colour, 'LineWidth', 2.5);
    plot3(beat4(:, 1), beat4(:, 2), beat4(:, 3),'Color', beat4Colour,'LineWidth', 2.5);

    entry1 = sprintf("Ref. (Control) all beats");
    entry2 = sprintf("%s Beat 1", movementsShort{expMovement});
    entry3 = sprintf("%s Beat 2", movementsShort{expMovement});
    entry4 = sprintf("%s Beat 3", movementsShort{expMovement});
    entry5 = sprintf("%s Beat 4", movementsShort{expMovement});

    legend({entry1, entry2, entry3, entry4, entry5});
%     legend({'Ref. all beats', 'Exp. Beat 1', 'Exp. Beat 2', 'Exp. Beat 3', 'Exp. Beat 4'});
    hold off;
%     title(titleName)
    
    % distances
    subplot('Position', pos2);
    hold on;
    plot((1:q1), beat1dists, 'Color',beat1Colour, 'LineWidth', 2.5)
    plot((q1:q2), beat2dists, 'Color',beat2Colour, 'LineWidth', 2.5)
    plot((q2:q3), beat3dists, 'Color',beat3Colour, 'LineWidth', 2.5)
    plot((q3:numElements), beat4dists, 'Color',beat4Colour, 'LineWidth', 2.5)
    
    ylimMax = 0.4;
    ylim([0,ylimMax]);
    yticks([(ylimMax*0.17),(ylimMax*0.5),(ylimMax*0.85)])
%     title("Deviation")
    yticklabels(["Good", "Medium", "Bad"]);
    tick1 = 0 + ceil(quarter/2);
    tick2 = q1 + ceil(quarter/2);
    tick3 = q2 + ceil(quarter/2);
    tick4 = q3 + ceil(quarter/2);
    xticks([tick1,tick2,tick3,tick4]);
%     xticks([q1,q2,q3]);
%     XAxis.TickLength = [0 0];
    xticklabels(["Beat 1", "Beat 2", "Beat 3", "Beat 4"])
%     label_2 = ylabel("Deviation");
    
    % Set the background color of the thirds
    ax = gca;  % Get current axes handle
    ylim_vals = get(ax, 'YLim');  % Get y-axis limits
    ax.XAxis.TickLength = [0 0];
    ax.YAxis.TickLength = [0 0];
%     label_2.Position(1) = label_2.Position(1) - 40;
    ytick = get(ax, 'YTick');  % Get y-axis tick locations
    yticklabels2 = get(ax, 'YTickLabel');
    set(ax, 'YTickLabel', yticklabels2, 'FontSize', 12)
    % Define the ranges for the colored areas
    top_third = [ylim_vals(2) * (2/3), ylim_vals(2)];  % Red area
    middle_third = [ylim_vals(2)/3, ylim_vals(2) * (2/3)];  % Yellow area
    bottom_third = [ylim_vals(1), ylim_vals(2)/3];  % Green area
    
    % Create patch objects with respective colors
    patch([xlim fliplr(xlim)], [top_third(1) top_third(1) top_third(2) top_third(2)], [0.7255 0.0549 0.0392], 'EdgeColor', 'none', 'FaceAlpha', 0.05);
    patch([xlim fliplr(xlim)], [middle_third(1) middle_third(1) middle_third(2) middle_third(2)], [0.9882 0.8196 0.1647], 'EdgeColor', 'none', 'FaceAlpha', 0.05);
    patch([xlim fliplr(xlim)], [bottom_third(1) bottom_third(1) bottom_third(2) bottom_third(2)], [0.4549 0.7176 0.1804], 'EdgeColor', 'none', 'FaceAlpha', 0.1);
    
    % Set the y-axis ticks to their original values
    set(ax, 'YTick', ytick);
    movingFile = strtrim(movingFile);  
    movingFileLength = strlength(movingFile);
    startIndex = movingFileLength - 46;
    
    movingFileShort = extractAfter(movingFile, strlength(movingFile) - 47);
    movingFileShort = extractBefore(movingFileShort, strlength(movingFileShort) - 13);
    movingFileShort = strrep(movingFileShort, '_', ' ');
    % movingFileShort = movingFile(end-46:end);

    % set title
%         titleName = sprintf(". \nKnees against %s", movements{j});
    

%     niceTitle{1} = {sprintf("Registration and Deviation")};
%     niceTitle{1} = {sprintf("Random experimental bar, 'No Extraneous Movement'")};
    niceTitle{1} = {sprintf("'%s' average trajectory", movements{expMovement})};
    niceTitle{2} = {sprintf("Against 'No Extraneous Movement (Control)' average trajectory")};
%     niceTitle{3} = {sprintf("Average extraneous movement: %s", movementsShort{expMovement})};
%     niceTitle{4} = {sprintf("Reference average extraneous movement: %s", movementsShort{j})};

    % overall title
    axes('Position', [0, 0.87, 1, 0.13] ) ;
    set( gca, 'Color', 'None', 'XColor', 'White', 'YColor', 'White' ) ;
    text( 0.5, 0.65, niceTitle{1}, 'FontName', 'Arial', 'FontSize', 17', 'FontWeight', 'bold', ...
      'HorizontalAlignment', 'Center', 'VerticalAlignment', 'middle' ) ;
    text( 0.5, 0.2, niceTitle{2}, 'FontName', 'Arial', 'FontSize', 15', 'FontWeight', 'normal', ...
      'HorizontalAlignment', 'Center', 'VerticalAlignment', 'middle' ) ;
%     text( 0.5, 0.17, niceTitle{3}, 'FontName', 'Arial', 'FontSize', 10', 'FontWeight', 'normal', ...
%       'HorizontalAlignment', 'Center', 'VerticalAlignment', 'middle' ) ;
%     text( 0.5, 0.02, niceTitle{4}, 'FontName', 'Arial', 'FontSize', 10', 'FontWeight', 'normal', ...
%       'HorizontalAlignment', 'Center', 'VerticalAlignment', 'middle' ) ;

    % regstration title
    axes('Position', [0, 0.76, 1, 0.1] ) ;
    set( gca, 'Color', 'None', 'XColor', 'None', 'YColor', 'None','Box', 'off' ) ;
    text( 0.5, 0.6, "Registration", 'FontName', 'Arial', 'FontSize', 14', 'FontWeight', 'bold', ...
      'HorizontalAlignment', 'Center', 'VerticalAlignment', 'middle' ) ; 
    
    % deviation title
    axes('Position', [0, 0.25, 1, 0.1] ) ;
    set( gca, 'Color', 'None', 'XColor', 'None', 'YColor', 'None','Box', 'off' ) ;
    text( 0.5, 0.6, "Deviation", 'FontName', 'Arial', 'FontSize', 14', 'FontWeight', 'bold', ...
      'HorizontalAlignment', 'Center', 'VerticalAlignment', 'middle' ) ;
    
    
  
end

% get graph details
graphDetails = sprintf("Rigid Registration Scaling and Deviation %s against Control", movements{expMovement});
dataset = sprintf("reference: Session01_ManipulatedData/SavedCycles_Resampled/Session01_ExpA1_All_Resampled_Average. data: Session01_ManipulatedData/SavedCycles_Resampled/%s", movingFileShort);
folderToSaveIn = 'Visualisations/RegistrationAnalysis';   % Your destination folder



if (isSaving)
    % add to GUID directory
    descriptionToUse = sprintf("Details: %s. Script used: %s.  Dataset used: %s. File Location: %s. Date Generated: %s", graphDetails, mfilename, dataset, folderToSaveIn, datetime('now'));
    descriptionToUse = sprintf("Details: %s. Script used: Averages_RigidRegistrationAndScalingWithDeviation.  Dataset used: %s. File Location: %s. Date Generated: %s", graphDetails, dataset, folderToSaveIn, datetime('now'));
%     GUIDToAppend = myGuidController.updateGuidDirectory(descriptionToUse).currGUID;
    % save all figures
    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
    for k = 1:length(FigList)
            GUIDToAppend = myGuidController.updateGuidDirectory(descriptionToUse).currGUID;
        myGuidController.saveFigures(graphDetails, GUIDToAppend, FigList(k), folderToSaveIn);
    end
end

function rearrangedArray = rearrangePoints(points)
    % Find the highest XY point
    [~, maxIdx] = max(points(:,2));
    fprintf("highest point for moving %f",maxIdx)
    
    % Rearrange the array
    rearrangedArray = circshift(points, [-maxIdx, 0]);
end