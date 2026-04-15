clear all
clc

%FFT Gyro Matlab Script Sample Position March 2021

% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
%                                           Parametros
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

COMM_PORT = 'COM3';
SystemMode = 'Encoder';
data_rate = 1; %Rango 1:1000 solo enteros.

ModeM1 = 0; %1 = Wheel  2 = Joint;   0:No change
ModeM2 = 0; %1 = Wheel  2 = Joint 0:No change
ModeM3 = 0; %1 = Wheel  2 = Joint  0:No change

LED_M1 = 1;
LED_M2 = 1;
LED_M3 = 1;


% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
%                                           1) Abro el puerto Serial
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

delete(instrfind({'Port'},{COMM_PORT}));
puerto_serial = serial(COMM_PORT,'baudrate',9600,'databits',8, 'parity','none','stopbits',1,'readasyncmode','continuous');
warning('off','MATLAB:serial:fscanf:unsuccessfulRead');
fopen(puerto_serial);

% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
%                                       Ciclo principal de lectura y
%                                           escritura
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

% 1.- Configuración e inicialización del data rate.
setMotorsConfiguration(puerto_serial,ModeM1,ModeM2,ModeM3, LED_M1,LED_M2,LED_M3);
pause(0.01);
setDataRate(puerto_serial,data_rate);

fig= figure('Name', 'FFT Gyroboard Data','Color','white');

    txt2_m1 = uicontrol('Style','text', 'Position',[40 150 80 50], 'String','Yaw:', 'FontSize',11,'BackgroundColor','white');
    Drone_Yaw = num2str(0.0);
    txt8_m1 = uicontrol('Style','text', 'Position',[40 130 80 50], 'String',Drone_Yaw, 'FontSize',11,'BackgroundColor','white');
    
    txt2_m2 = uicontrol('Style','text', 'Position',[40 110 80 50], 'String','Pitch:', 'FontSize',11,'BackgroundColor','white');
    Drone_Pitch = num2str(0.0);
    txt8_m2 = uicontrol('Style','text', 'Position',[40 90 80 50], 'String',Drone_Pitch, 'FontSize',11,'BackgroundColor','white');
    
    txt2_m3 = uicontrol('Style','text', 'Position',[40 70 80 50], 'String','Roll:', 'FontSize',11,'BackgroundColor','white');
    Drone_Roll = num2str(0.0);
    txt8_m3 = uicontrol('Style','text', 'Position',[40 50 80 50], 'String',Drone_Roll, 'FontSize',11,'BackgroundColor','white');
    
    drawnow

t=1;
while (1) %contador_muestras <= numero_muestras
     %pause(0.01);
     %clc
          
     %Gyrobaord Read
     [Data1, Data2, Data3] = getDataFromGyroboard(puerto_serial,32, SystemMode);
     
     Encoder_1 = Data1+6.2; %FFT_Roll
     Encoder_2 = Data2+1.4; %FFT_Pitch
     Encoder_3 = Data3+180; %FFT_Yaw

     e1 = deg2rad(Encoder_1);
     e2 = deg2rad(Encoder_2);
     e3 = deg2rad(Encoder_3);
     
     Rot_X = [1,       0,        0;
              0, cos(e1), -sin(e1);
              0, sin(e1),  cos(e1);];
              
     Rot_Y = [ cos(e2), 0, sin(e2);
                     0, 1,       0;
              -sin(e2), 0, cos(e2);];
              
     Rot_Z = [cos(e3), -sin(e3), 0;
              sin(e3),  cos(e3), 0;
                    0,        0, 1;];
                
     
     Rot_Global = Rot_Y*Rot_X*Rot_Z; %Cambie de orden Y por Z, y funciono
      
     i = Rot_Global*[1;0;0];
     j = Rot_Global*[0;1;0];
     k = Rot_Global*[0;0;1];
     
     i_X = i(1); i_Y = i(2); i_Z = i(3);
     j_X = j(1); j_Y = j(2); j_Z = j(3);
     k_X = k(1); k_Y = k(2); k_Z = k(3);
     
     if(k_Z>0)
         Roll = acos(sqrt(j_X^2 + j_Y^2))*sign(j_Z);
     else
         Roll = (pi-acos(sqrt(j_X^2 + j_Y^2)))*sign(j_Z);
     end
         Pitch = -acos(sqrt(i_X^2 + i_Y^2))*sign(i_Z);
     if(i_Y>0)
         Yaw = acos(i_X/sqrt(i_X^2 + i_Y^2));
     else
         Yaw = 2*pi-acos(i_X/sqrt(i_X^2 + i_Y^2));
     end
     
          
     Drone_Roll = rad2deg(Roll);
     Drone_Pitch = rad2deg(Pitch);
     Drone_Yaw = rad2deg(Yaw);
     
     %Drone_Roll = Encoder_1;
     %Drone_Pitch = Encoder_2;
     %Drone_Yaw = Encoder_3;
     
        set(txt8_m1, 'String', num2str(round(Drone_Yaw,0)));
        set(txt8_m2, 'String', num2str(round(Drone_Pitch,1)));
        set(txt8_m3, 'String', num2str(round(Drone_Roll,1)));
    
    drawnow
    
    fprintf(['Encoder 1: ' num2str(Encoder_1)  '  e1: ' num2str(e1) ' R: ' num2str(Roll) ' Roll: ' num2str(Drone_Roll) '  \n']);
    fprintf(['Encoder 2: ' num2str(Encoder_2)  '  e2: ' num2str(e2) ' P: ' num2str(Pitch) ' Pitch: ' num2str(Drone_Pitch) '  \n']);
    fprintf(['Encoder 3: ' num2str(Encoder_3)  '  e3: ' num2str(e3) ' Y: ' num2str(Yaw) ' Yaw: ' num2str(Drone_Yaw) '  \n']);
    t=t+1;
end

drawnow
fclose(puerto_serial);