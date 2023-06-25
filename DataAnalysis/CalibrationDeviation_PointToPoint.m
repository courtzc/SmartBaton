% initialise GUID controller
myGuidController = GUID_Controller;
close all;

%% file load
expID = "12B";
Smooth_Baton_filename = sprintf("Data/Session02_SmoothBatonPosition/Smooth_Baton_Pos_%s.mat",expID);
Motive_filename = sprintf("Data/Session02_ManipulatedData/TrackingDataTime_Resampled_Scaled_Rotated/Session02_Exp_%s_BBaton_BlanksRemoved_SimpleCentroid_Resampled_Scaled_Rotated.mat",expID);

 

Motive_Readings = load(Motive_filename).rotated_tracking_data;
Motive_Readings = Motive_Readings(:,2:4);
Smooth_Baton_Readings = load(Smooth_Baton_filename).transformed_baton_tip_pos_smoothed_array;

desired_num_points = length(Smooth_Baton_Readings(1,:));

% Calculate the resampling factor
resampling_factor = size(Motive_Readings, 2) / desired_num_points;

% Preallocate the resampled array
Motive_Readings_Resampled = zeros(3, desired_num_points);

% Resample each dimension of the array
for i = 1:3
    Motive_Readings_Resampled(i, :) = interp1(1:size(Motive_Readings, 2), Motive_Readings(i, :), ...
        linspace(1, size(Motive_Readings, 2), desired_num_points));
end

% get distances
dists = vecnorm(Motive_Readings_Resampled' - Smooth_Baton_Readings', 2, 2);
figure
plot(dists)

disp("maximum deviation")
fprintf("max: %.2f\n", max(dists))