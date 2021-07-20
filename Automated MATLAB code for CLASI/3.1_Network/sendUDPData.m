function [] = sendUDPData(udpObj, cmd)

% Convert hex to dec
cmd_d   = hex2dec(cmd);

% Flush buffers
flushinput(udpObj);
flushoutput(udpObj);

% Send command
fwrite(udpObj,cmd_d);

end