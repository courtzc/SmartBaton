% initialise GUID controller
myGuidController = GUID_Controller;
close all;



expMovement = 5; % knees is 2 etc.
plottingWithLegend = 1;
isSaving = 0; % t/f boolean

letters = {'A', 'B', 'C', 'D', 'E', 'F'};
movements = {'No Extraneous Movement (Control)', 'Extraneous Knee Movement', 'Extraneous Waist Movement', 'Extraneous Feet Movement', 'Extraneous Wrist Movement', 'Extraneous Upper Arm Movement'};
movementsShort = {'None (Control)', 'Knees', 'Waist', 'Feet', 'Wrist', 'Upper Arm'};

positions = [
[87.75,36.75,630,700];
[537.75,36.75,450,500];
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

    ylimMaxs = [0.4, 0.35, 0.4, 0.35, 0.35, 0.4];
    translation_vectors = [[0 0 0];  % Control
                           [0 0 0];   % Knees
                           [0 0 0];  % Waist
                           [0 0 0];   % Feet
                           [0 0 0];   % Wrist
                           [-0.15 0 0]]; % Upper Arm

    disp(translation_vectors(expMovement,:))
    translated_points = movingRegScaledShifted.' + translation_vectors(expMovement, :)';
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
    set(gcf,'units','points','position',positions(1,:))

    % Define subplot positions as percentages
    pos1 = [0.1 0.37 0.8 0.4];  % [left bottom width height]
    pos2 = [0.15 0.08 0.7 0.2];
    
    % E84D8A = pink, 64C5EB = blue, 7F58AF = purple, FEB326 = orange
    beat1Colour = '#E84D8A';
    beat2Colour = '#64C5EB';
    beat3Colour = '#7F58AF';
    beat4Colour = '#FEB326';
    
    % point clouds
    plotUpper = subplot('Position', pos1, 'Color', 'white');
    pointsUpper = cell(1,4);
    hold on;                   % Enable overlaying plots
    axis equal
    set(gca, 'xtick', [], 'ytick', [])
%     set(gca,'XDir','reverse')
    % reference
    plot3(fixed(:, 1), fixed(:, 2), fixed(:, 3),'Color', '#656565' ,'LineWidth', 2.5);
    % data
    pointsUpper{1} = plot3(plotUpper, NaN, NaN, NaN, 'Color', beat1Colour, 'LineWidth', 2.5);
    pointsUpper{2} = plot3(plotUpper, NaN, NaN, NaN, 'Color', beat2Colour, 'LineWidth', 2.5);
    pointsUpper{3} = plot3(plotUpper, NaN, NaN, NaN, 'Color', beat3Colour, 'LineWidth', 2.5);
    pointsUpper{4} = plot3(plotUpper, NaN, NaN, NaN, 'Color', beat4Colour, 'LineWidth', 2.5);
    setappdata(gca,'LegendColorbarManualSpace',1);
    setappdata(gca,'LegendColorbarReclaimSpace',1);
    entry1 = sprintf("Ref. (Control) all beats");
    entry2 = sprintf("%s Beat 1", movementsShort{expMovement});
    entry3 = sprintf("%s Beat 2", movementsShort{expMovement});
    entry4 = sprintf("%s Beat 3", movementsShort{expMovement});
    entry5 = sprintf("%s Beat 4", movementsShort{expMovement});

    
%     legend({'Ref. all beats', 'Exp. Beat 1', 'Exp. Beat 2', 'Exp. Beat 3', 'Exp. Beat 4'});
    hold off;
%     title(titleName)
    %% set up distances subplot
    % distances
    plotLower = subplot('Position', pos2);
    pointsLower = cell(1,4);
    
    hold on;


    
    ylimMax = ylimMaxs(expMovement);
    ylim([0,ylimMax]);
    yticks([(ylimMax*0.17),(ylimMax*0.5),(ylimMax*0.85)])

    yticklabels(["Good", "Medium", "Bad"]);
    tick1 = 0 + ceil(quarter/2);
    tick2 = q1 + ceil(quarter/2);
    tick3 = q2 + ceil(quarter/2);
    tick4 = q3 + ceil(quarter/2);
    xticks([tick1,tick2,tick3,tick4]);
    xticklabels(["Beat 1", "Beat 2", "Beat 3", "Beat 4"])
    
    % Set the background color of the thirds
    ax = gca;  % Get current axes handle
    ylim_vals = get(ax, 'YLim');  % Get y-axis limits
    ax.XAxis.TickLength = [0 0];
    ax.YAxis.TickLength = [0 0];

    ytick = get(ax, 'YTick');  % Get y-axis tick locations
    yticklabels2 = get(ax, 'YTickLabel');
    set(ax, 'YTickLabel', yticklabels2, 'FontSize', 16)

    % Set the y-axis ticks to their original values
    set(ax, 'YTick', ytick);
    movingFile = strtrim(movingFile);  
    movingFileLength = strlength(movingFile);
    startIndex = movingFileLength - 46;

    % Define the ranges for the colored areas
    all_x = [0,numElements,numElements,0];  % Red area
    top_third_y = [ylim_vals(2) * (2/3), ylim_vals(2) * (2/3), ylim_vals(2), ylim_vals(2)];  % Red area
    middle_third_y = [ylim_vals(2)/3, ylim_vals(2)/3, ylim_vals(2) * (2/3), ylim_vals(2) * (2/3)];  % Yellow area
    bottom_third_y = [ylim_vals(1), ylim_vals(1), ylim_vals(2)/3, ylim_vals(2)/3];  % Green area

    fill(all_x, top_third_y, [0.7255 0.0549 0.0392], 'EdgeColor', 'none', 'FaceAlpha', 0.1);
    fill(all_x, middle_third_y, [0.9882 0.8196 0.1647], 'EdgeColor', 'none', 'FaceAlpha', 0.15);
    fill(all_x, bottom_third_y, [0.4549 0.7176 0.1804], 'EdgeColor', 'none', 'FaceAlpha', 0.2);

    % define the devation data plots
    pointsLower{1} = plot(plotLower, NaN, NaN, 'color', beat1Colour, 'LineWidth', 2.5);
    pointsLower{2} = plot(plotLower, NaN, NaN, 'color', beat2Colour, 'LineWidth', 2.5);
    pointsLower{3} = plot(plotLower, NaN, NaN, 'color', beat3Colour, 'LineWidth', 2.5);
    pointsLower{4} = plot(plotLower, NaN, NaN, 'color', beat4Colour, 'LineWidth', 2.5);

    % define the title
    niceTitle{1} = {sprintf("'%s' average trajectory", movements{expMovement})};
    niceTitle{2} = {sprintf("Against 'No Extraneous Movement (Control)' average trajectory")};

    % plot the overall title
    axes('Position', [0, 0.87, 1, 0.13] ) ;
    set( gca, 'Color', 'None', 'XColor', 'White', 'YColor', 'White' ) ;
    text( 0.5, 0.65, niceTitle{1}, 'FontName', 'Arial', 'FontSize', 24', 'FontWeight', 'bold', ...
      'HorizontalAlignment', 'Center', 'VerticalAlignment', 'middle' ) ;
    text( 0.5, 0.2, niceTitle{2}, 'FontName', 'Arial', 'FontSize', 18', 'FontWeight', 'normal', ...
      'HorizontalAlignment', 'Center', 'VerticalAlignment', 'middle' ) ;

    % regstration title
    axes('Position', [0, 0.76, 1, 0.1] ) ;
    set( gca, 'Color', 'None', 'XColor', 'None', 'YColor', 'None','Box', 'off' ) ;
    text( 0.5, 0.6, "Registration", 'FontName', 'Arial', 'FontSize', 18', 'FontWeight', 'bold', ...
      'HorizontalAlignment', 'Center', 'VerticalAlignment', 'middle' ) ; 
    
    % deviation title
    axes('Position', [0, 0.25, 1, 0.1] ) ;
    set( gca, 'Color', 'None', 'XColor', 'None', 'YColor', 'None','Box', 'off' ) ;
    text( 0.5, 0.6, "Deviation", 'FontName', 'Arial', 'FontSize', 18', 'FontWeight', 'bold', ...
      'HorizontalAlignment', 'Center', 'VerticalAlignment', 'middle' ) ;

    for k = 1:numElements
        
        if (k < q1)
            if (k == 1 && plottingWithLegend)
                legend(plotUpper, {entry1, entry2}, 'Position', [0.75 0.75 0.16 0.06], 'FontName', 'Arial', 'FontSize', 14);
            end
            set(pointsLower{1}, 'XData', (1:k), 'YData', beat1dists(1:k));
            set(pointsUpper{1}, 'XData', beat1(1:k, 1), 'YData', beat1(1:k, 2), 'ZData', beat1(1:k, 3));
        elseif (k < q2)
            if (k == q1 && plottingWithLegend)
                legend(plotUpper, {entry1, entry2, entry3}, 'Position', [0.75 0.72 0.16 0.09]);
            end
            set(pointsLower{2}, 'XData', (q1:k), 'YData', beat2dists(1:(k-q1+1)));
            set(pointsUpper{2}, 'XData', beat2(1:(k-q1+1), 1), 'YData', beat2(1:(k-q1+1), 2), 'ZData', beat2(1:(k-q1+1), 3));
        elseif (k < q3)
            if (k == q2 && plottingWithLegend)
                legend(plotUpper, {entry1, entry2, entry3, entry4}, 'Position', [0.75 0.69 0.16 0.12]);
            end
            set(pointsLower{3}, 'XData', (q2:k), 'YData', beat3dists(1:(k-q2+1)));
            set(pointsUpper{3}, 'XData', beat3(1:(k-q2+1), 1), 'YData', beat3(1:(k-q2+1), 2), 'ZData', beat3(1:(k-q2+1), 3));
        else
            if (k == q3 && plottingWithLegend)
                legend(plotUpper, {entry1, entry2, entry3, entry4, entry5}, 'Position', [0.75 0.66 0.16 0.15]);
            end
            set(pointsLower{4}, 'XData', (q3:k), 'YData', beat4dists(1:(k-q3+1)));
            set(pointsUpper{4}, 'XData', beat4(1:(k-q3+1), 1), 'YData', beat4(1:(k-q3+1), 2), 'ZData', beat4(1:(k-q3+1), 3));
        end
        drawnow
    end


  
end
    % add legend
    
% get graph details
graphDetails = sprintf("Rigid Registration Scaling and Deviation %s against Control", movements{expMovement});
dataset = sprintf("reference: Session01_ManipulatedData/SavedCycles_Resampled/Session01_ExpA1_All_Resampled_Average. data: %s", movingFile);
folderToSaveIn = 'Visualisations/RegistrationAnalysis';   % Your destination folder



if (isSaving)
    % add to GUID directory
%     descriptionToUse = sprintf("Details: %s. Script used: %s.  Dataset used: %s. File Location: %s. Date Generated: %s", graphDetails, mfilename, dataset, folderToSaveIn, datetime('now'));
    descriptionToUse = sprintf("Details: %s. Script used: Presentation_Registration. Dataset used: %s. File Location: %s. Date Generated: %s", graphDetails, dataset, folderToSaveIn, datetime('now'));
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
%     fprintf("highest point for moving %f",maxIdx)
    
    % Rearrange the array
    rearrangedArray = circshift(points, [-maxIdx, 0]);
end