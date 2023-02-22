
% read in the file
% fprintf(1, 'Now reading %s\n', baseFileName);
PosData = readmatrix("Experiment_SimpleCentroidTrackingData\Session01_Exp_A1_004_GHI_BlanksRemoved_SimpleCentroid.csv");
lenData = length(PosData);
PosData = PosData(80:lenData, :);

% plot!

figure
sgtitle("Normal path")

endOfCycle = false;

colour = {'red', '#FFCC00', '#FFA500', 'blue', 'green', 'black', 'cyan', 'magenta'};
index = 1;
bufferPoints = 0;

% at downbeat
% endLimits = [[-0.49, -0.41]; [1.1, 1.27]; [0.44, 0.63]];

% at top of upbeat
% endLimits = [[-0.6, -0.45]; [1.93, 2.1]; [0.75, 0.8]];
endLimit = [-0.53; 1.99; 0.78];

for i = 1:8

    % start new plot
    subplot(2,4,i)
    beginTitle = sprintf("start: [%f, %f, %f]\n", PosData(index,1), PosData(index,2), PosData(index,3));
    hold on
    view (0,90)
   
    % plot this cycle of the path
    while (~endOfCycle) 
        
        % plot this point set
        plot3(PosData(index:index+1,1), PosData(index:index+1,2), PosData(index:index+1,3), 'color', colour{i})
        index = index + 1;
        bufferPoints = bufferPoints + 1;

        % check if at the end of the cycle
        if (bufferPoints > 200)
            endOfCycle = checkEndOfCycle(PosData(index,:), endLimit);
        end
    end

    % set this point as the point to get to for the end of next cycle
    endLimit = PosData(index,:);


    % title
    endTitle = sprintf("end: [%f, %f, %f]", PosData(index,1), PosData(index,2), PosData(index,3));

    whoelTitle = beginTitle + endTitle
    title(whoelTitle)

    % move on to the new cycle
    endOfCycle = false;

    
    % go through at least 50 points before checking again
    bufferPoints = 0;

end



function [isEnd] = checkEndOfCycle(point, endLimit) 

    isEnd = false;
    tolerance = [0.2, 0.02, 0.1];

    if (abs(point(1)-endLimit(1)) < tolerance(1)) && (abs(point(2)-endLimit(2)) < tolerance(2)) && (abs(point(3)-endLimit(3)) < tolerance(3))
        isEnd = true;
    end

end


