%% Run radar collect and process code for CLASI MLML
PulseSelection='long';
SaveRawDataSizePer2Hr=30;
deleteRawFile=1; %if 1 delete if 0 keep
SaveAllFiles=1;  %if 1 delete if 0 keep

%% inital dir setup
addpath('C:\Users\casper_admin\Desktop\Automated MATLAB code for CLASI')
data_dir = 'C:\Users\casper_admin\Desktop\KodenRadarControl';
cd(data_dir);

%% runing radar
% fid= RunRadar(PulseSelection)  %this runs the radar with a long or a short pulse.  the input is
% %"long" for the 1.47 us 400 HZ pulse and "short" for the 250 ns
% %2000 Hz pulse
% pause(18) %30 mins to get the antenna warmed up before collection
% i=1;



 while true
data_dir = 'C:\Users\casper_admin\Desktop\RealtimeCode\out\bin';
cd(data_dir);
if PulseSelection=="long"
            
            ! Collect_LongPulse.exe | taskkill /F /IM cmd.exe &
            pause(2)
            ! processing.exe | taskkill /F /IM cmd.exe &
            pause(600)
            % this is collecting the data in the background for 10 second
            % change header file for a new place to save raw data
            
            !taskkill /IM Collect_LongPulse.exe /F
            !taskkill /IM processing.exe /F
            !exit
        else
            
            ! Collect_ShortPulse.exe | taskkill /F /IM cmd.exe &
            pause(1)
            ! processing.exe | taskkill /F /IM cmd.exe &
            pause(5)
            % this is collecting the data in the background for 10 second
            % change header file for a new place to save raw data
            
            !taskkill /IM Collect_ShortPulse.exe /F
            !taskkill /IM processing.exe /F
            !exit
end
        pause(600*5)
 end