function [out] = setSTCAdjustment(level, fid)

out         = [];
out.err     = '';
out.status  = 0;

if(nargin == 0 || isempty(level))
    level  = 72;
end

if(nargin < 2 || fid == -1)
    fid = 1;
end

% Check Gain
if(level < 0 || level > 99)
    err     = sprintf('[ERROR][setSTCAdjustment] Level should be between 0 and 99 (inclusive)');
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end

% Command
cmd     = ['24'; '53'; dec2hex(level,2); '0D'];

% Send command
udpObj  = udpSetup;
sendUDPData(udpObj,cmd);

% Receive Data
rxLen   = 4;
dt      = receiveUDPData(udpObj,cmd);
udpClose(udpObj);
if(isempty(dt))
    err     = sprintf('[ERROR] [setSTCAdjustment] Invalid UDP data');
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end

% Check received data
if(size(dt,1) ~= rxLen)
    err     = sprintf('[ERROR] [setSTCAdjustment] Invalid received data length. Expected %d, Received %d', rxLen,size(dt,1));
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end

if(strcmp(dt(3,:),cmd(3,:)))
    out.status  = 1;
else
    out.status  = 0;
    err     = sprintf('[ERROR] [setSTCAdjustment] Received data does not match');
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end
end