%This script is only made to work with the Rigol DG1022A Function
%generator, and the Keithley 2701 Digital Ethernet Multimeter. It may work
%with other function generators and Multimeters within their respective
%families. This code should be easy to modify to suit any instrument which
%uses ascii strings for programming. Look up programming guides to be able
%to find the commands which will work with whichever instrument you plan to
%use. 
clear all
clc

TimesToRun=input('# of times to run?(Up to 10)');
SECONDFILENAME=input('FileName?','s');
TIMES=zeros(10,8);

for Iteration=1:TimesToRun
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ICMB3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TIMES(Iteration,:)=TimeString;
Data2(:,Iteration+2)=Data(:,3);  %#ok<*SAGROW>

pause(10);
end






Data2(:,1)=F;

for g=1:NumFreq
    sum=0;
    for h=1:TimesToRun
        sum=sum+Data2(g,h+2);
    end
    Data2(g,2)=sum/TimesToRun;
end

DataTitle2={'Frequency(Hz)' 'V_Red (Volts/Volt)' };
DataTitle3={' ' 'Avg'};% TIMES(1,:) TIMES(2,:) TIMES(3,:) TIMES(4,:) TIMES(5,:) TIMES(6,:) TIMES(7,:) TIMES(8,:) TIMES(9,:) TIMES(10,:)};
FileName2=[SECONDFILENAME '(' DateString '-' TimeString ')' '.xls'];


xlswrite(FileName2,DataTitle2,'Sheet1','A1')
xlswrite(FileName2,DataTitle3,'Sheet1','A2')
xlswrite(FileName2,Data2,'Sheet1','A3')