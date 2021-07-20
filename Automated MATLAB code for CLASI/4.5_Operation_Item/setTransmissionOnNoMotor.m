function [out,dt] = setTransmissionOnNoMotor(fid)

out         = [];
out.err     = '';
out.status  = 0;

if(nargin == 0 || fid == -1)
    fid = 1;
end
cmd     = ['26'; '98'; '11'; '0D'];
% Send command (Set flash memory)
udpObj  = udpSetup;
sendUDPData(udpObj,cmd);
% Receive Data
rxLen   = 4;
dt      = receiveUDPData(udpObj,cmd);
udpClose(udpObj);
if(isempty(dt))
    err     = sprintf('[ERROR] [setTransmissionOnNoMotor] Invalid UDP data');
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end

% Check received data
if(size(dt,1) ~= rxLen)
    err      = sprintf('[ERROR] [setTransmissionOnNoMotor] Invalid received data length. Expected %d, Received %d', rxLen,size(dt,1));
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end

if(strcmp(dt(3,:),cmd(3,:)))
    out.status  = 1;
else
    out.status  = 0;
    err     = sprintf('[ERROR] [setTransmissionOnNoMotor] Received data does not match');
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end
end