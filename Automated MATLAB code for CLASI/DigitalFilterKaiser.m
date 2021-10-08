function [df3,MaxFreqCheck]=DigitalFilterKaiser(Voltage,Freq,PulseSelection)
% this function is for the CLASI EXP. for digital filtering
%used for both long and short pulse

%initalizing vectors
DF3 = zeros(size(Voltage,1),1);
 
% used to find the peak for the whole 10 sec. interval (CPI) this should be
% sufficient because the freq should not move in the 10 sec
VFreq4OnePulse = fftshift(fft(ifftshift(Voltage(:,1))));

[PowerVal,FreqIndex]=(max(abs(VFreq4OnePulse(Freq>10e3 & Freq<Freq(end-3000)))));
% looking at the positive freq, and finding the peak only works for freq in
% Hz
% there could be a spike at DC so it starts at 0.5 to only capure the max
% that is wanted

FreqMaxIndex=length(Freq)/2+FreqIndex; % adding the neg freq and DC back to the index for shifting 

if PulseSelection=="long"

if (1.5e6 < Freq(FreqMaxIndex)) && (Freq(FreqMaxIndex) < 6e6)

else
FreqMaxIndex=12289;    
end
else PulseSelection=="short"
    
if (20e6 < Freq(FreqMaxIndex)) && (Freq(FreqMaxIndex) < 28e6)
else
    FreqMaxIndex=12289;    
end   

end

MaxFreqCheck=Freq(FreqMaxIndex);% to make sure the peak is around where it is supposed to be

VoltFreq = fftshift(fft(ifftshift(Voltage)));

% constructing the filter
i2 = find(abs(abs(Freq)-Freq(FreqMaxIndex))== min(abs(abs(Freq)-Freq(FreqMaxIndex))));
kl = 5400;%length of the filter may consider revising will work for short and long pulse
DF3((i2(1)-kl/2):(i2(1)+kl/2-1),1) = kaiser(kl,5)';
if (length(Freq)/2)-(i2(2)-kl/2)>0
DF3=[DF3(1:length(Freq)/2) ; flip(DF3(1:length(Freq)/2))];   
else
DF3((i2(2)-kl/2):(i2(2)+kl/2-1)) = kaiser(kl,5);
end
DF3=repmat(DF3,1,size(Voltage,2)); %making a matrix for all the pulses in the CPI
df3 = real(fftshift((ifft(ifftshift(DF3.*VoltFreq)))));%DEG ask caglar if i can do this
end