clear all
clc

%FFT Gyro Matlab Script Sample Position March 2021

% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
%                                           Parametros
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

COMM_PORT = 'COM3'; %Change COM number to match the assigned port to the FFT GYRO.
SystemMode = 'Motor';
data_rate = 10; %Rango 1:1000 solo enteros.
Samples = 30000;

ModeM1 = 2; %1 = Wheel  2 = Joint  0:No change
ModeM2 = 2; %1 = Wheel  2 = Joint  0:No change
ModeM3 = 2; %1 = Wheel  2 = Joint  0:No change

LED_M1 = 1;
LED_M2 = 1;
LED_M3 = 1;

%Torque
TorqueLimM1 = 512; %Recommended to start at low torques (512 = 50%), and once tested, gradually increase torque to full capacity (1023 = 100%).
setTL1      = 0;
MaxTorqueM1 = 512; %Recommended to start at low torques (512 = 50%), and once tested, gradually increase torque to full capacity (1023 = 100%).
setMT1      = 0;
setTorqueEnableM1 = 1;

TorqueLimM2 = 512; %Recommended to start at low torques (512 = 50%), and once tested, gradually increase torque to full capacity (1023 = 100%).
setTL2      = 0;
MaxTorqueM2 = 512; %Recommended to start at low torques (512 = 50%), and once tested, gradually increase torque to full capacity (1023 = 100%).
setMT2      = 0;
setTorqueEnableM2 = 1;

TorqueLimM3 = 512; %Recommended to start at low torques (512 = 50%), and once tested, gradually increase torque to full capacity (1023 = 100%).
setTL3      = 0;
MaxTorqueM3 = 512; %Recommended to start at low torques (512 = 50%), and once tested, gradually increase torque to full capacity (1023 = 100%).
setMT3      = 0;
setTorqueEnableM3 = 1;

Testpos = 512*1;

%Position
PosM1=Testpos;
setPosM1=1;
MovVel1=44; %Avoid velocities higher than 260 (~30RPM) that might damage the motors.
setVelM1=1;
CW_AngleLimitM1=1;
CCW_AngleLimitM1=1023;
setAngleLimitM1=3;%Set angle limits  1:CW  2:CCW   3:Both CW and CCW

PosM2=Testpos;
setPosM2=1;
MovVel2=44; %Avoid velocities higher than 260 (~30RPM) that might damage the motors.
setVelM2=1;
CW_AngleLimitM2=1;
CCW_AngleLimitM2=1023;
setAngleLimitM2=3;%Set angle limits  1:CW  2:CCW   3:Both CW and CCW

PosM3=Testpos;
setPosM3=1;
MovVel3=44; %Avoid velocities higher than 260 (~30RPM) that might damage the motors.
setVelM3=1;
CW_AngleLimitM3=1;
CCW_AngleLimitM3=1023;
setAngleLimitM3=3;%Set angle limits  1:CW  2:CCW   3:Both CW and CCW

% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
%                                           Inicializaci�n
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


Y =  zeros(1,Samples, 'uint8');
X =  zeros(1,Samples);

ZeroRelativo = [0,0,0];

% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
%                                           1) Abro el puerto Serial
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

delete(instrfind({'Port'},{COMM_PORT}));
puerto_serial = serial(COMM_PORT,'baudrate',9600,'databits',8, 'parity','none','stopbits',1,'readasyncmode','continuous');
warning('off','MATLAB:serial:fscanf:unsuccessfulRead');
%Abro el puerto Serial
fopen(puerto_serial);

% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
%                                       Ciclo principal de lectura y
%                                           escritura
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

% 1.- Configuraci�n e inicializaci�n del data rate.
setMotorsConfiguration(puerto_serial,ModeM1,ModeM2,ModeM3, LED_M1,LED_M2,LED_M3);
pause(0.05);
setDataRate(puerto_serial,data_rate);
pause(0.05);
sendPacket1ToGyroboard(puerto_serial,TorqueLimM1,setTL1,MaxTorqueM1,setMT1,setTorqueEnableM1, TorqueLimM2,setTL2,MaxTorqueM2,setMT2,setTorqueEnableM2, TorqueLimM3,setTL3,MaxTorqueM3,setMT3,setTorqueEnableM3);          %0-1023  CCW  y 1024-2047 CW
pause(0.05);
sendPacket2ToGyroboard(puerto_serial,PosM1,setPosM1,MovVel1,setVelM1,CW_AngleLimitM1,CCW_AngleLimitM1,setAngleLimitM1,PosM2,setPosM2,MovVel2,setVelM2,CW_AngleLimitM2,CCW_AngleLimitM2,setAngleLimitM2,PosM3,setPosM3,MovVel3,setVelM3,CW_AngleLimitM3,CCW_AngleLimitM3,setAngleLimitM3);
pause(0.05);

[Data1, Data2, Data3] = getDataFromGyroboard(puerto_serial,32, SystemMode);
pause(0.05);

delta = 1;

while(abs(Data1(4)-PosM1)>delta&&abs(Data2(4)-PosM2)>delta&&abs(Data3(4)-PosM3)>delta)
    [Data1, Data2, Data3] = getDataFromGyroboard(puerto_serial,32, SystemMode);
    pause(0.05);
end

fclose(puerto_serial);
