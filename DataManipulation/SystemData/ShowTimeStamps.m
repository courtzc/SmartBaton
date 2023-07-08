

expID = "53C";
fileToLoad = sprintf("Data/Session03_ManipulatedData/Time_SmoothBatonPosition/Time_Smooth_Baton_Pos_%s.mat", expID);
AbsolutePos = load(fileToLoad).tXYZ_System;


timeFirst = datetime(AbsolutePos(1,1),'ConvertFrom','epochtime','TicksPerSecond',1000,'Format', 'dd/MM/yy HH:mm:ss.SSS');
timeFirst.TimeZone = '+10:00';
disp(expID)
disp(timeFirst)

timeLast = datetime(AbsolutePos(end,1),'ConvertFrom','epochtime','TicksPerSecond',1000,'Format', 'dd/MM/yy HH:mm:ss.SSS');
% timeLast = datetime(AbsolutePos((end-42),1),'ConvertFrom','epochtime','TicksPerSecond',1000,'Format', 'dd/MM/yy HH:mm:ss.SSS');
timeLast.TimeZone = '+10:00';

disp(timeLast)

% fprintf("%d",AbsolutePos(1,1))
% tXYZ_System = AbsolutePos(2:end,1:4)
% 
% tXYZ_System = AbsolutePos(1:(end-42),:)

tXYZ_System = AbsolutePos;
% save(fileToLoad, 'tXYZ_System');