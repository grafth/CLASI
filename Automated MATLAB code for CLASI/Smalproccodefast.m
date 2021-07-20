%%
FN=dir('E:\CLASI_Save folder\SAVE');
cd(('E:\CLASI_Save folder\SAVE'))
for i=3:length(FN)
Mat(i-2)=load(FN(i).name);
end
%%
for ii=1:length(FN)-2
        BB(ii)=Mat(ii).Store_nciNoise;
   BBB(ii,:)=Mat(ii).Store_nci;
end
%%
for ii=3:length(FN)-1
%AwNoise(ii-2,:)=10*log10((Mat(ii).Store_nciNoise));
if ii<18
    Nmean(ii-2)=mean(BB(3:33)); 
elseif ii>length(FN)-19
  Nmean(ii-2)=mean(BB(length(FN)-28:end));   
else
Nmean(ii-2)=mean(BB(ii-15:ii+15));    
end
% 
% A(ii-2,:)=10*log10((Mat(ii).Store_nci-Nmean(ii-2)));
% AA(ii-2,:)=10*log10((Mat(ii).Store_nci));

for p=1:16000
    if(BBB(ii-2,p)-Nmean(ii-2))<0 %(Mat(ii).Store_nci(:,p)-Nmean(ii-2))<0
        BBB(ii-2,p)= 1.1*Nmean(ii-2);
        %q=q+1;
    else
    end
end
AAA(ii-2,:)=10*log10(BBB(ii-2,:)-Nmean(ii-2));
end
%%
figure
for iii=1:186%length(FN)-1
    
   %plot(Mat(3).range/1e3,10*log10(Mat(iii).Store_nci)+30)
   plot(Mat(3).range/1e3,AAA(iii,:)+30)
  % plot(Mat(3).range/1e3,AA(iii,:)+30)
   %plot(Mat(3).range/1e3,A(iii,:)+30)
   hold on
   xlim([0 15])
   pause(1);
end
%%
% 
% for iii=3:length(Mat)
% Binny2(iii)=Mat(iii).Store_nci(abs(range-1400)==min(abs(range-1400)));
% Binny3(iii)=Mat(iii).Store_nci(abs(range-1500)==min(abs(range-1500)));
% Binny4(iii)=Mat(iii).Store_nci(abs(range-1600)==min(abs(range-1600)));
% Binny5(iii)=Mat(iii).Store_nci(abs(range-1700)==min(abs(range-1700)));
% Binny6(iii)=Mat(iii).Store_nci(abs(range-1800)==min(abs(range-1800)));
% Binny7(iii)=Mat(iii).Store_nci(abs(range-1100)==min(abs(range-1100)));
% Binny8(iii)=Mat(iii).Store_nci(abs(range-1200)==min(abs(range-1200)));
% Binny9(iii)=Mat(iii).Store_nci(abs(range-1300)==min(abs(range-1300)));
% Binny10(iii)=Mat(iii).Store_nci(abs(range-2200)==min(abs(range-2200)));
% Binny11(iii)=Mat(iii).Store_nci(abs(range-2300)==min(abs(range-2300)));
% Binny12(iii)=Mat(iii).Store_nci(abs(range-2400)==min(abs(range-2400)));
% Binny13(iii)=Mat(iii).Store_nci(abs(range-2500)==min(abs(range-2500)));
% 
% end
%  
% figure
% hold on
% plot(52.5:-0.1:48.4,10*log10(Binny2))
% grid on
% plot(52.5:-0.1:48.4,10*log10(Binny3))
% plot(52.5:-0.1:48.4,10*log10(Binny4))
% plot(52.5:-0.1:48.4,10*log10(Binny5))
% plot(52.5:-0.1:48.4,10*log10(Binny6))
% plot(52.5:-0.1:48.4,10*log10(Binny7))
% plot(52.5:-0.1:48.4,10*log10(Binny8))
% plot(52.5:-0.1:48.4,10*log10(Binny9))
% plot(52.5:-0.1:48.4,10*log10(Binny10))
% plot(52.5:-0.1:48.4,10*log10(Binny11))
% plot(52.5:-0.1:48.4,10*log10(Binny12))
% plot(52.5:-0.1:48.4,10*log10(Binny13))
% 
% 
% Binny14=Mat(26).Store_nci;
% figure
% plot(Mat(26).range,10*log10(abs(Binny14))+30)
