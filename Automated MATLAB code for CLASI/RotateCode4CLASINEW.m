%% Run radar collect and process code for CLASI MLML
PulseSelection='long';
RecordingTime=10; %the time interval it takes for 
SaveRawDataSizePer2Hr=30;
deleteRawFile=1; %if 1 delete if 0 keep
SaveAllFiles=1;  %if 1 delete if 0 keep

 startAzAngle=-2; %has to be less than stop for reverse, change indexing from end to start
 stopAzAngle=2;
 incAzAngle=0.1;
 
 startElAngle=0;
 stopElAngle=0;
 
 %% calc angle for rotor
 
 Az=startAzAngle:incAzAngle:stopAzAngle;
 El=linspace(startElAngle,stopElAngle,length(Az));
 AzDegree=zeros(size(Az,1),size(Az,2));
 ElDegree=zeros(size(El,1),size(El,2));
%% inital dir setup
%addpath('C:\Users\palmore.19\Desktop\Automated MATLAB code for CLASI')
addpath('C:\Users\palmore.19\Documents\GitHub\CLASI\Automated MATLAB code for CLASI')
data_dir = 'C:\Users\casper_admin\Desktop\KodenRadarControl';
cd(data_dir);

%% runing radar
fid= RunRadar(PulseSelection)  %this runs the radar with a long or a short pulse.  the input is
%"long" for the 1.47 us 400 HZ pulse and "short" for the 250 ns
%2000 Hz pulse
[AzDegree(1),ElDegree(1)]=SingleAngleRotate(Az(1),El(1));
pause(18) %30 mins to get the antenna warmed up before collection
i=1;



% while i
for i=2:length(Az)+1
data_dir = 'C:\Users\casper_admin\Desktop\RealtimeCode\out\bin';
cd(data_dir);

if PulseSelection=="long"
    
! Collect_LongPulse.exe &
pause(2)
! processing.exe &
pause(10)
% this is collecting the data in the background for 10 second
% change header file for a new place to save raw data

!taskkill /IM Collect_LongPulse.exe /F
!taskkill /IM processing.exe /F

else
    
    ! Collect_ShortPulse.exe &
pause(1)
! processing.exe &
pause(10)
% this is collecting the data in the background for 10 second
% change header file for a new place to save raw data

!taskkill /IM Collect_ShortPulse.exe /F
!taskkill /IM processing.exe /F

end
if i > length(Az)
    
else
[AzDegree(i),ElDegree(i)]=SingleAngleRotate(Az(i),El(i));
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
data_dir = [filenamesday(end).folder ,'\', filenamesday(end).name]%'D:\CASPERWESTRadarData\NewTest\test\final\R_2021.06.04';
cd(data_dir);
filenames = dir(data_dir);
startF=3; %because the files start at 3



% put Processing code here

    for ii=startF:length(filenames)
        cd(data_dir);
[Store_nci,Store_nciNoise,Store_coh,Store_cohNoise,Store_offset,Vel,range,time] = Processing_CLASI_2_Channel(PulseSelection,data_dir,ii);
        dirsave=[filenamesday(end).folder ,'/', filenamesday(end).date ,'/', 'SAVE'];
    cd(dirsave);
    save([filenames(ii).name(3:21) '.mat'],'Store_nci','Store_nciNoise','Store_coh','Store_cohNoise','Store_offset','Vel','range','time');
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
