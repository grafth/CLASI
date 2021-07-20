function [out] = getStatus(fid)

out     = [];
out.err = '';

if(nargin == 0 || fid == -1)
    fid = 1;
end

% Command
cmd     = ['26'; '9A'; '11'; '0D'];

% Send command
udpObj  = udpSetup;
sendUDPData(udpObj,cmd);

% Receive Data
rxLen   = 68;
dt      = receiveUDPData(udpObj,cmd);
udpClose(udpObj);
if(isempty(dt))
    err     = sprintf('[ERROR] [getStatus] Invalid UDP data');
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end

% Check received data
if(size(dt,1) ~= rxLen)
    err     = sprintf('[ERROR] [getStatus] Invalid received data length. Expected %d, Received %d', rxLen,size(dt,1));
    fprintf(fid,[err '\n']);
    out.err = err;
    return;
end

%% 3) Sensor Status
dt1     = dec2bin(hex2dec(dt(3,:)),8);
out.Sensor_Status.D0.val        = str2double(dt1(8));
if(out.Sensor_Status.D0.val)
    out.Sensor_Status.D0.str    = 'Stand by';
else
    out.Sensor_Status.D0.str    = 'Warm up';
end

out.Sensor_Status.D1.val        = str2double(dt1(7));
if(out.Sensor_Status.D1.val)
    out.Sensor_Status.D1.str    = 'Radar image sent';
else
    out.Sensor_Status.D1.str    = 'Radar image not sent';
end

out.Sensor_Status.D2.val        = str2double(dt1(6));
if(out.Sensor_Status.D2.val)
    out.Sensor_Status.D2.str    = '480 x 480';
else
    out.Sensor_Status.D2.str    = '240 x 240';
end

out.Sensor_Status.D3.val        = str2double(dt1(5));
if(out.Sensor_Status.D3.val)
    out.Sensor_Status.D3.str    = 'Real time transfer mode';
else
    out.Sensor_Status.D3.str    = 'Full or quadrant screen mode';
end

out.Sensor_Status.D4.val        = str2double(dt1(4));
if(out.Sensor_Status.D4.val)
    out.Sensor_Status.D4.str    = 'Full screen mode';
else
    out.Sensor_Status.D4.str    = 'Image data transfer every quadrant mode';
end

out.Sensor_Status.D5.val        = str2double(dt1(3));
out.Sensor_Status.D5.str        = '';

out.Sensor_Status.D6.val        = str2double(dt1(2));
out.Sensor_Status.D6.str        = '';

out.Sensor_Status.D7.val        = str2double(dt1(1));
out.Sensor_Status.D7.str        = '';

%% 4) System Error
dt1     = dec2bin(hex2dec(dt(4,:)),8);
out.System_Error.D0.val         = str2double(dt1(8));
if(out.System_Error.D0.val)
    out.System_Error.D0.str     = 'ROM Error';
else
    out.System_Error.D0.str     = '';
end

out.System_Error.D1.val         = str2double(dt1(7));
if(out.System_Error.D1.val)
    out.System_Error.D1.str     = 'RAM Error';
else
    out.System_Error.D1.str     = '';
end

out.System_Error.D2.val         = str2double(dt1(6));
if(out.System_Error.D2.val)
    out.System_Error.D2.str     = 'VRAM Error';
else
    out.System_Error.D2.str     = '';
end

out.System_Error.D3.val         = str2double(dt1(5));
if(out.System_Error.D3.val)
    out.System_Error.D3.str     = 'ATA Error';
else
    out.System_Error.D3.str     = '';
end

out.System_Error.D4.val         = str2double(dt1(4));
if(out.System_Error.D4.val)
    out.System_Error.D4.str     = 'DHCP Server Error';
else
    out.System_Error.D4.str     = '';
end

out.System_Error.D5.val         = str2double(dt1(3));
out.System_Error.D5.str        	= '';

out.System_Error.D6.val         = str2double(dt1(2));
out.System_Error.D6.str         = '';

out.System_Error.D7.val         = str2double(dt1(1));
out.System_Error.D7.str         = '';

%% 5) Image error
dt1     = dec2bin(hex2dec(dt(5,:)),8);
out.Image_Error.D0.val          = str2double(dt1(8));
if(out.Image_Error.D0.val)
    out.Image_Error.D0.str      = 'AZI Error';
else
    out.Image_Error.D0.str      = '';
end

out.Image_Error.D1.val          = str2double(dt1(7));
if(out.Image_Error.D1.val)
    out.Image_Error.D1.str      = 'SHF Error (not use)';
else
    out.Image_Error.D1.str      = '';
end

out.Image_Error.D2.val          = str2double(dt1(6));
if(out.Image_Error.D2.val)
    out.Image_Error.D2.str      = 'PRF Error';
else
    out.Image_Error.D2.str      = '';
end

out.Image_Error.D3.val          = str2double(dt1(5));
if(out.Image_Error.D3.val)
    out.Image_Error.D3.str      = 'System Error';
else
    out.Image_Error.D3.str      = '';
end

out.Image_Error.D4.val          = str2double(dt1(4));
if(out.Image_Error.D4.val)
    out.Image_Error.D4.str      = 'Magnetron Electric Current Error';
else
    out.Image_Error.D4.str      = '';
end

out.Image_Error.D5.val          = str2double(dt1(3));
if(out.Image_Error.D5.val)
    out.Image_Error.D5.str      = 'Magnetron Heater Current Error';
else
    out.Image_Error.D5.str      = '';
end

out.Image_Error.D6.val          = str2double(dt1(2));
if(out.Image_Error.D6.val)
    out.Image_Error.D6.str      = 'High Voltage (250VDC) Error';
else
    out.Image_Error.D6.str      = '';
end

out.Image_Error.D7.val          = str2double(dt1(1));
out.Image_Error.D7.str          = '';

%% 6) Tune Mode
dt1     = hex2dec(dt(6,:));
out.Tune_Mode.val               = dt1;
if(out.Tune_Mode.val == 1)
    out.Tune_Mode.str           = 'Manual Tune';
else
    out.Tune_Mode.str           = 'Auto Tune';
end

%% 7) Trigger Delay Setting Value
dt1     = hex2dec(dt(7,:));
out.Trigger_Delay.val           = dt1;
out.Trigger_Delay.str           = '';

%% 8-9) Heading line Setting Value
dt1     = hex2dec([dt(8,:) dt(9,:)]);
out.Heading_Line.val           = dt1;
out.Heading_Line.str           = '';

%% 10) Trail Setting Value
dt1     = dt(10,:);
out.Trail_Setting.val           = hex2dec(dt1);
if(strcmp(dt1,'00'))
    out.Trail_Setting.str       = 'Off';
elseif(strcmp(dt1,'FF'))
    out.Trail_Setting.str       = 'Continuous';
elseif(strcmp(dt1,'0F'))
    out.Trail_Setting.str       = '15 Seconds';    
elseif(strcmp(dt1,'1E'))
    out.Trail_Setting.str       = '30 Seconds';
elseif(strcmp(dt1,'01'))
    out.Trail_Setting.str       = '1 Minute';
elseif(strcmp(dt1,'03'))
    out.Trail_Setting.str       = '3 Minutes';
elseif(strcmp(dt1,'06'))
    out.Trail_Setting.str       = '6 Minutes';
elseif(strcmp(dt1,'F0'))
    out.Trail_Setting.str       = 'Continuous (3 frames)';
elseif(strcmp(dt1,'8F'))
    out.Trail_Setting.str       = '15 Seconds (3 frames)';
elseif(strcmp(dt1,'9E'))
    out.Trail_Setting.str       = '30 Seconds (3 frames)';
elseif(strcmp(dt1,'81'))
    out.Trail_Setting.str       = '1 Minute (3 frames)';
elseif(strcmp(dt1,'83'))
    out.Trail_Setting.str       = '3 Minutes (3 frames)';
elseif(strcmp(dt1,'86'))
    out.Trail_Setting.str       = '6 Minutes (3 frames)';
end

%% 11-12) Off center X offset
dt1     = hex2dec([dt(11,:) dt(12,:)]);
out.X_Offset.val                = dt1;
out.X_offset.str                = '';

%% 13-14) Off center Y offset
dt1     = hex2dec([dt(13,:) dt(14,:)]);
out.Y_Offset.val                = dt1;
out.Y_offset.str                = '';

%% 15) No.1 Range Identification
dt1     = hex2dec(dt(15,:));
out.Range_Id_1.val              = dt1;
out.Range_Id_1.str              = '';

%% 16) No.2 Range Identification
dt1     = hex2dec(dt(16,:));
out.Range_Id_2.val              = dt1;
out.Range_Id_2.str              = '';

%% 17) No.1 Pulse width
dt1     = hex2dec(dt(17,:));
out.Pulse_Width_1.val           = dt1;
out.Pulse_Width_1.str           = '';

%% 18) No.2 Pulse width
dt1     = hex2dec(dt(18,:));
out.Pulse_Width_2.val           = dt1;
out.Pulse_Width_2.str           = '';

%% 19) Gain Mode
dt1     = hex2dec(dt(19,:));
out.Gain_Mode.val               = dt1;
out.Gain_Mode.str               = '';

%% 20) No.1 Range Gain
dt1     = hex2dec(dt(20,:));
out.Range_Gain_1.val            = dt1;
out.Range_Gain_1.str            = '';

%% 21) No.2 Range Gain
dt1     = hex2dec(dt(21,:));
out.Range_Gain_2.val            = dt1;
out.Range_Gain_2.str            = '';

%% 22) FTC Mode
dt1     = hex2dec(dt(22,:));
out.FTC_Mode.val                = dt1;
out.FTC_Mode.str                = '';

%% 23) No.1 Range FTC
dt1     = hex2dec(dt(23,:));
out.Range_FTC_1.val             = dt1;
out.Range_FTC_1.str             = '';

%% 24) No.2 Range FTC
dt1     = hex2dec(dt(24,:));
out.Range_FTC_2.val             = dt1;
out.Range_FTC_2.str             = '';

%% 25) STC Mode
dt1     = hex2dec(dt(25,:));
out.STC_Mode.val                = dt1;
out.STC_Mode.str                = '';

%% 26) No.1 Range STC
dt1     = hex2dec(dt(26,:));
out.Range_STC_1.val             = dt1;
out.Range_STC_1.str             = '';

%% 27) No.2 Range STC
dt1     = hex2dec(dt(27,:));
out.Range_STC_2.val             = dt1;
out.Range_STC_2.str             = '';

%% 28) IR
dt1     = hex2dec(dt(28,:));
out.IR.val                      = dt1;
out.IR.str                      = '';

%% 29) EXP Mode
dt1     = hex2dec(dt(29,:));
out.EXP.val                     = dt1;
out.EXP.str                     = '';

%% 30) Radar Image Mode
dt1     = hex2dec(dt(30,:));
out.Radar_Image_Mode.val        = dt1;
out.Radar_Image_Mode.str        = '';

%% 31-32) Head Line Bearing
dt1     = hex2dec([dt(31,:) dt(32,:)]);
out.Head_Line_Bearing.val       = dt1;
out.Head_Line_Bearing.str       = '';

%% 33-34) Tuning
dt1     = hex2dec([dt(33,:) dt(34,:)]);
out.Tuning.val                  = dt1;
out.Tuning.str                  = '';

%% 35-36) Intermittent Transfer
dt1     = hex2dec([dt(35,:) dt(36,:)]);
out.Intermittent_Transfer.val   = dt1;
out.Intermittent_Transfer.str   = '';

%% 37-56) ATA
for ii=37:1:56
    if(ii == 37)
        dt1     = dt(ii,:);
    else
        dt1     = [dt1 dt(ii,:)];
    end
end
out.ATA.val                     = dt1;
out.ATA.str                     = 'Reservations';

%% 57) Auto Gain Preset
dt1     = hex2dec(dt(57,:));
out.Auto_Gain_Preset.val        = dt1;
out.Auto_Gain_Preset.str        = '';

%% 58) Manual Gain Preset
dt1     = hex2dec(dt(58,:));
out.Manual_Gain_Preset.val      = dt1;
out.Manual_Gain_Preset.str      = '';

%% 59) Auto STC Preset
dt1     = hex2dec(dt(59,:));
out.Auto_STC_Preset.val         = dt1;
out.Auto_STC_Preset.str         = '';

%% 60) Manual STC Preset
dt1     = hex2dec(dt(60,:));
out.Manual_STC_Preset.val       = dt1;
out.Manual_STC_Preset.str       = '';

%% 61) Auto Tune Preset
dt1     = hex2dec(dt(61,:));
out.Auto_Tune_Preset.val        = dt1;
out.Auto_Tune_Preset.str        = '';

%% 62) Manual Tune Preset
dt1     = hex2dec(dt(62,:));
out.Manual_Tune_Preset.val      = dt1;
out.Manual_Tune_Preset.str      = '';

%% 63) Harbor STC Preset
dt1     = hex2dec(dt(63,:));
out.Harbor_STC_Preset.val       = dt1;
out.Harbor_STC_Preset.str       = '';

%% 64) STC Curve Preset
dt1     = hex2dec(dt(64,:));
out.STC_Curve_Preset.val        = dt1;
out.STC_Curve_Preset.str        = '';

%% 65) Antenna Rotation Speed
dt1     = hex2dec(dt(65,:));
out.Antenna_Rotation_Speed.val  = dt1;
out.Antenna_Rotation_Speed.str  = '';

%% 66-67) Antenna Parking Position
dt1     = hex2dec([dt(66,:) dt(67,:)]);
out.Antenna_Parking_Position.val= dt1;
out.Antenna_Parking_Position.str= '';

end