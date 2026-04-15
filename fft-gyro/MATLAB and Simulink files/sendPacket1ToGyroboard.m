function  Arr = sendPacket1ToGyroboard(puerto_serial,TorqueLimM1,setTL1,MaxTorqueM1,setMT1,setTorqueEnableM1,   TorqueLimM2,setTL2,MaxTorqueM2,setMT2,setTorqueEnableM2, TorqueLimM3,setTL3,MaxTorqueM3,setMT3,setTorqueEnableM3)
%PAQUETE ESCRITURA 1

% Arr = uint8([1:32]);
coder.extrinsic('num2str'); 

%TORQUE LIMIT
set3= bitshift(setTL3,2); %Negative values of k correspond to shifting bits right (divider)
set2= bitshift(setTL2,1); %Negative values of k correspond to shifting bits right(divider)
setAux = bitor(set3,set2);
setTL = bitor(setTL1,setAux);
nop=1;

inp= de2bi(TorqueLimM1,16);
LBits_arr = inp(1,1:8);
HBits_arr = inp(1,9:16);
TL_LBitsM1 = bi2de(LBits_arr);
TL_HBitsM1 = bi2de(HBits_arr);

inp2= de2bi(TorqueLimM2,16);
LBits_arr2 = inp2(1,1:8);
HBits_arr2 = inp2(1,9:16);
TL_LBitsM2 = bi2de(LBits_arr2);
TL_HBitsM2 = bi2de(HBits_arr2);

inp3= de2bi(TorqueLimM3,16);
LBits_arr3 = inp3(1,1:8);
HBits_arr3 = inp3(1,9:16);
TL_LBitsM3 = bi2de(LBits_arr3);
TL_HBitsM3 = bi2de(HBits_arr3);

%MAX TORQUE
setmt3= bitshift(setMT3,2); %Negative values of k correspond to shifting bits right (divider)
setmt2= bitshift(setMT2,1); %Negative values of k correspond to shifting bits right(divider)
setmtAux = bitor(setmt3,setmt2);
setMT = bitor(setMT1,setmtAux);
nop=1;

inp= de2bi(MaxTorqueM1,16);
LBits_arr = inp(1,1:8);
HBits_arr = inp(1,9:16);
MT_LBitsM1 = bi2de(LBits_arr);
MT_HBitsM1 = bi2de(HBits_arr);

inp2= de2bi(MaxTorqueM2,16);
LBits_arr2 = inp2(1,1:8);
HBits_arr2 = inp2(1,9:16);
MT_LBitsM2 = bi2de(LBits_arr2);
MT_HBitsM2 = bi2de(HBits_arr2);

inp3= de2bi(MaxTorqueM3,16);
LBits_arr3 = inp3(1,1:8);
HBits_arr3 = inp3(1,9:16);
MT_LBitsM3 = bi2de(LBits_arr3);
MT_HBitsM3 = bi2de(HBits_arr3);

%Set TorqueENABLE
sette3= bitshift(setTorqueEnableM3,2); %Negative values of k correspond to shifting bits right (divider)
sette2= bitshift(setTorqueEnableM2,1); %Negative values of k correspond to shifting bits right(divider)
setmtAux = bitor(sette3,sette2);
setTorqueEnable = bitor(setTorqueEnableM1,setmtAux);
nop=1;


Arr(1,1) =  122;
Arr(1,2) =  1;%50;
Arr(1,3) =  0; %CONFIG DATA RATE
Arr(1,4) =  0;%DATA RATE

Arr(1,5) =  setTorqueEnable;%Torque Enable  %1-7

Arr(1,6) =  setTL;%Set Torque Limit
Arr(1,7) =  TL_LBitsM1;
Arr(1,8) =  TL_HBitsM1;
Arr(1,9) =  TL_LBitsM2;
Arr(1,10) =  TL_HBitsM2; 
Arr(1,11) =  TL_LBitsM3;
Arr(1,12) =  TL_HBitsM3;

Arr(1,13) =  setMT; %Set Torque Max 
Arr(1,14) =  MT_LBitsM1;
Arr(1,15) =  MT_HBitsM1;
Arr(1,16) =  MT_LBitsM2;
Arr(1,17) =  MT_HBitsM2;
Arr(1,18) =  MT_LBitsM3;
Arr(1,19) =  MT_HBitsM3;

Arr(1,20) =  0;
Arr(1,21) =  0;
Arr(1,22) =  0;
Arr(1,23) =  0;
Arr(1,24) =  0;
Arr(1,25) =  0;
Arr(1,26) =  0;
Arr(1,27) =  0;
Arr(1,28) =  0;
Arr(1,29) =  0;
Arr(1,30) =  0;

Arr(1,31) =  1; %not used
Arr(1,32) =  123;

fprintf(puerto_serial,Arr);

end