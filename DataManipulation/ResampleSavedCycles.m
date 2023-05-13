% Resample Saved Cycles

% Get all files of the jth feature
miniPattern = "C:\Users\Courtney\source\repos\ThesisProject\" + ...
    "Data\Session01_ManipulatedData\SavedCycles\Session01_Exp_*.mat";

% collect the files
theFiles = dir(miniPattern);


% do for every file in the files
for k = 1:length(theFiles)
   
    % read in cycle from file
    currFileName = theFiles(k).name;
    withFolders = "Data\Session01_ManipulatedData\SavedCycles\"+currFileName;
    fprintf(1, 'Now reading %s\n', currFileName)
    cycle = load(withFolders).tXYZ;

    % start the time index from zero
    cycle(:,1) = [cycle(:,1)]-cycle(1,1);
    
    % convert into a 'timetable' (very easy to resample times from here)
    t = array2timetable(cycle(:, 2:end), 'rowTimes', datetime(0, 0, 0, 0, 0, cycle(:, 1), 'Format', 'ss.SSS'));
    
    % resample!
    desiredInterval = 0.002;
    barLength76bpm = 3.157900;
    newtimes = datetime(0, 0, 0, 0, 0, 0) : duration(0, 0, desiredInterval) : datetime(0, 0, 0, 0, 0, barLength76bpm);
    newtimes.Format = 'ss.SSS';
    newt = retime(t, newtimes, 'linear');

    % convert values back into number arrays
    X = table2array(newt(:,1));
    Y = table2array(newt(:,2));
    Z = table2array(newt(:,3));
    
    % convert the datetime values to durations (this is a bit more
    % complicated)
    T = timetable2table(newt);
    t = table2array(T(:,1)); % this may not be fully needed? might be able to go straight from newt to array.
    t = seconds(t - dateshift(t,'start','day')); % convert to durations inside brackets, then to doubles with the seconds() function.
    

    % concatenate new data
    tXYZ = [t, X, Y, Z];
    
    % save new data
    fileName = sprintf("Data\\Session01_ManipulatedData\\SavedCycles_Resampled\\%s_Resampled.mat", currFileName(1:end-4));
    save(fileName, 'tXYZ');

end