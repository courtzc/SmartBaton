% Get all files of the jth feature
theFiles = [];
for j = 4:6
    miniPattern = "C:\Users\Courtney\source\repos\ThesisProject\" + ...
        "Data\Session01_ManipulatedData\SavedCycles_Resampled\" + ...
        "Session01_*_00"+j+"_SavedCycle_*.mat";
    
    % collect the files
    theFiles = [theFiles; dir(miniPattern)];
    
end

A = zeros(1579,4,length(theFiles));

% do for every file in the files
for k = 1:length(theFiles)
   
    % read in cycle from file
    currFileName = theFiles(k).name;
    withFolders = "Data\Session01_ManipulatedData\SavedCycles_Resampled\"+currFileName;
    fprintf(1, 'Now reading %s\n', currFileName)
    A(:,:,k) = load(withFolders).tXYZ;

end

tXYZ_Average = mean(A,3);
figure;
plot(tXYZ_Average(:,2), tXYZ_Average(:,3))

% save new data
fileName = sprintf("Session01_ExpA1_All_Resampled_Average.mat"); %1:30 is "Session0X_ExpXX_00X_SavedCycle"
save(fileName, 'tXYZ_Average');