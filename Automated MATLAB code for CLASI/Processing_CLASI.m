
function [Store_nci,Store_nciNoise,Store_coh,Store_cohNoise,Store_offset,range,time] = Processing_CLASI(PulseSelection,data_dir,startF,endF)
%% Load Raw Radar Data


%filenames = dir(data_dir);
%filenames = filenames(startF:endF);   %when it's a folder on hard drive
%filenames = filenames(4:end);  %when it's a folder on my macbook

% fin = length(filenames);
% starter = 1:1:length(filenames);
% stopper = 1:1:length(filenames);

%% Define Radar Parameters

StartNoiseIndex=1;                  % To start the noise averageing bins for voltage bias
EndNoiseIndex=30;                   % To end the noise averageing bins for voltage bias
VpeakA=0.8;                          % The voltage rails of the ADC for channel A
VpeakB=0.8;                          % The voltage rails of the ADC for channel B

if PulseSelection=="long";
    decimation_factor = 1;          % Data collected at 100 MHz, decimate to 20 MHz
    Fs = 20e6;%20e6;                      % Sample Frequency (Hz)
    BW = 4e6;                       % Hardware Bandwidth (Hz)
    tau = 1.67e-6;
    PWindex = ceil(tau*Fs);     % Pulse width sample index
    numcohPulse = 4;                % Number of coherent pulse to be grouped together (function of the sea state, see sea state function)
    c = 299792458;                  % Speed of light (m/s)
    fc = 9.41e9;                    % Carrier frequency (Hz)
    PRI = 2.5e-3;                   % Pulse repetition index (s)
    lambda = c/fc;                  % Wavelength (m)
    PPIflag = 0;                    % Flag to indicate plan position indicator map processing mode
    noiseStart = 100e3;             %  noise range in m
    noiseStop = 115e3;              % noise range in m
    signalEnd = 16000;
    PRF = 400;
    numPulses = 4;
    
else PulseSelection=="short";
    decimation_factor = 1;          % Data collected at 100 MHz
    Fs = 100e6;                      % Sample Frequency (Hz)
    BW = 20e6;                       % Hardware Bandwidth (Hz)
    tau = 250e-9;
    PWindex = ceil(tau*Fs);     % Pulse width sample index
    numcohPulse = 20;                % Number of coherent pulse to be grouped together (function of the sea state, see sea state function)
    c = 299792458;                  % Speed of light (m/s)
    fc = 9.41e9;                    % Carrier frequency (Hz)
    PRI = 0.5e-3;                   % Pulse repetition index (s)
    lambda = c/fc;                  % Wavelength (m)
    PPIflag = 0;                    % Flag to indicate plan position indicator map processing mode
    noiseStart = 20e3;             % noise range in m
    noiseStop = 25e3;              % noise range in m
    signalEnd = 16000;             %DEG will be the same as long pulse because of no down sampling
    PRF = 2000;
    numPulses = 20;
end
%signalEnd = 16000;

% DEG CAG ?
% Vp,Nnoise -->parameterize -->send to loadrawdataloop


%% Getting voltage input
[voltage,fnameraw] = loadRawData_loop(data_dir,decimation_factor,startF,endF,StartNoiseIndex,EndNoiseIndex,VpeakA,VpeakB);
%     Vout=voltage.Storevoltage(1:signalEnd,:);
%     voltage.Storevoltage=voltage.Storevoltage(1:signalEnd,:);

voltageA = voltage.StorevoltageA;
voltageB = voltage.StorevoltageB;
%% remove error at the end of every 4th pulse and set the start of the pulse to the zero range
fth_Pulse = 4:4:4000;

% DEG CAG is this 70? with everything connected at the end ?
% pulseBegin = 70;?
pulseBegin = find(voltageA >=0.0015,1,'first');%DEG Change Threshold it was .2

raw_sampleSize = size(voltageA,1);

voltageA(raw_sampleSize-6:raw_sampleSize,fth_Pulse) = voltageA(raw_sampleSize-13:raw_sampleSize-7,fth_Pulse);
voltageA = circshift(voltageA,-1*(pulseBegin-3));
voltageA = voltageA(1:raw_sampleSize-(pulseBegin-3),:);

voltageB(raw_sampleSize-6:raw_sampleSize,fth_Pulse) = voltageB(raw_sampleSize-13:raw_sampleSize-7,fth_Pulse);
voltageB = circshift(voltageB,-1*(pulseBegin-3));
voltageB = voltageB(1:raw_sampleSize-(pulseBegin-3),:);

%% Define Ploting and FFT Parameters

samples = size(voltageA,1);   % Must define samples after size change
time = (1:samples)*(1/Fs);
range = (3e8*time)/2;
NFFT = size(voltageA,1);
f_axis = (-Fs/2:Fs/NFFT:Fs/2-Fs/NFFT)/1e6;
Mag = fft(voltageA(:,1),NFFT);

%do we need these shortened?
Mag_pos = Mag(length(Mag)/2:end);
f_pos = f_axis(length(f_axis)/2:end);
maxFreqindex = find(Mag_pos==max(Mag_pos));
maxFreq = f_pos(maxFreqindex);
Energy = 10*log10(abs(Mag'*Mag)/length(Mag))+30;
%
Energy = round(Energy,2);
maxFreq_disp = round(maxFreq,2);


%% RFI Reduction

%may want to store non rfi if wanted. currently it is replaced.

% RFI for single pulse
nRFI_range = 3;
RFI_cut_amplitude = 3.2;%2.6;
voltageA(pulseBegin+PWindex+1:end,:) = RFI_coh_MED_range(voltageA(pulseBegin+PWindex+1:end,:),nRFI_range,RFI_cut_amplitude);

%RFI over miltiple Pulses
nRFI = 31;%71; DEG change                    % Number of samples to group together
RFI_cut_amplitude = 3.2;%2.6;         % RFI cutoff amplitude
voltageA = RFI_coh_MED(voltageA,nRFI,RFI_cut_amplitude);

%vv = hilbert(voltage.Storevoltage);
%voltage.Storevoltage = vv;
% %% Set up low-pass filter parameters to be used within loop
% fp = BW/2 - BW*0.025;          %Passband
% fs = BW/2 + BW*0.075;          %Stopband
% dem = (fs - fp)/(Fs/2);
% L = 3.1/dem;                   %Multiplier from DSP class
% L = 2*round(L/2);              %L is even to have an odd filter order, to obtain a null at nyquist
% LPF_h = fir1(L-1,(BW*1.00)/2*2/Fs,'low',hann(L)).';
% LPFfreq = fftshift(fft(LPF_h,NFFT));

%% Convert to Power
startIndex = find(range>=noiseStart,1,'first');
%stopIndex = 16000;%find(range>=noiseStop,1,'first'); DEG set above

%% NCI Average
voltageA_hil = hilbert(voltageA);
if(voltageB ~= 0)%DEG
    voltageB_hil = hilbert(voltageB);
end
PowerA = ((abs(voltageA_hil).^2)/(sqrt(2)^2*50))/2;  %what is this 2 at the end? hilbert 2?

if(voltageB ~= 0)%DEG
    PowerB = ((abs(voltageB_hil).^2)/(sqrt(2)^2*50))/2;  %what is this 2 at the end? hilbert 2?
end
%[nci_pow,NS,pow_RFI] = RFI_inc_MED(power,nRFI,RFI_cut_amplitude,startIndex,stopIndex,PPIflag);
nci_pow = mean(PowerA,2);  % do we need powera in final ?

%% Matched Filter and Pulse-Pair Nested Loop

for rr = 1:(size(voltageA,2)-(mod(size(voltageA,2),numcohPulse)))/numcohPulse % loop over number of pulses/numcohpulses
    for qq = (rr-1)*numcohPulse+1:(rr)*numcohPulse  %loop over individual pulse 1:numcohPulse
        
        
        %vv = voltageA_hil(:,qq);
        %% hilbert transform to recover        DEG
        %voltHil = hilbert(vv);
        %voltBB = (voltHil.*exp(-j*2*pi*(Fs/4)*time.'))/(2);
        
        %voltHil = PowerHil(:,qq);%DEG this replaces the need for the two lines above
        voltageA_BB = (voltageA_hil(:,qq).*exp(-j*2*pi*maxFreq*1e6*time.'))/(2); %baseband conversion for found max freq instead of 5MHz like it should be
        
        %if(voltageB ~= 0)%DEG
            voltageB_BB = (voltageB_hil(:,qq).*exp(-j*2*pi*maxFreq*1e6*time.'))/(2); %baseband conversion for found max freq instead of 5MHz like it should be
        %end
        % Do we want this fixed as josh did at 70 or flexible?
        %pulseStart =  70;%find(voltBB >=.2,1,'first');           % Start of the Pulse
        pulseStart =  find(voltageA_BB >=.05,1,'first');           % Start of the Pulse
        
        %% Convert to Baseband and Low-Pass Filter
        
        
        %             xrCirc = circshift(xrBB,pulseStart);
        %             BBfreq = fftshift(fft(xrCirc));
        %             filt = LPFfreq.*BBfreq;
        %             timeFilt = (ifft(filt));
        %             first_Circ = circshift(timeFilt,-25);
        
        
        %% Initialize Parameters for Matched Filter
        
        %% DEG this is where I would put the stored pulse to compare
        %if(voltageB ~= 0)%DEG
            xt = voltageB_BB(pulseStart:(pulseStart+PWindex),1);
%         else
%             xt = voltageA_BB(pulseStart:(pulseStart+PWindex),1);           % Filter xt
%         end
        
        xr = voltageA_BB(pulseStart:end,1); %CH A      DEG Change                     % Scene xr
        filterPower = sum((abs(xt)).^2);
        xtNorm = xt/sqrt(filterPower*(BW/((1/tau))));
        %xtNorm = xt/sqrt(filterPower);
        %xtNorm = xt/(2*sqrt(Fs/2/BW*filterPower)); %suggested by Shanka
        %but doesn't seem necessary
        
        %% Matched Filter
        XR = fft(xr,NFFT);
        XT = fft(xtNorm,NFFT);
        Match = XR.*conj(XT);
        xrMatch = ifft(Match);
        
        %filtCirc(:,qq) = xrMatch;
        Nshift = 25; % this needs to go up with all others, potentially one for long one for short ?
        ShiftedCoh(:,qq) = circshift(xrMatch,Nshift); %this is here to shift the leading edge away from the end of the data
        %DEG maybe need to change ?
        
        
        
        %% Pulse-Pair Processing
        coh_power(:,qq) = ShiftedCoh(:,qq);
        if mod(qq,numcohPulse)~=1
            pairPulse(:,qq) = ShiftedCoh(:,qq-1).*conj(ShiftedCoh(:,qq));%DEG why are we multiplying the pulse of one with the CONJ of the next
            velocity(:,qq) = -1*i*((log(pairPulse(:,qq)) - log(abs(pairPulse(:,qq)))) *lambda)/(2*pi*2*PRI);
            phase(:,qq) = -1*i*((log(pairPulse(:,qq)) - log(abs(pairPulse(:,qq)))));
            ppp = ShiftedCoh(:,qq-1).*conj(ShiftedCoh(:,qq));%DEG why are we multiplying the pulse of one with the CONJ of the next
            ppp = ppp./abs(ppp);
            coh_power(:,qq) = ShiftedCoh(:,qq).*ppp;
        end
        
    end
    
    
    xrStore = ShiftedCoh(:,qq-numcohPulse+1:end); %filtcirc at this point only exists from 1 to max qq value of the for loop above, fix?
    xrMatch_avg(:,rr) = abs(mean((xrStore),2)); %idk about the division by 2
    %     %MatchPower(:,rr) = (xrMatch_avg(:,rr)).^2)/(2*50);
    %
    %
    % wtf are these?
%     xrStorepp = coh_power(:,qq-numcohPulse+1:end);
%     xrStorePowerpp = ((xrStorepp).^2)/(2*50); % *2 multiplier due to baseband conversion
    %     % but I'm pretty sure I'm gaining a *2 inherently by taking the
    %     % magnitude of the complex signal so I actually don't need the *2
    %     % (5/21/18)
%     xrMatch_avgpp(:,rr) = abs(mean((xrStorePowerpp),2));
    
end



nci_pow = nci_pow(1:signalEnd,1); %DEG do not need anymore because signal is truncated above

PowAvg_match = (abs(ShiftedCoh).^2)/(2*50);   % 16k x 4000
PowAvg_coh = (abs(xrMatch_avg).^2)/(2*50);   % 16k x 1000

% match_pow = mean(PowAvg_match,2);
% match_pow = match_pow(1:signalEnd,:);

coh_pow = mean(PowAvg_coh,2);
coh_pow = coh_pow(1:signalEnd,:);

% % xrMatch_cohpp = mean(xrMatch_avgpp,2);
% % xrMatch_cohpp = xrMatch_cohpp(1:signalEnd,:);
velocity = velocity(1:signalEnd,:);

%xrMatch_avgpp = xrMatch_avgpp(1:signalEnd,:);

%% Redefine Plotting Parameters
samples = size(nci_pow,1);   % Must define samples after size change
time = (1:samples)*(1/Fs);
range = (3e8*time)/2;

%% Remove Average Noise
% noiseStart = 100e3;
% noiseStop = 120e3;
%
% startIndex = find(range>=noiseStart,1,'first');
% stopIndex = find(range>=noiseStop,1,'first');

MNnoiseMatch = mean(PowAvg_match(startIndex:end,:),1);  % WTF?
MNpowNoise_match = mean(MNnoiseMatch,2);

MNpowNoisecoh = mean(PowAvg_coh(startIndex:end,:),1);  % COH NOISE
MNpowNoise_coh = mean(MNpowNoisecoh,2);

MNnoise = mean(PowerA(startIndex:end,:),1);  % INC NOISE
MNpowNoise_nci = mean(MNnoise,2);

% MNnoisePP = mean(xrMatch_avgpp(startIndex:end,:),1);   % WTF?
% PPNoiseAvg = mean(MNnoisePP,2);

matchOffset = abs(10*log10(abs(MNpowNoise_match)) -  10*log10(abs(MNpowNoise_nci)));


    %% Range-Doppler Map

    velocity((velocity==0))=NaN;

    %% Find Average Velocity for a given Range
    % remember, every 4th pulse has invalid data because it is the reference to
    % the other velocities
    pulseToss = 1:4:4000;
    vel = velocity;
    vel(:,pulseToss) = [];

    MNVel = mean(vel,2,'omitnan');






%nciPC = nci_pow - MNpowNoise_nci;  % NOT NECESSARY ANYMORE, REPORTING
%RADAR RECEIVED POWER AND NOISE SEPERATELY
%nonCiPc = nciPC;
%nonCiPc(nonCiPc<0) = NaN;

%DEG DONT NEED
% % MatchPC = match_pow - MNpowNoise_match;   %WTF?
% % Pc = MatchPC;
% % Pc(Pc<0) = NaN;

%cohPC = coh_pow - MNpowNoise_coh; % NOT NECESSARY ANYMORE, REPORTING
%RADAR RECEIVED POWER AND NOISE SEPERATELY
%noncohPc = cohPC;
%noncohPc(noncohPc<0) = NaN;

% % PP_PC = xrMatch_cohpp - PPNoiseAvg;   %WFT?


%     nciPcNoise = mean(nonCiPc(startIndex:stopIndex),1,'omitnan');  % CRAP
%     matchPcNoise = mean(Pc(startIndex:stopIndex),1,'omitnan');
%     cohPcNoise = mean(noncohPc(startIndex:stopIndex),1,'omitnan');



% % %     %% Plots
% % %
% % %     pow_RFI = pow_RFI(1:signalEnd,1);
% % %     PowAvg_match = PowAvg_match(1:signalEnd,1);
% % %
% % %     figure()
% % %     plot(range(1:size(pow_RFI,1))/1e3,10*log10(abs(pow_RFI(:,1)))+30,range(1:size(PowAvg_match,1))/1e3,10*log10(abs(PowAvg_match(:,1)))+30);%range/1e3,10*log10(abs(coh_pow))+30);%,range/1e3,10*log10(abs(xrMatch_cohpp))+30);
% % %     xlabel('Range (km)');
% % %     ylabel('dBm');
% % %     grid on;
% % %     legend( 'non-coherent','Matched filter NCI Average');%,'Coherent');%,'pulse-pair');
% % %     title('10/17/17 6:00 UTC');
% % %     ylim([-70 10]);
% % %     xlim([0 120]);
% % %
% % %     % figure()
% % %     % plot(range/1e3,10*log10(abs(nci_pow))+30,range/1e3,10*log10(abs(coh_pow))+30+matchOffset,range/1e3,10*log10(abs(match_pow))+30);%,range/1e3,10*log10(abs(xrMatch_cohpp))+30);
% % %     % xlabel('Range (km)');
% % %     % ylabel('dBm');
% % %     % grid on;
% % %     % legend( 'non-coherent','Coherent','non-coherent Matched Filter');%,'pulse-pair');
% % %     % title('10/13/17 12:00 UTC');
% % %     % %ylim([-70 10]);
% % %     % xlim([0 120]);
% % %     %
% % %     % figure()
% % %     % plot(range/1e3,10*log10(abs(nonCiPc))+30,range/1e3,10*log10(abs(Pc))+30,range/1e3,10*log10(abs(cohPC))+30);%,range/1e3,10*log10(abs(xrMatch_cohpp))+30);
% % %     % xlabel('Range (km)');
% % %     % ylabel('dBm');
% % %     % grid on;
% % %     % legend('non-coherent','Matched filter NCI Average','Coherent');%,'pulse-pair');
% % %     % title('10/13/17 12:00 UTC');
% % %     % ylim([-90 10]);
% % %     % xlim([0 120]);
% % %     %
% % %
% % %
% % %
% % %     %% Range-Doppler Map
% % %     PRF = 400;
% % %     numPulses = 4;
% % %     index = 1/2.5e-3/numPulses;
% % %     Fd = (-PRF/2:index:PRF/2-index);
% % %     v = ((3e8/9.41e9)/2)*Fd;
% % %
% % %     pulseTime = 0:2.5e-3:2.5e-3*4000-2.5e-3;
% % %     velocity((velocity==0))=NaN;
% % %
% % %     Fd = (velocity*2)/lambda;
% % %
% % %     %% Find Average Velocity for a given Range
% % %     % remember, every 4th pulse has invalid data because it is the reference to
% % %     % the other velocities
% % %     pulseToss = 1:4:4000;
% % %     vel = velocity;
% % %     vel(:,pulseToss) = [];
% % %
% % %     MNVel = mean(vel,2,'omitnan');
% % %
% % %     % figure()
% % %     % plot(range/1e3,MNVel);
% % %     % grid on
% % %     % xlabel('Range (km)');
% % %     % ylabel('Velocity (m/s)');
% % %     % hold on
% % %     % yyaxis right
% % %     % ylabel('dBm')
% % %     % plot(range/1e3,10*log10(abs(coh_pow))+30+matchOffset);
% % %     % title('10/13/17 12:00 UTC');
% % %     %
% % %     %
% % %     % figure()
% % %     % imagesc(range/1e3,pulseTime,real(velocity).')
% % %     % xlabel('Range (km)');
% % %     % ylabel('time (s)');
% % %     % colorbar
% % %     %
% % %     % %view(0,90)
% % %     % set(gca,'ydir','normal');
% % %     % hold on
% % %     % yyaxis right
% % %     % plot(range/1e3,10*log10(abs(coh_pow))+30+matchOffset,'r');
% % %     % title('10/13/17 12:00 UTC');
% % %
% % %     % checkStart = 1e3;
% % %     % checkStop = 50e3;
% % %     % startIndexCheck = find(range>=checkStart,1,'first');
% % %     % stopIndexCheck = find(range>=checkStop,1,'first');
% % %     %
% % %     % VelCheck = mean(MNVel(startIndexCheck:stopIndexCheck));
% % %
% % %
% % %     %% DOPPLER REMOVAL. IMPORTANT! JUST NOT FOR CURRENT PROCESSING
% % %
% % %     %% Stationary FLIP,Feed Through, and Buoy removal
% % %
% % %     % FLIPStart = 46.04e3;
% % %     % FLIPStop = 48.54e3;
% % %     % startIndexFLIP = find(range>=FLIPStart,1,'first');
% % %     % stopIndexFLIP = find(range>=FLIPStop,1,'first');
% % %     % coh_pow(startIndexFLIP:stopIndexFLIP) = NaN;
% % %     % nci_pow(startIndexFLIP:stopIndexFLIP) = NaN;
% % %     %
% % %     % FEEDStart = 0e3;
% % %     % FEEDStop = 0.8e3;
% % %     % startIndexFEED = find(range>=FEEDStart,1,'first');
% % %     % stopIndexFEED = find(range>=FEEDStop,1,'first');
% % %     % coh_pow(startIndexFEED:stopIndexFEED) = NaN;
% % %     % nci_pow(startIndexFEED:stopIndexFEED) = NaN;
% % %     %
% % %     % Buoy21Start = 4.7e3;
% % %     % Buoy21Stop = 5.5e3;
% % %     % startIndexBuoy21 = find(range>=Buoy21Start,1,'first');
% % %     % stopIndexBuoy21 = find(range>=Buoy21Stop,1,'first');
% % %     % coh_pow(startIndexBuoy21:stopIndexBuoy21) = NaN;
% % %     % nci_pow(startIndexBuoy21:stopIndexBuoy21) = NaN;
% % %     %
% % %     % Buoy22Start = 20e3;
% % %     % Buoy22Stop = 20.74e3;
% % %     % startIndexBuoy22 = find(range>=Buoy22Start,1,'first');
% % %     % stopIndexBuoy22 = find(range>=Buoy22Stop,1,'first');
% % %     % coh_pow(startIndexBuoy22:stopIndexBuoy22) = NaN;
% % %     % nci_pow(startIndexBuoy22:stopIndexBuoy22) = NaN;
% % %     %
% % %     %
% % %     %
% % %     % VelHist = histogram(MNVel,25); %50
% % %     %
% % %     % KillBins = find(VelHist.BinCounts<80);%60); %200
% % %     % values = VelHist.BinEdges(KillBins);
% % %
% % %
% % %
% % %     % for aa = 1:length(values)
% % %     %
% % %     % velIndex(aa) =find(abs(MNVel-values(aa))==min(abs(MNVel-values(aa))));
% % %     % %velIndex(:,aa) = find(MNVel>=values(aa) & MNVel<=values(aa)+0.01);%,1,'first');
% % %     % end
% % %     %
% % %     %
% % %     % Doppvar = 100;
% % %     % for rr = 1:length(velIndex)
% % %     %     %if (abs(MNVel(rr)) >= 0.8)
% % %     %         for slideVar = 1:Doppvar
% % %     %             coh_pow(velIndex(rr)) = NaN;
% % %     %             coh_pow(velIndex(rr)+slideVar) = NaN;
% % %     %             coh_pow(velIndex(rr)-slideVar) = NaN;
% % %     %
% % %     %             nci_pow(velIndex(rr)) = NaN;
% % %     %             nci_pow(velIndex(rr)+slideVar) = NaN;
% % %     %             nci_pow(velIndex(rr)-slideVar) = NaN;
% % %     %
% % %     %         end
% % %     %     %else
% % %     %     %end
% % %     % end
% % %
% % %
% % %
% % %     cohPC = coh_pow - MNpowNoise_coh;
% % %     nciPC = nci_pow - MNpowNoise_nci;
% % %
% % %     cohSNR = 10*log10(abs(coh_pow)) - 10*log10(abs(MNpowNoise_coh));
% % %     nciSNR = 10*log10(abs(nci_pow)) - 10*log10(abs(MNpowNoise_nci));
% % %
% % %
% % %
% % %     nonCiPc = nciPC;
% % %     nonCiPc(nonCiPc<0) = NaN;
% % %
% % %     noncohPc = cohPC;
% % %     noncohPc(noncohPc<0) = NaN;
% % % % % % % %
% % % % % % % %
% % % % % % % %     load('SIO_Buoy_Data_Casper.mat');
% % % % % % % %
% % % % % % % %
% % % % % % % %     Wind = datetime(Met21.Time,'ConvertFrom','datenum');
% % % % % % % %
% % % % % % % %     WindSpeed = Met21.Wind_Speed*0.514444;
% % % % % % % %
% % % % % % % %     %% Get Filename For Figure Title
% % % % % % % %     fileIndex = find(ismember(fnameraw,'R'));
% % % % % % % %
% % % % % % % %     splitIndex = find(ismember(fnameraw,'_'));
% % % % % % % %     splitIndex = splitIndex(2);
% % % % % % % %
% % % % % % % %     titleName1 = fnameraw(fileIndex+2:splitIndex-1);
% % % % % % % %     titleName2 = fnameraw(splitIndex+1:end-4);
% % % % % % % %     space = ' ';
% % % % % % % %     titleName = [titleName1,space,titleName2];
% % % % % % % %
% % % % % % % %     dateCheck = titleName1(9:end);
% % % % % % % %     dateCheck = str2num(dateCheck);
% % % % % % % %
% % % % % % % %     hourCheck = titleName2(1:2);
% % % % % % % %     hourCheck = str2num(hourCheck)+1;
% % % % % % % %
% % % % % % % %     Dts = 13:1:27;
% % % % % % % %     for ww = 1:length(Dts)
% % % % % % % %         if (dateCheck == Dts(ww))
% % % % % % % %             disp_Wind = Wind(386+24*(ww-1):409+24*(ww-1));
% % % % % % % %             disp_WindSpeed = WindSpeed(386+24*(ww-1):409+24*(ww-1));
% % % % % % % %         else
% % % % % % % %         end
% % % % % % % %     end
% % % % % % % %
% % % % % % % %     %AvgWind = mean(disp_WindSpeed);
% % % % % % % %     hourWind = disp_WindSpeed(hourCheck);
% % % % % % % %
% % % % % % % %
% % % % % % % %     if (hourWind <= 0.5)
% % % % % % % %         BeauNum = 0;
% % % % % % % %         BeauString = 'Calm';
% % % % % % % %
% % % % % % % %     elseif (hourWind> 0.5 & hourWind < 1.6)
% % % % % % % %         BeaNum = 1;
% % % % % % % %         BeauString = 'Light Air';
% % % % % % % %     elseif (hourWind>= 1.6 & hourWind < 3.4)
% % % % % % % %         BeaNum = 2;
% % % % % % % %         BeauString = 'Light Breeze';
% % % % % % % %
% % % % % % % %     elseif (hourWind>= 3.4 & hourWind < 5.5)
% % % % % % % %         BeaNum = 3;
% % % % % % % %         BeauString = 'Gentle Breeze';
% % % % % % % %
% % % % % % % %     elseif (hourWind>= 5.5 & hourWind < 8)
% % % % % % % %         BeaNum = 4;
% % % % % % % %         BeauString = 'Moderate Breeze';
% % % % % % % %
% % % % % % % %     elseif (hourWind>= 8 & hourWind < 10.8)
% % % % % % % %         BeaNum = 5;
% % % % % % % %         BeauString = 'Fresh Breeze';
% % % % % % % %
% % % % % % % %     elseif (hourWind>= 10.8 & hourWind < 13.9)
% % % % % % % %         BeaNum = 6;
% % % % % % % %         BeauString = 'Strong Breeze';
% % % % % % % %
% % % % % % % %     else
% % % % % % % %         BeaNum = 7;
% % % % % % % %         BeauString = 'High Wind';
% % % % % % % %
% % % % % % % %     end
% % % % % % % %
% % % % % % % %
% % % % % % % %     minPc = 10*log10(abs(min(nonCiPc(1:6667))))+30;
% % % % % % % %
% % % % % % % %
% % % % % % % %     figure()
% % % % % % % %     subplot(2,4,1)
% % % % % % % %     plot(range/1e3,10*log10(abs(nci_pow))+30,'color',[0.0 0.0 1.0]);
% % % % % % % %     hold on
% % % % % % % %     plot(range/1e3,10*log10(abs(coh_pow))+30+matchOffset,'color',[1.00 0.0 0.0]);
% % % % % % % %     xlabel('Range (km)');
% % % % % % % %     ylabel('dBm');
% % % % % % % %     grid on;
% % % % % % % %     legend('non-coherent','Coherent');%,'pulse-pair');
% % % % % % % %     %title('10/13/17 12:00 UTC');
% % % % % % % %     ylim([-55 2]);
% % % % % % % %     xlim([0 50]);
% % % % % % % %
% % % % % % % %
% % % % % % % %     subplot(2,4,2)
% % % % % % % %     plot(range/1e3,MNVel,'color',[0.0 1.0 1.0]);
% % % % % % % %     grid on
% % % % % % % %     xlabel('Range (km)');
% % % % % % % %     ylabel('Velocity (m/s)');
% % % % % % % %     hold on
% % % % % % % %     yyaxis right
% % % % % % % %     ylabel('dBm','color',[1.00 0.0 0.0]);
% % % % % % % %     plot(range/1e3,10*log10(abs(coh_pow))+30+matchOffset,'color',[1.0    0.0    0.0]);
% % % % % % % %     legend('Mean Velocity','Coherent');
% % % % % % % %     xlim([0 50]);
% % % % % % % %     ylim([-55 2]);
% % % % % % % %
% % % % % % % %     subplot(2,4,3)
% % % % % % % %     plot(f_axis,20*log10(abs(Mag)),'color',[1.0 0.4 0]);
% % % % % % % %     xlabel('Frequency (MHz)');
% % % % % % % %     xlim([0 10]);
% % % % % % % %     ylabel('dB');
% % % % % % % %     grid on;
% % % % % % % %     % legend(['Fc = ', num2str(maxFreq), ' MHz']');
% % % % % % % %     % title(['Energy = ', num2str(Energy), ' dB']);
% % % % % % % %     title({['Power = ', sprintf('%g %s', Energy,'dB')];['Fc = ', sprintf('%g %s',maxFreq_disp,'MHz')]});
% % % % % % % %
% % % % % % % %     subplot(2,4,4)
% % % % % % % %     plot(disp_Wind,disp_WindSpeed,'color',[0.0 0.59 0.60]);
% % % % % % % %     title({'Met Buoy 21 (5 km South of Radar)';['Beaufort Number ', num2str(BeaNum)]; [BeauString]});
% % % % % % % %     ylabel({'Wind Speed';'(m/s)'});
% % % % % % % %     xlabel('Date (UTC)');
% % % % % % % %     grid on;
% % % % % % % %
% % % % % % % %     subplot(2,4,5)
% % % % % % % %     plot(range/1e3,10*log10(abs(nonCiPc))+30,'color',[0.0 0.0 1.0]);
% % % % % % % %     hold on
% % % % % % % %     plot(range/1e3,10*log10(abs(noncohPc))+30+matchOffset,'color',[1.0 0.0 0.0]);%,range/1e3,10*log10(abs(xrMatch_cohpp))+30);
% % % % % % % %     xlabel('Range (km)','FontSize', 12);
% % % % % % % %     ylabel('dBm','FontSize', 12);
% % % % % % % %     grid on;
% % % % % % % %     legend('non-coherent P_c','Coherent P_c');%,'pulse-pair');
% % % % % % % %     %title('10/13/17 12:00 UTC');
% % % % % % % %     %ylim([-90 10]);
% % % % % % % %     ylim([minPc 2]);
% % % % % % % %     xlim([0 50]);
% % % % % % % %     title(titleName);
% % % % % % % %
% % % % % % % %
% % % % % % % %
% % % % % % % %     subplot(2,4,6)
% % % % % % % %     plot(range/1e3,nciSNR,'color',[0.0 0.0 1.0]);
% % % % % % % %     hold on
% % % % % % % %     plot(range/1e3,cohSNR,'color',[1.0 0.0 0.0]);
% % % % % % % %     grid on
% % % % % % % %     xlabel('Range (km)');
% % % % % % % %     ylabel('dB');
% % % % % % % %     legend('non-coherent SNR','Coherent SNR');
% % % % % % % %     xlim([0 50]);
% % % % % % % %     ylim([-2 50]);
% % % % % % % %
% % % % % % % %
% % % % % % % %     subplot(2,4,7:8)
% % % % % % % %     imshow( 'DuctProfileHeight.jpg');
% % % % % % % %
% % % % % % % %     set(gcf, 'Position', [800, 800, 1300, 700])
% % % % % % % %
% % % % % % % %
% % %
% % %
% % %


u=1;

for r =1:size(nci_pow,2);
    for z =6:10:size(nci_pow,1)-5;
        
        NEWnonCiPc(u,r)=mean(nci_pow(z-5:z+5));
        %   NEWnonCiPc(u,r)=mean(nonCiPc(z-5:z+5));
        NEWrange(u)=mean(range(z-5:z+5));
        
        
        if r<2
            NEWrange(u)=mean(range(z-5:z+5));
        else
        end
        
        
        u=u+1;
        
    end
end
%DEG NOT USED YET
NEWnonCiPc(u)=mean(nci_pow(end-5:end));
NEWrange(u)=mean(range(end-5:end));

%     saveas(gcf, ['/Users/Joshuacompaleo/Desktop/CASPER_data_processing/6HrStore/',titleName,'.png']);
%
%     close all
%
Store_nci(:) = nci_pow;
Store_coh(:) = coh_pow;
Store_offset(:) = matchOffset;
Store_vel(:) = MNVel; %DEG Do we need this??
%     Store_mag(:,ii) = Mag;
%    Store_nciPc(:,ii) = nonCiPc;
%    Store_cohPc(:,ii) = noncohPc;
Store_cohNoise(:) = MNpowNoise_coh;
Store_nciNoise(:) = MNpowNoise_nci;
%     Store_maxFreq(:,ii) = maxFreq;
%     Store_Energy(:,ii)  = Energy; %wtf is rthis degrafth?   do i need it
%     degrafrth!

%clearvars -except Store_nci Store_coh Store_offset Store_vel Store_mag Store_nciPc Store_cohPc MNpowNoise_coh MNpowNoise_nci filenames data_dir fin starter stopper ii Store_maxFreq Store_Energy

end





% save('6HrAnalysis');