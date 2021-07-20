function [out] = setTrailSettingSecFrames(level, fid)

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
if(strcmpi(level,'OFF'));
    cmd = ['26'; '73'; '00'; '0D'];
elseif(strcmpi(level,'15'))
    cmd = ['26'; '73'; '8F'; '0D'];
elseif(strcmpi(level,'30'))
    cmd = ['26'; '73'; '9E'; '0D'];
elseif(strcmpi(level,'Continuous'))
    cmd = ['26'; '73'; 'F0'; '0D']; 
end

% Send command
udpObj  = udpSetup;
sendUDPData(udpObj,cmd);

% Receive Data
rxLen   = 4;
dt      = receiveUDPData(udpObj,cmd);
udpClose(udpObj);
if(isempty(dt))
    err     = sprintf('[ERROR] [setTrailSettingSecFrames] Invalid UDP data');
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end

% Check received data
if(size(dt,1) ~= rxLen)
    err     = sprintf('[ERROR] [setTrailSettingSecFrames] Invalid received data length. Expected %d, Received %d', rxLen,size(dt,1));
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end

if(strcmp(dt(3,:),cmd(3,:)))
    out.status  = 1;
else
    out.status  = 0;
    err     = sprintf('[ERROR] [setTrailSettingSecFrames] Received data does not match');
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end
end