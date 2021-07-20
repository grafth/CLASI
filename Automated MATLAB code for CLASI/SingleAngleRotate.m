function [AzDegree,ElDegree]=SingleAngleRotate(AzAngle,LaunchAngle)

%% connecting to serieal port
s2 = serial("COM4", 'BaudRate', 460800);
addpath(genpath('./'));
fid=fopen('Log File.txt');
% data=readline(s2)
fopen(s2);
%% scaning angle set
NN=['30';'31';'32';'33';'34';'35';'36';'37';'38';'39'];

%% Angle input

%% Angle input ,math
StartAzAngleEncode = (AzAngle+360)*10;
StartElAngleEncode = (LaunchAngle+360)*10;

%% Converting the angle to 
StrtAzThou=floor(StartAzAngleEncode/1000);
StrtAzHun=floor((StartAzAngleEncode-StrtAzThou*1000)/100);
StrtAzTens=floor((StartAzAngleEncode-StrtAzHun*100 -StrtAzThou*1000 )/10);
StrtAzones=floor(StartAzAngleEncode-StrtAzHun*100 -StrtAzThou*1000 -StrtAzTens*10);

StrtElThou=floor(StartElAngleEncode/1000);
StrtElHun=floor((StartElAngleEncode-StrtElThou*1000)/100);
StrtElTens=floor((StartElAngleEncode-StrtElHun*100 -StrtElThou*1000 )/10);
StrtElones=floor(StartElAngleEncode-StrtElHun*100 -StrtElThou*1000 -StrtElTens*10);

%% Setting the angle
    cmd=['57',...
        NN(StrtAzThou+1,:),NN(StrtAzHun+1,:),NN(StrtAzTens+1,:),NN(StrtAzones+1,:),'0A',...
        NN(StrtElThou+1,:),NN(StrtElHun+1,:),NN(StrtElTens+1,:),NN(StrtElones+1,:),'0A','2F','20'];
D=sscanf(cmd, '%2x');
    fwrite(s2,D,'uint8');
   
AzDegree=str2double(strcat(NN(StrtAzThou+1,2), NN(StrtAzHun+1,2), NN(StrtAzTens+1,2), ".", NN(StrtAzones+1,2)))-360;
ElDegree=str2double(strcat(NN(StrtElThou+1,2), NN(StrtElHun+1,2), NN(StrtElTens+1,2), ".", NN(StrtElones+1,2)))-360;


fclose(s2)
end