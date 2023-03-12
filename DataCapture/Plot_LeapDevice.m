
numSeconds = 10;

leap_data = get_leap_data(numSeconds);

figure
hold on;
axis equal;
title("Leap Palm Positional Data 12/03/23")
view([0,90])

for i = 1:length(leap_data)

    hands = leap_data(i).hands;

    if (~isempty(hands))
        palm = hands(1).palm;
        pos = palm.position;
        plot3(pos(1),pos(2),pos(3), '.r', LineWidth=6) ;
        drawnow
%         pause(0.02)
    end
    
end