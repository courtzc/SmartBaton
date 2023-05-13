close all;

% myGuidController = GUID_Controller;

miniPattern = "C:\Users\Courtney\source\repos\ThesisProject\" + ...
    "Data\Session01_SimpleCentroidTrackingDataTime\*.csv";
    
% collect the files
theFiles = dir(miniPattern);

dirToSave = "C:\Users\Courtney\source\repos\ThesisProject\" + ...
    "Data\Session01_ManipulatedData";


% do for every file in the files
for k = 1:length(theFiles)

    T = readtable(theFiles(k).name);
    tXYZ = table2array(T);
    rawFileName = theFiles(k).name;
    fileName = sprintf("%stXYZ.mat", rawFileName(1:21));
    placeToSave = sprintf("%s\\%s", dirToSave, fileName)
    save(placeToSave, 'tXYZ');

end
