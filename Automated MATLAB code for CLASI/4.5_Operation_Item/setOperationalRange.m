function [out] = setOperationalRange(range_nm, mode, fid)

out         = [];
out.err     = '';
out.status  = 0;

if(nargin == 0 || isempty(range_nm))
    range_nm  = 96;
end
if(nargin <= 1 || isempty(mode))
    mode    = 'normal';
    % mode  = 'd1';
    % mode  = 'd2';
end

if(nargin < 3 || fid == -1)
    fid = 1;
end

% Check if command works with radar config
mc  = getModelCode;
if(strcmp(mc.radar,'MDS-50R'))
    max_range_nm    = 24;
elseif(strcmp(mc.radar,'MDS-51R'))
    max_range_nm    = 36;
elseif(strcmp(mc.radar,'MDS-52R'))
    max_range_nm    = 48;
elseif(strcmp(mc.radar,'MDS-61R'))
    max_range_nm    = 64;
elseif(strcmp(mc.radar,'MDS-62R'))
    max_range_nm    = 72;
elseif(strcmp(mc.radar,'MDS-63R'))
    max_range_nm    = 96;
else
    max_range_nm    = 1/8;
end

range_nm    = min(range_nm, max_range_nm);
range_m     = 0;

if(range_nm == 1/8)
    rCode   = 'X000E7';
    range_m = 231;
elseif(range_nm == 1/4)
    rCode   = 'X001CF';
    range_m = 463;
elseif(range_nm == 1/2)
    rCode   = 'X0039E';
    range_m = 926;
elseif(range_nm == 3/4)
    rCode   = 'X0056D';
    range_m = 1389;
elseif(range_nm == 1)
    rCode   = 'X0073C';
    range_m = 1852;
elseif(range_nm == 1.5)
    rCode   = 'X00ADA';
    range_m = 2778;
elseif(range_nm == 2)
    rCode   = 'X00E78';
    range_m = 3704;
elseif(range_nm == 3)
    rCode   = 'X015B4';
    range_m = 5556;
elseif(range_nm == 4)
    rCode   = 'X01CF0';
    range_m = 7408;
elseif(range_nm == 6)
    rCode   = 'X02B68';
    range_m = 11112;
elseif(range_nm == 8)
    rCode   = 'X039E0';
    range_m = 14816;
elseif(range_nm == 12)
    rCode   = 'X056D0';
    range_m = 22224;
elseif(range_nm == 16)
    rCode   = 'X073C0';
    range_m = 29632;
elseif(range_nm == 24)
    rCode   = 'X0ADA0';
    range_m = 44448;
elseif(range_nm == 32)
    rCode   = 'X0E780';
    range_m = 59264;
elseif(range_nm == 36)
    rCode   = 'X10470';
    range_m = 66672;
elseif(range_nm == 48)
    rCode   = 'X15B40';
    range_m = 88896;
elseif(range_nm == 64)
    rCode   = 'X1CF00';
    range_m = 118528;
elseif(range_nm == 72)
    rCode   = 'X208E0';
    range_m = 133344;
elseif(range_nm == 96)
    rCode   = 'X2B680';
    range_m = 177792;
end
range_n     = ['2' rCode(2:end)];
range_d1    = ['2' dec2hex(hex2dec(rCode(2))+4) rCode(3:end)];
range_d2    = ['2' dec2hex(hex2dec(rCode(2))+8) rCode(3:end)];

if(strcmp(mode,'normal'))
    cmd     = ['26'; range_n(1:2); range_n(3:4); range_n(5:6); '0D'];
elseif(strcmp(mode,'d1'))
    cmd     = ['26'; range_d1(1:2); range_d1(3:4); range_d1(5:6); '0D'];
elseif(strcmp(mode,'d2'))
    cmd     = ['26'; range_d2(1:2); range_d2(3:4); range_d2(5:6); '0D'];
end

% Send command
udpObj  = udpSetup;
sendUDPData(udpObj,cmd);

% Receive Data
rxLen   = 5;
dt      = receiveUDPData(udpObj,cmd);
out.dt=dt;
udpClose(udpObj);
if(isempty(dt))
    err     = sprintf('[ERROR] [setOperationalRange] Invalid UDP data');
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end

% Check received data
if(size(dt,1) ~= rxLen)
    err     = sprintf('[ERROR] [setOperationalRange] Invalid received data length. Expected %d, Received %d', rxLen,size(dt,1));
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end

if(strcmp(dt(3,:),cmd(3,:)) && strcmp(dt(4,:),cmd(4,:)))
    out.status  = 1;
else
    out.status  = 0;
    err     = sprintf('[ERROR] [setOperationalRange] Received data does not match');
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end
end