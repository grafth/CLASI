function [out,err] = receiveUDPData(udpObj,cmd,fid)

out     = [];
err     = '';

if(nargin < 2)
    err     = sprintf('Invalid function call. udpObj and cmd required');
    fprintf(1,[err '\n']);
    out.err = err;
    return;
end

if(nargin <= 2 || fid == -1)
    fid = 1;
end

% Receive data
str_d   = fread(udpObj);

% Convert to hex
out     = dec2hex(str_d);

if(isempty(out))
    err     = sprintf('[ERROR] [receiveUDPData] UDP Timeout');
    out     = [];
    fprintf(fid,[err '\n']);
    return;
end

% Check received data
if(size(out,1) < size(cmd,1))
    err     = sprintf('[ERROR] [receiveUDPData] Invalid received data length. Expected >=%d, Received %d', size(cmd,1),size(out,1));
    out     = [];
    fprintf(fid,[err '\n']);
    return;
end
if(~strcmp(out(1,:),'23') || ~strcmp(out(2,:),cmd(2,:)))
    err     = sprintf('[ERROR] [receiveUDPData] Invalid header or command Id');
    out     = [];
    fprintf(fid,[err '\n']);
    return;
end
if(~strcmp(out(end,:),cmd(end,:)))
    err     = sprintf('[ERROR] [receiveUDPData] Invalid end of command');
    out     = [];
    fprintf(fid,[err '\n']);
    return;
end
end