function [udpObj] = udpSetup()

% Specify PC IP and port
controlPCIP     = '192.168.0.100';
controlPCPort   = 49155;%53664;%8000;

% Specify Koden box IP and port
kodenBoxIP      = '192.168.0.1';%192.168.0.6'
kodenBoxPort    = 10001;

% Initialize UDP TX/RX object
udpObj          = udp(kodenBoxIP,kodenBoxPort,'LocalPort',controlPCPort);
set(udpObj,'ByteOrder','littleEndian','Timeout',1);
udpObj.EnablePortSharing = 'on';
fopen(udpObj);
% fclose(udpObj);
end