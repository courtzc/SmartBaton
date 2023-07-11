function Step2_ChangeToRelativeTime

    expID = "B1_023_System";
    fileToLoad = sprintf("Data/Session04_ManipulatedData/AbsoluteTime_SystemPos/AbsoluteTime_Smooth_Baton_Pos_%s.mat", expID);
    AbsolutePos = load(fileToLoad).tXYZ_System;
    fprintf(1, 'Now reading %s\n', expID)
    tXYZ_System = AbsolutePos;

    % get first time, make it a date time, then set first time to 0.000
    firstEpoch = AbsolutePos(1,1);
    firstTime = datetime(firstEpoch,'ConvertFrom','epochtime','TicksPerSecond',1000,'Format', 'MM/dd/yy HH:mm:ss.SSS');
    tXYZ_System(1,1) = 0.000;

    for i = 2:length(AbsolutePos(:,1))
        % get new epoch
        epocht = AbsolutePos(i,1);
        absTime = datetime(epocht,'ConvertFrom','epochtime','TicksPerSecond',1000,'Format', 'MM/dd/yy HH:mm:ss.SSS');

        % get calendar duration, extract the seconds, and assign
        relTime = between(firstTime,absTime,"time");
        [~,t] = split(relTime,{'days','time'});
        sec = seconds(t);
        tXYZ_System(i,1) = sec;

    end

     fileToSave = sprintf("Data/Session04_ManipulatedData/RelativeTime_SystemPos/RelativeTime_Smooth_Baton_Pos_%s.mat", expID);
    save(fileToSave, "tXYZ_System");

end

