function [VFilt]=DigitalFilter(Voltage,Freq,Pulse_selection)
Vfreq=fftshift(abs(fft(Voltage(:,1))));
Freq(round(length(Freq)/2)+1)=0;
[Freqmax,FreqIndex]=(max(abs(Vfreq(Freq>0. & Freq<Freq(end)))));

FreqDiv=round(length(Freq)./(Freq(end)/1e6-Freq(1)/1e6));
FreqFiltMax=Freq(length(Freq)/2+FreqIndex+FreqDiv*4);
FreqFiltMin=Freq(length(Freq)/2+FreqIndex-FreqDiv*4);

[a,b]=cheby2(4,20,[FreqFiltMin*1e6 FreqFiltMax*1e6]/(Freq(end)*1e6),'bandpass');
[H,W]=freqz(a,b,size(Voltage,1)/2);
DFilter=cat(1,H,H);

DFilter=repmat(DFilter,1,size(Voltage,2));
VFreqFilt=Vfreq.*DFilter;
VFilt=ifft(VFreqFilt);
end