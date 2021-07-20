% ----------------------------------------------------------------------- %
% function raw = readRawMetadata(fname)
% Inputs:   fname       - full path name to the raw file
%
% Usage:    1) raw = readRawMetadata(fname)- Reads all metadata from file
%
% ** File History **
% 06/22/2017 - Created
%
% ----------------------------------------------------------------------- %

function raw = readRawMetadata(fname,decimation_factor)


raw = [];

if(nargin < 1 || nargin > 2)
    clc;
    fprintf(1,'Invalid function call\n');
    help readRawData;
    return;
end


fid = fopen(fname,'r');
if(fid == -1)
    fprintf(1,'Invalid file name\n');
    return;
end

sync = [hex2dec('AA'), hex2dec('55'), hex2dec('0F'), hex2dec('F0')];

d = dir(fname);

raw.fileSize        = d.bytes;  % Size of the file
raw.rHdrSz          = 16;       % Record header size
raw.bytesPerSample  = 2;
raw.packetSize      = 0;        % Expected packet size (updated later)
raw.recordSize      = 0;        % Expected Record size (updated later)
br                  = 0;        % Bytes read
raw.nPackets        = 0;
raw.format          = 0;
raw.packetNum       = 0;
raw.sync            = 0;
raw.azimuth         = 0;
raw.chASamples      = 0;
raw.chBSamples      = 0;
raw.systemTime      = 0;
raw.nRecords        = 0;


fseek(fid,0,'bof');

% Read sync
for ii=1:1:4
    if(fread(fid,1,'uint8') ~= sync(ii))
        fprintf(1,'Invalid format or sync byte. Cant read file\n');
        break;
    end
    br = br + 1;
end

fseek(fid,0,'bof');
br = 0;
        
% Read sync byte
raw.sync = fread(fid,1,'uint32');
br = br + 4;

% Read packet number
raw.packetNum = fread(fid, 1, 'uint32'); 
br = br + 4;

% Read antenna azimuth
raw.azimuth   = fread(fid, 1, 'single');
br = br + 4;

% Read number of IF samples
raw.chASamples = fread(fid,1,'uint32')/decimation_factor;
br = br + 4;

% Read number of video samples
raw.chBSamples = fread(fid,1,'uint32')/decimation_factor;
br = br + 4;

% Read system time
raw.systemTime = fread(fid, 1, 'double');
br = br + 8;

% Read number of records (pulses) per packet
raw.nRecords = fread(fid,1,'uint32');
br = br + 4;

% Calculate the record (pulse) size
raw.recordSize = 0;
if(raw.chASamples ~= 0)
    raw.recordSize = raw.recordSize + ...
                     raw.rHdrSz + raw.bytesPerSample * raw.chASamples;
end
if(raw.chBSamples ~= 0)
    raw.recordSize = raw.recordSize + ...
                     raw.rHdrSz + raw.bytesPerSample * raw.chBSamples;
end

% Calculate the packet size
raw.packetSize = br + raw.nRecords * raw.recordSize;

% Calclate the number of packets
raw.nPackets = floor(raw.fileSize/raw.packetSize);


fclose(fid);
