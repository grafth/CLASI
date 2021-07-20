function [out] = getModelCode(fid)

out         = [];
out.err     = '';
out.status  = 0;

if(nargin == 0 || fid == -1)
    fid = 1;
end

% Command
cmd     = ['26'; '72'; 'FF'; '0D'];

% Send command
udpObj  = udpSetup;
sendUDPData(udpObj,cmd);

% Receive Data
rxLen   = 4;
dt      = receiveUDPData(udpObj,cmd);
udpClose(udpObj);
if(isempty(dt))
    err     = sprintf('[ERROR] [getSerialNumber] Invalid UDP data');
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end

% Check received data
if(size(dt,1) ~= rxLen)
    err     = sprintf('[ERROR] [getModelCode] Invalid received data length. Expected %d, Received %d', rxLen,size(dt,1));
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end


if(strcmp(dt(3,:),'00'))
    out.model   = '2kW Dome';
    out.radar   = 'MDS-50R';
elseif(strcmp(dt(3,:),'01'))
    out.model   = '4kW Dome';
    out.radar   = 'MDS-51R';
elseif(strcmp(dt(3,:),'02'))
    out.model   = '4kW Open';
    out.radar   = 'MDS-52R';
elseif(strcmp(dt(3,:),'03'))
    out.model   = '6kW Open';
    out.radar   = 'MDS-61R';
elseif(strcmp(dt(3,:),'04'))
    out.model   = '12kW Open';
    out.radar   = 'MDS-62R';
elseif(strcmp(dt(3,:),'05'))
    out.model   = '25kW Open';
    out.radar   = 'MDS-63R';
elseif(strcmp(dt(3,:),'FF'))
    out.model   = 'Unknown';
    out.radar   = '';
end
out.status      = 1;
end