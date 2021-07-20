function [P_inc,noiseAvg] = RFI_inc_MEAN(Power,nRFI,RFI_cut_amplitude,startIndexNoise,stopIndexNoise,PPIflag)

%% RFI Section

xs  = ceil(nRFI/2);
%P = Power;
for kk = 1:length(Power)
    
    xe  = size(Power(kk).Storepower,2)-ceil(nRFI/2);
    for jj = 1:xs-1
        dummy = Power(kk).Storepower(:,jj);
        Pavg = mean(Power(kk).Storepower(:,1:nRFI),2,'omitnan');
        RFI_flag = dummy>RFI_cut_amplitude*Pavg;
  
        Power(kk).Storepower(RFI_flag,jj) = 0;
        noiseAvg(jj) = mean(Power(kk).Storepower(startIndexNoise:stopIndexNoise,jj),1,'omitnan');
    end
    
    for jj = xs:xe
        dummy = Power(kk).Storepower(:,jj);
        Pavg = mean(Power(kk).Storepower(:,jj-floor(nRFI/2):jj+floor(nRFI/2)),2,'omitnan');
        RFI_flag = dummy>RFI_cut_amplitude*Pavg;
        
        Power(kk).Storepower(RFI_flag,jj) = 0;
        noiseAvg(jj) = mean(Power(kk).Storepower(startIndexNoise:stopIndexNoise,jj),1,'omitnan');
    end
    
    for jj = xe+1:size(Power(kk).Storepower,2)
        dummy = Power(kk).Storepower(:,jj);
        Pavg = mean(Power(kk).Storepower(:,xe:end),2,'omitnan');
        RFI_flag = dummy>RFI_cut_amplitude*Pavg;
        
        Power(kk).Storepower(RFI_flag,jj) = 0;
        noiseAvg(jj) = mean(Power(kk).Storepower(startIndexNoise:stopIndexNoise,jj),1,'omitnan');
    end
    if PPIflag == 1
        P_inc = Power(kk).Storepower;
    else
    P_inc(:,kk) = mean(Power(kk).Storepower,2,'omitnan');
    end
end

