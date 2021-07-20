%% Run radar collect and process code for CLASI MLML
PulseSelection='long';
%   data_dir = 'C:\Users\casper_admin\Desktop\KodenRadarControl';    
%   cd(data_dir);
fid= RunRadar(PulseSelection)  %this runs the radar with a long or a short pulse.  the input is 
            %"long" for the 1.47 us 400 HZ pulse and "short" for the 250 ns
            %2000 Hz pulse
 pause(5)
            i=1
            while i>0.5;
  data_dir = 'C:\Users\casper_admin\Desktop\RealtimeCode\out\bin';    
  cd(data_dir);
 ! collect.exe &
  pause(2)
  ! processing.exe &
 
 pause(20)
 
 % this is collecting the data in the background for 10 second
 % change header file for a new place to save raw data
 
 !taskkill /IM collect.exe /F
 !taskkill /IM processing.exe /F
 
 data_dir = 'D:\CASPERWESTRadarData\NewTest\test\R_2021.04.28'; 
 cd(data_dir);
% %  filenames = dir(CD);
% % filenames = filenames(3:end);
filenames = dir(data_dir);
startF=2;
endF=2;


% put Processing code here
w=1;
q=0;
for ii=length(filenames)-startF+1
    
%[nonCiPc,cohPc,range,time,Vout] = Processing_CLASI(PulseSelection,data_dir,endF,endF)

decimation_factor = 1;  %5   %decimate data
Fs = 100e6;  %  20e6             %sample frequency
            
           load('testVoltageSet');
            voltage = loadRawData(data_dir,decimation_factor);
            
             voltageTest = loadRawData(data_dir,decimation_factor);            
            samples = size(voltage(1).Storevoltage,1);
            time = (1:samples)*(1/Fs);
            range = (3e8*time)/2;
            vtime=voltageTest.Storevoltage(:,1000);           
            

% put the image code in the processing code so it can update every packtage
% update

if w==1
    
    if q==0
%         figure(1)
%         plot(range,nonCiPc)
        figure(2)
        plot(time,vtime)
        Vout2=Vout;
        nonCiPc2=nonCiPc;
        
    else
% % % %         
% % % %         figure(1)
% % % %         plot(range,nonCiPc,range,nonCiPc5,'--',range,nonCiPc4,':')
% % % %         figure(2)
% % % %         plot(time,Vout,time,Vout,time,Vout5,'--',time,Vout4,':')
% % % %         Vout2=Vout;
% % % %         nonCiPc2=nonCiPc;
% % % %         
% % % %     end
% % % %             w=w+1;
% % % %             
% % % % elseif w==2
% % % %         
% % % %         figure(1)
% % % %         plot(range,nonCiPc,range,nonCiPc2,'--')
% % % %         figure(2)
% % % %         plot(time,Vout,time,Vout,time,Vout2,'--')
% % % %         Vout3=Vout;
% % % %         nonCiPc3=nonCiPc;
% % % %         
% % % %                 w=w+1;
% % % %                 
% % % % elseif w==3
% % % %             
% % % %         figure(1)
% % % %         plot(range,Store_nci,range,nonCiPc3,'--',range,nonCiPc2,':')
% % % %         figure(2)
% % % %         plot(time,Vout,time,Vout,time,Vout3,'--',time,Vout2,':')
% % % %         Vout4=Vout;
% % % %         nonCiPc4=nonCiPc;
% % % %         
% % % %                 w=w+1;
% % % %             
% % % %             else w==4
% % % %                 
% % % %         figure(1)
% % % %         plot(range,Store_nci,range,nonCiPc4,'--',range,nonCiPc3,':',range,nonCiPc2,'--o')
% % % %         figure(2)
% % % %         plot(time,Vout,time,Vout,time,Vout4,'--',time,Vout3,':',time,Vout2,'--o')
% % % %         Vout5=Vout;
% % % %         nonCiPc5=nonCiPc;
% % % %                 
% % % %    w=1;
% % % %    q=1;
% % % % end
% % % % endF=endF+1;


%     Store_nci(:,ii) = nci_pow;
%     Store_coh(:,ii) = coh_pow;
%     Store_offset(:,ii) = matchOffset;
%     Store_vel(:,ii) = MNVel;
%     Store_mag(:,ii) = Mag;
    Store_nciPc(:,ii) = nonCiPc;
    Store_cohPc(:,ii) = cohPc;
%     Store_cohNoise(:,ii) = MNpowNoise_coh;
%     Store_nciNoise(:,ii) = MNpowNoise_nci;
%     Store_maxFreq(:,ii) = maxFreq;
%     Store_Energy(:,ii)  = Energy;


end
 data_dir = 'D:\CASPERWESTRadarData\NewTest\test\R_2021.04.28'; 
 cd(data_dir);
!del /q *.* 
%deletes the folder
            end
[out4] = setTransmissionOff(fid);
fclose(fid)            
