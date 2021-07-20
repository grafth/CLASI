function V = RFI_coh_MED_range(V,nRFI_range,RFI_cut_amplitude)

%% RFI Section
xs  = ceil(nRFI_range/2);

%for kk = 1:length(V)
    
    Power = V.^2/2/50;
    xe  = size(Power,1)-ceil(nRFI_range/2);
    for jj = 1:xs-1
        dummy = Power(jj,:);
        Pavg = median(Power(1:nRFI_range,:),1);
        RFI_flag = dummy>RFI_cut_amplitude*Pavg;
        V(jj,RFI_flag) = 0; 
    end
    
    for jj = xs:xe
        dummy = Power(jj,:);
        Pavg = median(Power(jj-floor(nRFI_range/2):jj+floor(nRFI_range/2),:),1);
        RFI_flag = dummy>RFI_cut_amplitude*Pavg;
        V(jj,RFI_flag) = 0;
    end
    
    for jj = xe+1:size(V,1)
        dummy = Power(jj,:);
        Pavg = median(Power(xe:end,:),1);
        RFI_flag = dummy>RFI_cut_amplitude*Pavg;
        V(jj,RFI_flag) = 0; 
    end
    
%end

