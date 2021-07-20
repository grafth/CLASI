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
fid= RunRadar(PulseSelection)  %this runs the radar with a long or a short pulse.  the input is
%"long" for the 1.47 us 400 HZ pulse and "short" for the 250 ns
%2000 Hz pulse
pause(1800) %30 mins to get the antenna warmed up before collection
i=1;


while true
% while i
data_dir = 'C:\Users\casper_admin\Desktop\RealtimeCode\out\bin';
cd(data_dir);
if PulseSelection=="long"
            
            ! Collect_LongPulse.exe | taskkill /F /IM cmd.exe &
            pause(2)
            ! processing.exe | taskkill /F /IM cmd.exe &
            pause(300)
            % this is collecting the data in the background for 10 second
            % change header file for a new place to save raw data
            
            !taskkill /IM Collect_LongPulse.exe /F
            !taskkill /IM processing.exe /F
            !exit
        else
            
            ! Collect_ShortPulse.exe | taskkill /F /IM cmd.exe &
            pause(1)
            ! processing.exe | taskkill /F /IM cmd.exe &
            pause(10)
            % this is collecting the data in the background for 10 second
            % change header file for a new place to save raw data
            
            !taskkill /IM Collect_ShortPulse.exe /F
            !taskkill /IM processing.exe /F
            !exit
end
pause (1800)
end
%% keep track of the days
if PulseSelection=="long"
data_day_dir = ('E:\CLASILongData');    
else
data_day_dir = ('E:\CLASIShortData');
end
cd(data_day_dir);
filenamesday = dir(data_day_dir);
%%
data_dir = [filenamesday(end).folder ,'/', filenamesday(end).name]%'D:\CASPERWESTRadarData\NewTest\test\final\R_2021.06.04';
cd(data_dir);
filenames = dir(data_dir);
startF=3;



% put Processing code here

    for ii=startF:length(filenames)
        cd(data_dir);
[Store_nci,Store_nciNoise,Store_coh,Store_cohNoise,Store_offset,range,time] = Processing_CLASI_2_Channel(PulseSelection,data_dir,ii);
        dirsave=[filenamesday(end).folder ,'/', filenamesday(end).date ,'/', 'SAVE'];
    cd(dirsave);
    save([filenames(ii).name(3:21) '.mat'],'Store_nci','Store_nciNoise','Store_coh','Store_cohNoise','Store_offset','range','time');
    end
% put the image code in the processing code so it can update every packtage
% update




if deleteRawFile == 0
    if SaveAllFiles==0
    dirsave=[filenamesday(end).folder ,'/', filenamesday(end).name ,'/', 'SAVERAW'];
for i=startF:length(filenames)
    cd(data_dir);
copyfile (filenames(i+2).name,dirsave)
end
    else
dirsave=[filenamesday(end).folder ,'/', filenamesday(end).name ,'/', 'SAVERAW'];
for i=1:SaveRawDataSizePer2Hr
cd(data_dir);
    copyfile (filenames(i+2).name,dirsave)
end
    end
cd(data_dir);

!del /q *.*
    %deletes the folder
else
cd(data_dir);

!del /q *.*
    %deletes the folde    
end
[out4] = setTransmissionOff(fid);
fclose(fid)
