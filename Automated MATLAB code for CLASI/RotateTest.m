%% Run radar collect and process code for CLASI MLML
clear;
clc;
%while true
    
    PulseSelection='long';
    RecordingTime=10; %the time interval it takes for
    SaveRawDataSizePer2Hr=30;
    deleteRawFile=1; %if 1 delete if 0 keep
    SaveAllFiles=1;  %if 1 delete if 0 keep
    
    startAzAngle=46.3; % the hard limit is 105 %has to be less than stop for reverse, change indexing from end to start
    stopAzAngle=46.3;   %the hard limit is the bouy is written down somewhere between 46 and 48
    incAzAngle=0.1;
    
    startElAngle=67.0;
    stopElAngle=65.5;
    
    %% calc angle for rotor
    
    
    Az=startAzAngle:incAzAngle:stopAzAngle;
    ElL=startElAngle:-1*incAzAngle:stopElAngle;
    El=linspace(startElAngle,stopElAngle,length(ElL));
    
    Az2=stopAzAngle:incAzAngle:startAzAngle;
    %Az=[Az1 Az2(2:end)];
    
    
    El2=linspace(stopElAngle,startElAngle,length(El));
    El=[El El2(2:end)];
    AzDegree=zeros(size(Az,1),size(Az,2));
    ElDegree=zeros(size(El,1),size(El,2));
    
    %% inital dir setup
    addpath('C:\Users\casper_admin\Desktop\Automated MATLAB code for CLASI')
    data_dir = 'C:\Users\casper_admin\Desktop\KodenRadarControl';
    cd(data_dir);
    
    %% runing radar
     fid= RunRadar(PulseSelection)  %this runs the radar with a long or a short pulse.  the input is
    % %"long" for the 1.47 us 400 HZ pulse and "short" for the 250 ns
    % %2000 Hz pulse
    
     [AzDegree(1),ElDegree(1)]=SingleAngleRotate(Az(1),El(1));
    pause(60) %30 mins to get the antenna warmed up before collection
    % i=1;
    
    
    
     while true
    for i=2:length(El)+1
        data_dir = 'C:\Users\casper_admin\Desktop\RealtimeCode\out\bin';
        cd(data_dir);
        
        if PulseSelection=="long"
            
            ! Collect_LongPulse.exe | taskkill /F /IM cmd.exe&
            %| taskkill /F /IM cmd.exe &
            pause(2)
            ! processing.exe | taskkill /F /IM cmd.exe&
            %| taskkill /F /IM cmd.exe &
            pause(60)
            % this is collecting the data in the background for 10 second
            % change header file for a new place to save raw data
            
            !taskkill /IM Collect_LongPulse.exe /F
            !taskkill /IM processing.exe /F
            !exit
        else
            
            ! Collect_ShortPulse.exe | taskkill /F /IM cmd.exe &
            pause(2)
            ! processing.exe | taskkill /F /IM cmd.exe &
            pause(60)
            % this is collecting the data in the background for 10 second
            % change header file for a new place to save raw data
            
            !taskkill /IM Collect_ShortPulse.exe /F
            !taskkill /IM processing.exe /F
            !exit
        end
        Time(i-1)=datetime;
        
        if i > length(El)
            
        else
            [AzDegree(i),ElDegree(i)]=SingleAngleRotate(Az(1),El(i));
            pause(1)
        end
        
        %% keep track of the days
        
        data_day_dir = ('G:\CLASI_Long_Pulse');
        
        cd(data_day_dir);
        filenamesday = dir(data_day_dir);
        %%
        data_dir = [filenamesday(end).folder ,'\', filenamesday(end).name]%'D:\CASPERWESTRadarData\NewTest\test\final\R_2021.06.04';
        cd(data_dir);
        filenames = dir(data_dir);
        startF=3; %because the files start at 3
        
        
        % put Processing code here
        
    end
            data_day_dir = ('G:\CLASI_Long_Pulse');
        
        cd(data_day_dir);
    save(['G:\CLASI_Long_Pulse.', filenames(end).name, '.mat'],'AzDegree','ElDegree','Time')
    pause (1800)
end
% [out4] = setTransmissionOff(fid);
% fclose(fid)
