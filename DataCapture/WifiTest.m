IPAddress = '192.168.1.199'; % Replace with the IP address of the Wi-Fi device
PortNumber = 23; % Replace with the port number of the Wi-Fi device
t = tcpclient(IPAddress, PortNumber);
disp(t)