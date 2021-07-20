
function [voltage, fnameraw] = loadRawData_loop(data_dir,decimation_factor,starter,stopper,StartNoiseIndex,EndNoiseIndex,VpeakA,VpeakB)


dRaw = dir([data_dir filesep 'R*.bin']);
%numfiles = length(dRaw);
for ii = starter:stopper
    fnameraw   = [data_dir filesep dRaw(ii).name];
    dataraw(ii)    = readRawData(fnameraw, decimation_factor);
    
    %DEG this is only using the data for cha A, do we need to have a seperate
    %for cha B?
    if(dataraw(ii).chASamples ~= 0)
        
        Mn = mean(dataraw(ii).chAData(StartNoiseIndex:EndNoiseIndex,:),1);
        
        N = dataraw(ii).chASamples;
        biasoffset = dataraw(ii).chAData - ones(N,1)*Mn;
        
        Storevoltage = (biasoffset./2^15).*VpeakA;
        
        if starter==1
            voltage(ii).StorevoltageA = Storevoltage;
        else
            voltage(ii-starter+1).StorevoltageA = Storevoltage;
        end
        
    else
        voltage.StorevoltageA=0;
    end
    
    %% DEG for chan B
    
    if(dataraw(ii).chBSamples ~= 0)
        
        MnB = mean(dataraw(ii).chBData(StartNoiseIndex:EndNoiseIndex,:),1);
        
        N = dataraw(ii).chBSamples;
        biasoffsetB = dataraw(ii).chBData - ones(N,1)*MnB;
        StorevoltageB = (biasoffsetB./2^15).*VpeakB;
        
        if starter==1
            voltage(ii).StorevoltageB = StorevoltageB;
        else
            voltage(ii-starter+1).StorevoltageB = StorevoltageB;
            
        end
    else
        voltage.StorevoltageB=0;
    end
    
    
    %cd('/Volumes/easystore/CASPERWESTdata');
    %save('voltageTestset1','voltage','-v7.3');
    %save(strcat('voltage_',datestr(now,'HH:MM:SS')),'voltage','-v7.3');
    
    %save('dataraw.mat','dataraw','-v7.3');
end


