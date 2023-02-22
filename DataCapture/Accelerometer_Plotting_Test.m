
data = readtable('output.txt', 'ReadVariableNames', false);
summary(data)
% 
% figure;
% plot(data(:,1), data(:,2))


% a = arduino('COM10','Leonar54665tdo')
a.scanI2CBus
% a.AvailableI2CBusIDs
% a.AvailableSerialPortIDs