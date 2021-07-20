function [out] = setInterferenceRejection(level, fid)

out         = [];
out.err     = '';
out.status  = 0;

if(nargin == 0 || isempty(level))
    level  = 'OFF';
end

if(nargin < 2 || fid == -1)
    fid = 1;
end

% Command
if(strcmp(level,'L1'))
    cmd = ['26'; '49'; '11'; '0D'];
elseif(strcmp(level,'L2'))
    cmd = ['26'; '49'; '22'; '0D'];
elseif(strcmp(level,'L3'))
    cmd = ['26'; '49'; '33'; '0D'];    
elseif(strcmp(level,'OFF'))
    cmd = ['26'; '49'; '00'; '0D'];
else
    err     = sprintf('[ERROR][setInterferenceRejection] Invalid input');
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end

% Send command
udpObj  = udpSetup;
sendUDPData(udpObj,cmd);

% Receive Data
rxLen   = 4;
dt      = receiveUDPData(udpObj,cmd);
udpClose(udpObj);
if(isempty(dt))
    err     = sprintf('[ERROR] [setInterferenceRejection] Invalid UDP data');
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end

% Check received data
if(size(dt,1) ~= rxLen)
    err     = sprintf('[ERROR] [setInterferenceRejection] Invalid received data length. Expected %d, Received %d', rxLen,size(dt,1));
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end

if(strcmp(dt(3,:),cmd(3,:)))
    out.status  = 1;
else
    out.status  = 0;
    err     = sprintf('[ERROR] [setInterferenceRejection] Received data does not match');
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end
end