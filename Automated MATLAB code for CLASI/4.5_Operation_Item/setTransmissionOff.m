function [out] = setTransmissionOff(fid)

out         = [];
out.err     = '';
out.status  = 0;

if(nargin == 0 || fid == -1)
    fid = 1;
end

% Command
cmd     = ['26'; '74'; '00'; '0D'];

% Send command
udpObj  = udpSetup;
sendUDPData(udpObj,cmd);

% Receive Data
rxLen   = 4;
dt      = receiveUDPData(udpObj,cmd);
udpClose(udpObj);
if(isempty(dt))
    err     = sprintf('[ERROR] [setTransmissionOff] Invalid UDP data');
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end

% Check received data
if(size(dt,1) ~= rxLen)
    err     = sprintf('[ERROR] [setTransmissionOff] Invalid received data length. Expected %d, Received %d', rxLen,size(dt,1));
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end

if(strcmp(dt(3,:),cmd(3,:)))
    out.status  = 1;
else
    out.status  = 0;
    err     = sprintf('[ERROR] [setTransmissionOff] Received data does not match');
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end
end