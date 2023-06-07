figure('Color','white');
set(gcf,'units','points','position',[100, 100, 800, 600]) % Adjust figure size if needed

% Define subplot positions as percentages
pos = zeros(6, 4);
pos(:, 1) = repmat([0.05 0.375 0.70], 1, 2);
pos(:, 2) = repelem([0.62 0.28], 1, 3);
pos(:, 3) = 0.27;
pos(:, 4) = repmat([0.64 0.32], 1, 3);

topSubplots = [1,2,3,7,8,9];
bottomSubplots = [4,5,6,10,11,12];

% E84D8A = pink, 64C5EB = blue, 7F58AF = purple, FEB326 = orange
beat1Colour = '#E84D8A';
beat2Colour = '#64C5EB';
beat3Colour = '#7F58AF';
beat4Colour = '#FEB326';

for i = 1:6
   
    % point clouds
    subplot(4, 3, topSubplots(i));
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
    legend({'Reference', 'Beat 1', 'Beat 2', 'Beat 3', 'Beat 4'});
    hold off;
    
    % distances
    subplot(4, 3, bottomSubplots(i));
    hold on;
    plot((1:q1), beat1dists, 'Color',beat1Colour, 'LineWidth', 2.5)
    plot((q1:q2), beat2dists, 'Color',beat2Colour, 'LineWidth', 2.5)
    plot((q2:q3), beat3dists, 'Color',beat3Colour, 'LineWidth', 2.5)
    plot((q3:numElements), beat4dists, 'Color',beat4Colour, 'LineWidth', 2.5)
    ylim([0,0.6]);
    ylabel("Deviation")
    
    % Set the background color of the thirds
    ax = gca;  % Get current axes handle
    ylim_vals = get(ax, 'YLim');  % Get y-axis limits
    ytick = get(ax, 'YTick');  % Get y-axis tick locations
    
    % Define the ranges for the colored areas
    top_third = [ylim_vals(2) * (2/3), ylim_vals(2)];  % Red area
    middle_third = [ylim_vals(2)/3, ylim_vals(2) * (2/3)];  % Yellow area
    bottom_third = [ylim_vals(1), ylim_vals(2)/3];  % Green area
    
    % Create patch objects with respective colors
    patch([xlim fliplr(xlim)], [top_third(1) top_third(1) top_third(2) top_third(2)], [0.7255 0.0549 0.0392], 'EdgeColor', 'none', 'FaceAlpha', 0.05);
    patch([xlim fliplr(xlim)], [middle_third(1) middle_third(1) middle_third(2) middle_third(2)], [0.9882 0.8196 0.1647], 'EdgeColor', 'none', 'FaceAlpha', 0.05);
    patch([xlim fliplr(xlim)], [bottom_third(1) bottom_third(1) bottom_third(2) bottom_third(2)], [0.4549 0.7176 0.1804], 'EdgeColor', 'none', 'FaceAlpha', 0.05);
    
    % Set the y-axis ticks to their original values
    set(ax, 'YTick', ytick);
end

sgtitle("Nested Subplots Example");
