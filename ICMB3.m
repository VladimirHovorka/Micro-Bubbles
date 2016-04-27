%This script is only made to work with the Rigol DG1022A Function
%generator, and the Keithley 2701 Digital Ethernet Multimeter. It may work
%with other function generators and Multimeters within their respective
%families. This code should be easy to modify to suit any instrument which
%uses ascii strings for programming. Look up programming guides to be able
%to find the commands which will work with whichever instrument you plan to
%use. 

%UserInput
PromptVpp='Desired Function Generator Peak-To-Peak Voltage in Volts?:';
PromptF_start='Starting Frequency in Hz?:';
PromptF_end='Ending Frequency in Hz?:';
PromptF_int='Frequency Interval in Hz?:';
PromptWaveType='Type of Wave:SQU=square,SIN=sine,RAMP=ramp,DC=dc voltage:';
PromptDC_Offset='Desired DC Offset in Volts?:';
PromptSample='SampleType?:';
PromptInfo='SampleInfo?:';
PromptAmpGain='Amplifier Gain';
PromptAmpVoltage='Amplifier Voltage @ 1kHz?:';

%Rigol DG1022A Outputs
F_start=100;%Hz
F_end=25000;%Hz
F_int=100;%Hz
Vpp=7.5;%Volts
WaveType='SQU';
DC_Offset=0;
dt=2;

%%%%%%F_start=input(PromptF_start); %Hz  %Uncomment if user input is desired
%%%%%%F_end=input(PromptF_end); %Hz  
%%%%%%F_int=input(PromptF_int); %Hz
%%%%%Vpp=input(PromptVpp); %Volts
%%%%%WaveType=input(PromptWaveType,'s'); %SQU=square wave, SIN=sine wave, RAMP=ramp function, DC=dc voltage
%%%%%DC_Offset=input(PromptDC_Offset);
%%%%%dt=input('dt in sec:'); %sec

%Keithley 2701
DMMString='FUNC ''VOLT:AC''';   %This is the command which will be sent to the DMM and determine what measurement is returns

%Miscellaneous-these can be used for whatever information is necessary for
%the experiment that is not within the settings of the DMM, OSC or FG
%%%%%SampleType=input(PromptSample,'s');
%%%%%SampleInfo=input(PromptInfo,'s');
%%%%%AmpGain=input(PromptAmpGain,'s');
%%%%%AmpVoltage=input(PromptAmpVoltage,'s');

SampleType='Plate with no Holes';
SampleInfo='TEST';
AmpGain='TEST';
AmpVoltage='TEST';

%Creates strings and vectors for the time and date, and creates a filename
%with those
DateString=date;
ClockVector=clock;
TimeString=[int2str(ClockVector(4)) '-' int2str(ClockVector(5)) '-' int2str(floor(ClockVector(6)))];
FileName=['MicroBubblesData(' DateString '-' TimeString ')' SampleInfo '.xls'];
FileHeaderA={'Date' 'Time' 'SampleType' 'SampleInfo' 'Vpp(FG)' 'AmplifierGain' 'AmplifierVoltage' 'WaveType' 'dt'};
FileHeaderB={DateString TimeString SampleType SampleInfo num2str(Vpp) AmpGain AmpVoltage WaveType num2str(dt)};
DataTitle={'Frequency(Hz)' 'HYD Voltage(Volts)' 'V_Red (Volts/Volt)' 'V_Amp (Volts)' 'V_Filt'};


%Creates a vector for all the frequencies necessary
NumFreq=((F_end-F_start)/F_int)+1;
F=F_start:F_int:F_end;

%Preallocates space for the Voltages
V=(1:NumFreq)*0;
BKG=V;
V_Red=V;
AmpV=V;
V_Filt=V;
%Preallocates space for the Data columns which will hold the F and V
%vectors for writing to file
Data(:,1)=F;
Data(:,2)=V;
Data(:,3)=V;
Data(:,4)=V;
Data(:,5)=V;

%Finds the function generator and connects to it
FG=instrfind('Type','visa-usb','RsrcName','USB0::0x0400::0x09C4::DG1F160100002::0::INSTR', 'Tag', '');
if isempty(FG)
    FG = visa('NI', 'USB0::0x0400::0x09C4::DG1F160100002::0::INSTR');
else
    fclose(FG);
    FG = FG(1);
end
fclose(FG);

%Finds the DMM and connects to it
DMM = instrfind('Type', 'visa-generic', 'RsrcName', 'TCPIP0::169.254.150.226::1394::SOCKET', 'Tag', '');  %fourth input string might need to be changed to reflect different ip address or hardware name
if isempty(DMM)
    DMM = visa('NI', 'TCPIP0::169.254.150.226::1394::SOCKET');  %second input string might need to be changed to reflect different ip address or hardware name
else
    fclose(DMM);
    DMM = DMM(1);
end

%Connect to Oscilloscope
OSC=serial('COM11');
fopen(OSC);
fprintf(OSC,'*RST');
fprintf(OSC,'CHAN1:DISP 0');
fprintf(OSC,'CHAN2:PROB 1');
fprintf(OSC,'CHAN2:COUP 0');
fprintf(OSC,'CHAN2:SCAL 5e+1');
fprintf(OSC,'TIM:SCAL 1e-3');
fprintf(OSC,'CHAN2:OFFS 0');
fclose(OSC);

fopen(DMM);
fprintf(DMM,'*RST');                %Restores default setup
fprintf(DMM,DMMString);    %sets the function(FREQ for frequency,VOLT:AC for ac voltage,VOLT:DC for dc voltage...)
fclose(DMM);    

fopen(FG);
fprintf(FG,'OUTP ON');
pause(dt);
fclose(FG);

% % %
fopen(DMM);
fopen(FG);
fopen(OSC);
% % % 

for i=1:NumFreq
    FGString=['APPL:' WaveType ' ' int2str(F(i)) ',' num2str(Vpp) ',' int2str(DC_Offset)];
    fprintf(FG, FGString);            %prints the string to the FG
    pause(dt);                        %pauses for dt sec
    
    fprintf(DMM,'TRAC:CLE');          %Clears Buffer
    fprintf(DMM,'SAMP:COUN 1');       %how many samples to collect
    fprintf(DMM,'READ?');             %tells the DMM to output the reading
    Temp=fscanf(DMM);                 %temporary spot for DMM output data
    pause(dt);                        %pauses for dt sec
    V(i)=str2double(Temp(1:15));     
    
    fprintf(OSC,'MEAS:SOURCE 2');
    fprintf(OSC,'MEAS:VRMS?');
    Temp2=fscanf(OSC);
    pause(dt);
    AmpV(i)=str2double(Temp2);
    
    V_Red(i)=V(i)/AmpV(i);
    
    
    if i>2
        V_Filt(i-1)=(V_Red(i-2)+V_Red(i-1)+V_Red(i))/3;
        Data(i-1,5)=V_Filt(i-1);
    end
    
    Data(i,2)=V(i);
    Data(i,3)=V_Red(i);
    Data(i,4)=AmpV(i);
    plot(F,V_Red,F,V_Filt)
    title(TimeString);
    grid on
    ylabel('V_R(Volts/Volt)=V_H/V_A');
    xlabel('Frequency(Hz)');
end

% % %
fclose(DMM);
fclose(FG);
fclose(OSC);
% % % 

fopen(FG);
fprintf(FG,'OUTP OFF');
%fprintf(FG,'OUTP?');
pause(dt);
%  if strcmp(fscanf(FG),'ON')
%      fprintf(FG,'OUTP OFF');
%  end
fclose(FG);

fclose(FG);
fclose(DMM);
fclose(OSC);
delete(FG);
delete(DMM);
delete(OSC);
clear FG
clear DMM
clear OSC

xlswrite(FileName,FileHeaderA,'Sheet1','A1')
xlswrite(FileName,FileHeaderB,'Sheet1','A2')
xlswrite(FileName,DataTitle,'Sheet1','A3')
xlswrite(FileName,Data,'Sheet1','A4')

