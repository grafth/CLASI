function [out] = setTransmissionOffAP(angDeg, fid)

out         = [];
out.err     = '';
out.status  = 0;

if(nargin == 0 || isempty(angDeg))
    angDeg  = 340;
end

if(nargin < 2 || fid == -1)
    fid = 1;
end

% Command
angDegH = dec2hex(floor(1024/360*mod(round(angDeg),360)),4);
cmd     = ['26'; 'AA'; angDegH(1:2); angDegH(3:4) ; '0D'];

% Send command
udpObj  = udpSetup;
sendUDPData(udpObj,cmd);

% Receive Data
rxLen   = 5;
dt      = receiveUDPData(udpObj,cmd);
udpClose(udpObj);
if(isempty(dt))
    err     = sprintf('[ERROR] [setTransmissionOffAP] Invalid UDP data');
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end

% Check received data
if(size(dt,1) ~= rxLen)
    err     = sprintf('[ERROR] [setTransmissionOffAP] Invalid received data length. Expected %d, Received %d', rxLen,size(dt,1));
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end

if(strcmp(dt(3,:),cmd(3,:)) && strcmp(dt(4,:),cmd(4,:)))
    out.status  = 1;
else
    out.status  = 0;
    err     = sprintf('[ERROR] [setTransmissionOffAP] Received data does not match');
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end
end