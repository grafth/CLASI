function V = RFI_coh_MED(V,nRFI,RFI_cut_amplitude)

%% RFI Section
xs  = ceil(nRFI/2);


    
    Power = V.^2/2/50;
    xe  = size(Power,2)-ceil(nRFI/2);
    for jj = 1:xs-1
        dummy = Power(:,jj);
        Pavg = median(Power(:,1:nRFI),2);
        RFI_flag = dummy>RFI_cut_amplitude*Pavg;
        V(RFI_flag,jj) = 0; 
    end
    
    for jj = xs:xe
        dummy = Power(:,jj);
        Pavg = median(Power(:,jj-floor(nRFI/2):jj+floor(nRFI/2)),2);
        RFI_flag = dummy>RFI_cut_amplitude*Pavg;
        V(RFI_flag,jj) = 0;
    end
    
    for jj = xe+1:size(V,2)
        dummy = Power(:,jj);
        Pavg = median(Power(:,xe:end),2);
        RFI_flag = dummy>RFI_cut_amplitude*Pavg;
        V(RFI_flag,jj) = 0; 
    end
    


