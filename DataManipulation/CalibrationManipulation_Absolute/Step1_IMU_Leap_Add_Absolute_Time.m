function Step1_IMU_Leap_Add_Absolute_Time
    
    %% inputs
    load('Data/Session02_RawData/IMU_Leap_Data/Raw_IMU_and_Leap_Exp_11B.mat')
    shortFileName = "Raw_IMU_and_Leap_Exp_11B";
    OG_Time = datetime('10:59:20.000'); % GOING 5 SECONDS BACK DUE TO DISCREPANCY
    
    %% calculations
    OG_Time.Format = 'HH:mm:ss.SSS';
    
    AbsoluteTimes = datetime(zeros(300,1),0,0);
    
    for i = 1:length(Times)
        AbsoluteTimes(i) = OG_Time + seconds(Times(i));
    end
    AbsoluteTimes.Format = 'HH:mm:ss.SSS';
    
    lastestMotiveTime = '10:59:31.000';
    
    targetTime = datetime(lastestMotiveTime, 'InputFormat', 'HH:mm:ss.SSS');
    
    lastIndex = find(AbsoluteTimes > targetTime, 1, 'first') - 1;
    
    if (~isempty(lastIndex))
        IMU_readings_cut = IMU_readings(1:lastIndex);
        Leap_readings_cut = Leap_readings(1:lastIndex);
        Times_cut = Times(1:lastIndex);
        AbsoluteTimes_cut = AbsoluteTimes(1:lastIndex);
    else
        IMU_readings_cut = IMU_readings;
        Leap_readings_cut = Leap_readings;
        Times_cut = Times;
        AbsoluteTimes_cut = AbsoluteTimes;
    end
    
    newFileName = sprintf("Data/Session02_IMU_Data_Cut/%s_cut.mat", shortFileName);
    
    save(newFileName, "IMU_readings_cut", "Leap_readings_cut", "Times_cut", "AbsoluteTimes_cut")
end