% ----------------------------------------------------------------------- %
% function raw = readRawData(fname,nPackets)
% Inputs:   fname       - full path name to the raw file
%           nPackets    - number of samples to be read (<= 10000)
% Outputs:  raw         - raw file data
%
% Usage:    1) raw = readRawData(fname)         - Reads all complete 
%                   samples from file
%           2) raw = readRawData(fname,nPackets)- Reads specified number of
%                   samples from file
%
% ** File History **
% 06/22/2017 - Created
% ----------------------------------------------------------------------- %

function raw = readRawData(fname,decimation_factor)

raw = [];

if(nargin ==1)
 decimation_factor = 1;    
end


fid = fopen(fname,'r');
if(fid == -1)
    fprintf(1,'Invalid file name\n');
    return;
end

raw = readRawMetadata(fname,decimation_factor);
if(isempty(raw))
    return;
end

maxSamples = 10000; %DEG same as rawPacketsPerFile in header file
if(raw.nPackets > maxSamples)
    raw.nPackets = maxSamples;
end

pn = 0;                     % Packet Number
rn = 0;                     % Record Number
br = 0;                     % Bytes read

while (~feof(fid) && pn < raw.nPackets)
    pn = pn + 1;
    if(mod(br,raw.packetSize) ~= 0)
        fprintf(1,'Read error\n');
        return;
    end
    % --------------- Read Packet Header --------------- %
   
    
    % Read sync
    raw.sync = fread(fid,1,'uint32');
    br = br + 4;
    % Read packet number
    packetNum = fread(fid, 1, 'uint32'); 
    br = br + 4;

    % Read antenna azimuth
    azimuth   = fread(fid, 1, 'single');
    br = br + 4;

    % Read number of IF samples
    raw.chASamples = fread(fid,1,'uint32')/decimation_factor;
    br = br + 4;
    
    % Read number of video samples
    raw.chBSamples = fread(fid,1,'uint32')/decimation_factor;%DEG
    br = br + 4;
    
    % Read system time
    systemTime = fread(fid, 1, 'double');
    br = br + 8;
    
    % Read number of records (pulses) per packet
    raw.nRecords = fread(fid,1,'uint32');
    br = br + 4;
    
    
    % ------------- End Read Packet Header ------------- %
    
    % Initialize output arrays
    if(pn == 1)
        raw.chAData = zeros(raw.chASamples,raw.nPackets*raw.nRecords);
        if(raw.chBSamples ~= 0)
            raw.chBData = zeros(raw.chBSamples,raw.nPackets*raw.nRecords);
        end
        raw.azimuth = zeros(1,raw.nPackets*raw.nRecords);
        raw.systemTime = zeros(1,raw.nPackets*raw.nRecords); 
        raw.packetNum = zeros(1,raw.nPackets*raw.nRecords); 
    end
    
    idx = (pn - 1) * raw.nRecords;
    raw.azimuth(idx + 1: idx + raw.nRecords) = azimuth;
    raw.systemTime(idx+ 1: idx + raw.nRecords) = systemTime;
    raw.packetNum(idx + 1: idx + raw.nRecords) = packetNum;
   
    
    rn = 0;%DEG record num is always 0 before
    while (~feof(fid) && rn < raw.nRecords)
        rn = rn + 1;
        if(raw.chASamples ~= 0)
            ifHdr = fread(fid,raw.rHdrSz,'uint8');
            br = br + raw.rHdrSz;
            raw.chAData(:,idx + rn) = fread(fid,raw.chASamples,'uint16');
            br = br + raw.chASamples * 2;
        end
        if(raw.chBSamples ~= 0)
            vidHdr = fread(fid,raw.rHdrSz,'uint8');
            br = br + raw.rHdrSz;
            raw.chBData(:,idx + rn) = fread(fid,raw.chBSamples,'uint16');
            br = br + raw.chBSamples * 2;
        end
    end
end

fclose(fid);
% Convert to Matlab UTC time for use with datestr
%raw.time=raw.time/86400+datenum('Jan 1 2000'); 
