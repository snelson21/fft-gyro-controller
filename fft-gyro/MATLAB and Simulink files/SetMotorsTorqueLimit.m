function y = SetMotorsTorqueLimit(puerto_serial,TorqueLimM1,setTL1,MaxTorqueM1,setMT1,setTorqueEnableM1,   TorqueLimM2,setTL2,MaxTorqueM2,setMT2,setTorqueEnableM2, TorqueLimM3,setTL3,MaxTorqueM3,setMT3,setTorqueEnableM3)
% Write Packet 1

Arr = ([1:32]);
coder.extrinsic('num2str'); 

%TORQUE LIMIT
set3= bitshift(setTL3,2); 
set2= bitshift(setTL2,1); 
setAux = bitor(set3,set2);
setTL = bitor(setTL1,setAux);

inp= de2bi(TorqueLimM1,16);
LBits_arr = inp(1,1:8);
HBits_arr = inp(1,9:16);

TL_LBitsM1 = bi2de(LBits_arr);
TL_HBitsM1 = bi2de(HBits_arr);
%TL_LBitsM1 = binaryToDecimal(LBits_arr,'LSB');  %2017
%TL_HBitsM1 = binaryToDecimal(HBits_arr,'LSB');  %2017

inp2= de2bi(TorqueLimM2,16);
LBits_arr2 = inp2(1,1:8);
HBits_arr2 = inp2(1,9:16);
TL_LBitsM2 = bi2de(LBits_arr2);
TL_HBitsM2 = bi2de(HBits_arr2);
%TL_LBitsM2 = binaryToDecimal(LBits_arr2,'LSB');  %2017
%TL_HBitsM2 = binaryToDecimal(HBits_arr2,'LSB');  %2017

inp3= de2bi(TorqueLimM3,16);
LBits_arr3 = inp3(1,1:8);
HBits_arr3 = inp3(1,9:16);
TL_LBitsM3 = bi2de(LBits_arr3);
TL_HBitsM3 = bi2de(HBits_arr3);
%TL_LBitsM3 = binaryToDecimal(LBits_arr3,'LSB');  %2017
%TL_HBitsM3 = binaryToDecimal(HBits_arr3,'LSB');  %2017

%MAX TORQUE
setmt3      = bitshift(setMT3,2); 
setmt2      = bitshift(setMT2,1); 
setmtAux    = bitor(setmt3,setmt2);
setMT       = bitor(setMT1,setmtAux);

inp         = de2bi(MaxTorqueM1,16);
LBits_arr   = inp(1,1:8);
HBits_arr   = inp(1,9:16);
MT_LBitsM1 = bi2de(LBits_arr);
MT_HBitsM1 = bi2de(HBits_arr);
%MT_LBitsM1 = binaryToDecimal(LBits_arr,'LSB');  %2017
%MT_HBitsM1 = binaryToDecimal(HBits_arr,'LSB');  %2017

inp2        = de2bi(MaxTorqueM2,16);
LBits_arr2  = inp2(1,1:8);
HBits_arr2  = inp2(1,9:16);
MT_LBitsM2 = bi2de(LBits_arr2);
MT_HBitsM2 = bi2de(HBits_arr2);
%MT_LBitsM2 = binaryToDecimal(LBits_arr2,'LSB');  %2017
%MT_HBitsM2 = binaryToDecimal(HBits_arr2,'LSB');  %2017

inp3        = de2bi(MaxTorqueM3,16);
LBits_arr3  = inp3(1,1:8);
HBits_arr3  = inp3(1,9:16);
MT_LBitsM3  = bi2de(LBits_arr3);
MT_HBitsM3  = bi2de(HBits_arr3);
%MT_LBitsM3 = binaryToDecimal(LBits_arr3,'LSB');  %2017
%MT_HBitsM3 = binaryToDecimal(HBits_arr3,'LSB');  %2017

%Set TorqueENABLE
sette3          = bitshift(setTorqueEnableM3,2); 
sette2          = bitshift(setTorqueEnableM2,1); 
setmtAux        = bitor(sette3,sette2);
setTorqueEnable = bitor(setTorqueEnableM1,setmtAux);

Arr(1,1) =  122;
Arr(1,2) =  1;
Arr(1,3) =  0;  
Arr(1,4) =  0;  
Arr(1,5) =  setTorqueEnable;  
Arr(1,6) =  setTL;
Arr(1,7) = TL_LBitsM1;
Arr(1,8) = TL_HBitsM1;
Arr(1,9) = TL_LBitsM2;
Arr(1,10) =TL_HBitsM2; 
Arr(1,11) = TL_LBitsM3;
Arr(1,12) = TL_HBitsM3;
Arr(1,13) =  setMT; 
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
Arr(1,31) =  1;
Arr(1,32) =  123;

fprintf(puerto_serial,Arr);

y = Arr;