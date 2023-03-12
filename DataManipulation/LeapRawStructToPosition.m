structArray = load("Data\matleapTestHandData_12-03-23.mat").testHandData;
figure
hold on;
for i = 1:length(structArray)
    hands = structArray(i).hands;
    if(length(hands) > 1)
        fprintf("at spot %d, length is %d\n", i, length(hands))
    end
    if (~isempty(hands))
        palm = hands(1).palm;
        pos = palm.position;
        plot3(pos(1),pos(2),pos(3), '.r', LineWidth=6) ;
        drawnow
        pause(0.2)
    end
    
end
