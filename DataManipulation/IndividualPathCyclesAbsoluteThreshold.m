
% read in the file
% fprintf(1, 'Now reading %s\n', baseFileName);
PosData = readmatrix("Experiment_SimpleCentroidTrackingData\Session01_Exp_A1_004_GHI_BlanksRemoved_SimpleCentroid.csv");
lenData = length(PosData);
PosData = PosData(80:lenData, :);

% plot!

figure
sgtitle("Normal path, absolute threshold")

endOfCycle = false;

colour = {'red', '#FFCC00', '#FFA500', 'blue', 'green', 'black', 'cyan', 'magenta', 'yellow', 'black', 'black'};
index = 1;
bufferPoints = 0;

% at downbeat
% endLimits = [[-0.49, -0.41]; [1.1, 1.27]; [0.44, 0.63]];

% at top of upbeat
endLimits = [[-0.6, -0.45]; [1.93, 2.1]; [0.75, 0.8]];


for i = 1:9

    % start new plot
    subplot(3,4,i)
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
            endOfCycle = checkEndOfCycle(PosData(index,:), endLimits);
        end
    end

    % move on to the new cycle
    endOfCycle = false;

    cycleChangeIndex(i) = index;
    

    % go through at least 50 points before checking again
    bufferPoints = 0;

end


cycleDataFirst = PosData(cycleChangeIndex(1):cycleChangeIndex(2), :);
cycleDataSecond = PosData(cycleChangeIndex(2):cycleChangeIndex(3), :);
cycleDataThird = PosData(cycleChangeIndex(3):cycleChangeIndex(4), :);
cycleDataFourth = PosData(cycleChangeIndex(4):cycleChangeIndex(5), :);
cycleDataFifth = PosData(cycleChangeIndex(5):cycleChangeIndex(6), :);
cycleDataSixth = PosData(cycleChangeIndex(6):cycleChangeIndex(7), :);
cycleDataSeventh = PosData(cycleChangeIndex(7):cycleChangeIndex(8), :);
cycleDataEighth = PosData(cycleChangeIndex(8):length(PosData), :);

figure;
hold on
view(0,90)
plot3(cycleDataEighth(:,1), cycleDataEighth(:,2), cycleDataEighth(:,3), 'color', colour{7})



function [isEnd] = checkEndOfCycle(point, endLimits) 

    isEnd = false;

    if (point(1) >= endLimits(1,1) && point(1) <= endLimits(1,2)) && (point(2) >= endLimits(2,1) && point(2) <= endLimits(2,2)) && (point(3) >= endLimits(3,1) && point(3) <= endLimits(3,2))
        isEnd = true;
    end

end


