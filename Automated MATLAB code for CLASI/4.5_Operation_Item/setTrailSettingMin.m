function [out] = setTrailSettingMin(level, fid)

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
    cmd = ['26'; '6D'; '00'; '0D'];
elseif(strcmpi(level,'6'))
    cmd = ['26'; '6D'; '06'; '0D'];
elseif(strcmpi(level,'3'))
    cmd = ['26'; '6D'; '03'; '0D'];
elseif(strcmpi(level,'1'))
    cmd = ['26'; '6D'; '01'; '0D']; 
end

% Send command
udpObj  = udpSetup;
sendUDPData(udpObj,cmd);

% Receive Data
rxLen   = 4;
dt      = receiveUDPData(udpObj,cmd);
udpClose(udpObj);
if(isempty(dt))
    err     = sprintf('[ERROR] [setTrailSettingMin] Invalid UDP data');
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end

% Check received data
if(size(dt,1) ~= rxLen)
    err     = sprintf('[ERROR] [setTrailSettingMin] Invalid received data length. Expected %d, Received %d', rxLen,size(dt,1));
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end

if(strcmp(dt(3,:),cmd(3,:)))
    out.status  = 1;
else
    out.status  = 0;
    err     = sprintf('[ERROR] [setTrailSettingMin] Received data does not match');
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end
end