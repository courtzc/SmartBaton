% smoothing window returned from smoothdata() function on raw array in this folder.
load("Data\smoothingWindow.mat");
mean(window_array)
max(window_array)
prctile(window_array, 80)