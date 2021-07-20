function [out] = setPulseWidth(pwStr, fid)

out         = [];
out.err     = '';
out.status  = 0;

if(nargin == 0 || isempty(pwStr))
    pwStr   = 'long';
end

if(nargin < 2 || fid == -1)
    fid = 1;
end

% Command
if(strcmpi(pwStr,'short'))
    pwStrH  = '00';
elseif(strcmpi(pwStr,'long'))
    pwStrH  = '01';
else
    err     = sprintf('[ERROR] [setPulseWidth] Invalid pulse width selection');
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end
cmd     = ['26'; 'A4'; pwStrH ; '0D'];

% Send command
udpObj  = udpSetup;
sendUDPData(udpObj,cmd);

% Receive Data
rxLen   = 4;
dt      = receiveUDPData(udpObj,cmd);
udpClose(udpObj);
if(isempty(dt))
    err     = sprintf('[ERROR] [setPulseWidth] Invalid UDP data');
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end

% Check received data
if(size(dt,1) ~= rxLen)
    err     = sprintf('[ERROR] [setPulseWidth] Invalid received data length. Expected %d, Received %d', rxLen,size(dt,1));
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end

if(strcmp(dt(3,:),cmd(3,:)))
    out.status  = 1;
else
    out.status  = 0;
    err     = sprintf('[ERROR] [setPulseWidth] Received data does not match');
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end
end