figure;
hold on;
axis equal;
title('raw vs smoothed data for baton tip')
view([0,90])
baton_tip_pos_raw_array = baton_tip_pos_raw_array(:, 2:end);
baton_tip_pos_smoothed_array = baton_tip_pos_smoothed_array(:, 2:end);

plot3(baton_tip_pos_raw_array(1,:), baton_tip_pos_raw_array(2,:), baton_tip_pos_raw_array(3,:), 'color', 'r')
plot3(baton_tip_pos_smoothed_array(1,:), baton_tip_pos_smoothed_array(2,:), baton_tip_pos_smoothed_array(3,:), 'color', 'b', LineWidth=1.5)
legend('raw', 'smoothed')