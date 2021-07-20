%% Run radar collect and process code for CLASI MLML
PulseSelection='long';
SaveRawDataSizePer2Hr=30;
deleteRawFile=1; %if 1 delete if 0 keep
SaveAllFiles=1;  %if 1 delete if 0 keep

%% inital dir setup
%addpath('C:\Users\palmore.19\Desktop\Automated MATLAB code for CLASI')
addpath('C:\Users\palmore.19\Documents\GitHub\CLASI\Automated MATLAB code for CLASI')


data_dir = 'E:\CLASI_Save folder\R_2021.07.10'%'E:\June_23_test\R_2021.06.23' %'D:\CASPERWESTRadarData\NewTest\test\final\R_2021.06.04';
cd(data_dir);
filenames = dir(data_dir);
startF=3;



% put Processing code here

    for ii=startF:length(filenames)
        cd(data_dir);
[Store_nci,Store_nciNoise,Store_coh,Store_cohNoise,Store_offset,Velocity,range,time] = Processing_CLASI_2_Channel(PulseSelection,data_dir,ii);
        dirsave='E:\CLASI_Save folder\SAVE 2';
    cd(dirsave);
    save([filenames(ii).name(3:21) '.mat'],'Store_nci','Store_nciNoise','Store_coh','Store_cohNoise','Store_offset','range','time');
    end
% put the image code in the processing code so it can update every packtage
% update




%fclose(fid)
