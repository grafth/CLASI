%% Run radar collect and process code for CLASI MLML
PulseSelection='long';
BiasAvg='long';
SaveRawDataSizePer2Hr=30;
deleteRawFile=1; %if 1 delete if 0 keep
SaveAllFiles=1;  %if 1 delete if 0 keep

%% inital dir setup
%addpath('C:\Users\palmore.19\Desktop\Automated MATLAB code for CLASI')
addpath('C:\Users\palmore.19\Documents\GitHub\CLASI\Automated MATLAB code for CLASI')


data_dir ='F:\CLASI_Monterey\single files\longerbias\long\R_2021.10.04'%F:\CLASI_Monterey\single files\shortpulsedata8272021\R_2021.08.27' %'F:\CLASI_Monterey\single files\R_2021.08.21' %'F:\CLASI_Monterey\single files'%'E:\June_23_test\R_2021.06.23' %'D:\CASPERWESTRadarData\NewTest\test\final\R_2021.06.04';
cd(data_dir);
filenames = dir(data_dir);
startF=3%212%3;%22
%2070


%% put Processing code here 512%

    for ii=startF:length(filenames)
        cd(data_dir);
[Store_nci,Store_nciNoise,Store_coh,Store_cohNoise,Store_offset,Velocity,range,time] = Processing_CLASI_2_Channel(PulseSelection,BiasAvg,data_dir,ii);
        dirsave='F:\CLASI_Monterey\Radar_data_100524';
    cd(dirsave);
    save([filenames(ii).name(3:21) '.mat'],'Store_nci','Store_nciNoise','Store_coh','Store_cohNoise','Store_offset','Velocity','range','time');
    end
% put the image code in the processing code so it can update every packtage
% update




%fclose(fid)
