%%
FN=dir('F:\CLASI_Monterey\Radar_data_100524')%'F:\CLASI_Monterey\Radar_data_AUG27C')%('F:\CLASI_Monterey\Radar_data_AUG27CHECK2')%'F:\CLASI_Monterey\Radar_data_aug_17');%('F:\CLASI_Monterey\Radar_data_22_up');%('E:\CLASI_Save folder\SAVE')
cd('F:\CLASI_Monterey\Radar_data_100524')%'F:\CLASI_Monterey\Radar_data_AUG27C')
for i=3:length(FN)%+49
Mat(i-(2))=load(FN(i).name);
end
%%
for ii=1:length(FN)-2
        BB(ii)=Mat(ii).Store_nciNoise;
   BBB(ii,:)=Mat(ii).Store_nci;
end


%%
e=1;
R=1%15*6
for q=1:length(FN)-2
Q=mod(q,R);

if Q==0
    WWx(e)=mean(BB(q-(R-1):q));
     WW(e)=mean(mean(BBB(q-(R-1):q,8000:11000)));%,11000:end-500)));
WWW(e,:)=mean(BBB(q-(R-1):q,:));
e=e+1;
else
    
end
end

%%


for ii=1:length(WW)
%AwNoise(ii-2,:)=10*log10((Mat(ii).Store_nciNoise));
% if ii<5
%     Nmean(ii)=mean(WW(1:5)); 
% elseif ii>length(WW)-5
%   Nmean(ii)=mean(WW(length(WW)-5:end));   
% else
% Nmean(ii)=mean(WW(ii-3:ii+3));    
% end
% 
% A(ii-2,:)=10*log10((Mat(ii).Store_nci-Nmean(ii-2)));
% AA(ii-2,:)=10*log10((Mat(ii).Store_nci));

for p=1:15500
    if(BBB(ii,p)-WW(ii))<0 %(Mat(ii).Store_nci(:,p)-Nmean(ii-2))<0
        BBB(ii,p)= 1*WW(ii);
        %q=q+1;
    else
    end
end
AAAAA(ii,:)=10*log10(BBB(ii,:))+30;
AAA(ii,:)=10*log10(BBB(ii,:)-WW(ii));
end

figure
imagesc(Mat(3).range/1e3,1:size(AAA,1),AAA+30)
caxis([-55 0])
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

for p=1:15500
    if(BBB(ii-2,p)-Nmean(ii-2))<0 %(Mat(ii).Store_nci(:,p)-Nmean(ii-2))<0
        BBB(ii-2,p)= 1*Nmean(ii-2);
        %q=q+1;
    else
    end
end
AAA(ii-2,:)=10*log10(BBB(ii-2,:)-Nmean(ii-2));
end
%%

figure
for iii=1:500%1:19;%134:154%1:length(FN)-2%186 %length(FN)-1
     I=find(10*log10(BBB(iii,:))+30>-2,1);
     AAA(iii,:)=circshift(AAA(iii,:),-I);
%    plot(Mat(3).range/1e3,10*log10(BBB(iii,:))+30)
   plot(Mat(3).range/1e3,AAA(iii,:)+30)
   %plot(AAA(iii,:)+30)
   %plot(Mat(1).range/1e3,AAA(iii,:)+30)
   %plot(Mat(3).range/1e3,A(iii,:)+30)
   hold on
   xlim([0 7])
   pause(0.3);
   grid on
end
%%
% 
% for iii=3:length(Mat)
% Binny2(iii8)=Mat(iii).Store_nci(abs(range-1400)==min(abs(range-1400)));
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
