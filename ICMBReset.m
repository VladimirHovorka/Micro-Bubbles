fclose(FG);
fopen(FG);                  %Turns off Function Generator Output
fprintf(FG,'OUTP OFF');
fclose(FG);

fclose(FG);                 %Closes all communication
fclose(DMM);
fclose(OSC);
delete(FG);
delete(DMM);
delete(OSC);
clear FG
clear DMM
clear OSC

%Writes Data to Files if desired
FilePrompt='Write Data to Files?(y/n):';
WD=input(FilePrompt,'s');

if WD=='y' || WD=='Y'
    xlswrite(FileName,FileHeaderA,'Sheet1','A1')
    xlswrite(FileName,FileHeaderB,'Sheet1','A2')
    xlswrite(FileName,DataTitle,'Sheet1','A3')
    xlswrite(FileName,Data,'Sheet1','A4')

end
%clear all
%clc