Fs = sample_rate;
decim = 2;
[orientation,angularVelocity] = FUSE(accelReadings,gyroReadings);
time = (0:1:size(accelReadings-2,1)-1)/Fs;

figure
hold on
plot(time,eulerd(orientation,'ZYX','frame'))
title('Orientation Estimate')
legend('Z-axis', 'Y-axis', 'X-axis')
xlabel('Time (s)')
ylabel('Rotation (degrees)')

figure
hold on
tp = theaterPlot('XLimit',[-2 2],'YLimit',[-2 2],'ZLimit',[-2 2]);
op = orientationPlotter(tp,'DisplayName','Fused Data',...
    'LocalAxesLength',2);

for i=1:numel(orientation)
    plotOrientation(op, orientation(i))
    pause(0.02)
    drawnow
end