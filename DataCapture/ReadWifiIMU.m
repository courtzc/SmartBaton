% create tcp connection with known static IP address and port number
IPAddress = '192.168.1.199'; % Replace with the IP address of the Wi-Fi device
PortNumber = 23; % Replace with the port number of the Wi-Fi device
t = tcpclient(IPAddress, PortNumber);
i = 0;
tic;
while (i < 11)

    
    bytesAvailable = t.NumBytesAvailable;
%     fprintf("before: %d\n", bytesAvailable);

    data = read(t);

    data_str = char(data);
    data_num = str2num(data_str);
    disp(data_num);

    if (bytesAvailable < 70 && bytesAvailable > 0)
        fprintf("read line %d\n", i);
        i = i + 1;
    end

    pause(0.005); % Wait for 10 ms before reading again
end
toc;
duration = toc*1000;

fprintf("time taken: %.2fms\t", duration)

% close the tcp connection
clear t
