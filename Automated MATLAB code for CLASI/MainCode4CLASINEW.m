%% Run radar collect and process code for CLASI MLML
 PulseSelection='long';
  data_dir = 'C:\Users\casper_admin\Desktop\KodenRadarControl';
  cd(data_dir);
fid= RunRadar(PulseSelection)  %this runs the radar with a long or a short pulse.  the input is
%"long" for the 1.47 us 400 HZ pulse and "short" for the 250 ns
%2000 Hz pulse
pause(18) %30 mins to get the antenna warmed up before collection
i=1;
% while i
    data_dir = 'C:\Users\casper_admin\Desktop\RealtimeCode\out\bin';
    cd(data_dir);
    ! collect.exe &
    pause(2)
    ! processing.exe &
    
    pause(10)
    
    % this is collecting the data in the background for 10 second
    % change header file for a new place to save raw data
    
    !taskkill /IM collect.exe /F
    !taskkill /IM processing.exe /F
    
    data_dir = 'D:\CASPERWESTRadarData\NewTest\test\final\R_2021.05.29';
    cd(data_dir);
    % %  filenames = dir(CD);
    % % filenames = filenames(3:end);
    filenames = dir(data_dir);
    startF=2;
    endF=2;
    
    
    % put Processing code here
    w=1;
    q=0;
    for ii=startF+2:length(filenames)-1
        
        [Store_nci,Store_nciNoise,Store_coh,Store_cohNoise,Store_offset,range,time] = Processing_CLASI(PulseSelection,data_dir,endF,endF);
        
        % put the image code in the processing code so it can update every packtage
        % update
        
        if w==1
            
            if q==0
                figure(1)
                plot(range,nonCiPc)
                legend('1 noncoh')
                figure(2)
                plot(time,Vout(:,10))
                legend('1 V')
                Vout2=Vout;
                nonCiPc2=nonCiPc;
            
            Vfreq=fftshift(10*log10( (abs(fft(Vout(:,1000))).^2)/(sqrt(2)^2*50) )+30);
            NFFT = size(Vout,1);
            freq = (-NFFT/2+1:1:NFFT/2)/NFFT*20e6/1e6;
            figure(3)
            plot(freq,Vfreq)
            
            else
                
                figure(1)
                plot(range,nonCiPc,range,nonCiPc5,'--',range,nonCiPc4,':')
                legend('1 noncoh','2 noncoh','3 noncoh')
                figure(2)
                plot(time,Vout(:,10),time,Vout5(:,10),'--',time,Vout4(:,10),':')
                  legend('1 V','2 V','3 V')
                Vout2=Vout;
                nonCiPc2=nonCiPc;
                
            end
            w=w+1;
            
        elseif w==2
            
            figure(1)
            plot(range,nonCiPc,range,nonCiPc2,'--')
            legend('1 noncoh','2 noncoh')
            figure(2)
            plot(time,Vout(:,10),time,Vout2(:,10),'--')
                 legend('1 V','2 V')
            Vout3=Vout;
            nonCiPc3=nonCiPc;
           

            w=w+1;
            
        elseif w==3
            
            figure(1)
            plot(range,nonCiPc,range,nonCiPc3,'--',range,nonCiPc2,':')
            legend('1 noncoh','2 noncoh','3 noncoh')
            figure(2)
            plot(time,Vout(:,10),time,Vout3(:,10),'--',time,Vout2(:,10),':')
                 legend('1 V','2 V','3 V')
            Vout4=Vout;
            nonCiPc4=nonCiPc;
            
            w=w+1;
            
        else w==4
            
            figure(1)
            plot(range,nonCiPc,range,nonCiPc4,'--',range,nonCiPc3,':',range,nonCiPc2,'--o')
            legend('1 noncoh','2 noncoh','3 noncoh','4 noncoh')
            figure(2)
            plot(time,Vout(:,10),time,Vout4(:,10),'--',time,Vout3(:,10),':',time,Vout2(:,10),'--o')
                  legend('1 V','2 V','3 V','4 V')
            Vout5=Vout;
            nonCiPc5=nonCiPc;
            
            w=1;
            q=1;
        end
        endF=endF+1;
        
        
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
    data_dir = 'D:\CASPERWESTRadarData\NewTest\test\final\R_2021.05.20';
    cd(data_dir);
    !del /q *.*
    %deletes the folder
 %end
[out4] = setTransmissionOff(fid);
fclose(fid)
