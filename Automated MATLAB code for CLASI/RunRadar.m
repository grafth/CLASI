function [fid]=RunRadar(PulseSel)

%   data_dir = 'C:\Users\casper_admin\Desktop\KodenRadarControl';    
%   cd(data_dir);

if PulseSel=="long";
    range_nm=96;
else
    PulseSel=="short";
  range_nm=1;  
end

addpath(genpath('./'));
fid=fopen('Log File.txt');

% turning on and pausing for 3 minutes
% if no pause, then you can burn magnetron!!!
[outstat] = getStatus(fid);
disp(outstat)
[out] = setTurningPowerOn(fid); pause(200);%this has to be done to protect the magnetron

% disp(out)
% 
% [out] = getWarmupTime(fid);
% 
% [out] = getWarmupComplete(fid);
% % while out.status==0
% %     pause(50);
% % [out] = getWarmupComplete(fid);
% % 
% % end 




mode='normal';%allows us to send out one pulse width, d1 and d2 is for two different alt. opperational modes
pwStr   = 'short';%'short';%
[out] = setPulseWidth(pwStr, fid)
[out2] = setOperationalRange(range_nm, mode, fid);

[outstat] = getStatus(fid);
%%
disp(outstat.Range_Id_1)
disp(outstat.Range_Id_2)
disp(outstat.Pulse_Width_1)
disp(outstat.Pulse_Width_2)
[out3,dt] = setTransmissionOnNoMotor(fid)



end