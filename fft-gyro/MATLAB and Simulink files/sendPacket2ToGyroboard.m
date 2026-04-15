function Arr = sendPacket2ToGyroboard(puerto_serial,PosM1,setPosM1,MovVel1,setVelM1,CW_AngleLimitM1,CCW_AngleLimitM1,setAngleLimitM1,PosM2,setPosM2,MovVel2,setVelM2,CW_AngleLimitM2,CCW_AngleLimitM2,setAngleLimitM2,PosM3,setPosM3,MovVel3,setVelM3,CW_AngleLimitM3,CCW_AngleLimitM3,setAngleLimitM3)

% Arr = uint8([1:32]);

%SET POSITION
set3= bitshift(setPosM3,2); %Negative values of k correspond to shifting bits right (divider)
set2= bitshift(setPosM2,1); %Negative values of k correspond to shifting bits right(divider)
setAux = bitor(set3,set2);
setPos = bitor(setPosM1,setAux);

inp= de2bi(PosM1,16);
LBits_arr = inp(1,1:8);
HBits_arr = inp(1,9:16);
LBitsM1 = bi2de(LBits_arr);
HBitsM1 = bi2de(HBits_arr);

inp2= de2bi(PosM2,16);
LBits_arr2 = inp2(1,1:8);
HBits_arr2 = inp2(1,9:16);
LBitsM2 = bi2de(LBits_arr2);
HBitsM2 = bi2de(HBits_arr2);

inp3= de2bi(PosM3,16);
LBits_arr3 = inp3(1,1:8);
HBits_arr3 = inp3(1,9:16);
LBitsM3 = bi2de(LBits_arr3);
HBitsM3 = bi2de(HBits_arr3);

%SET VELOCITY
setv3= bitshift(setVelM3,2); %Negative values of k correspond to shifting bits right (divider)
setv2= bitshift(setVelM2,1); %Negative values of k correspond to shifting bits right(divider)
setAux = bitor(setv3,setv2);
setVel = bitor(setVelM1,setAux);

inp= de2bi(MovVel1,16);
LBits_arr = inp(1,1:8);
HBits_arr = inp(1,9:16);
VLBitsM1 = bi2de(LBits_arr);
VHBitsM1 = bi2de(HBits_arr);

inp2= de2bi(MovVel2,16);
LBits_arr2 = inp2(1,1:8);
HBits_arr2 = inp2(1,9:16);
VLBitsM2 = bi2de(LBits_arr2);
VHBitsM2 = bi2de(HBits_arr2);

inp3= de2bi(MovVel3,16);
LBits_arr3 = inp3(1,1:8);
HBits_arr3 = inp3(1,9:16);
VLBitsM3 = bi2de(LBits_arr3);
VHBitsM3 = bi2de(HBits_arr3);


%ANGLE LIMIT CW AND CCW
setal3= bitshift(setAngleLimitM3,4); %Negative values of k correspond to shifting bits right (divider)
setal2= bitshift(setAngleLimitM2,2); %Negative values of k correspond to shifting bits right(divider)
setAux = bitor(setal3,setal2);
setAL = bitor(setAngleLimitM1,setAux);
nop=1;

inp= de2bi(CW_AngleLimitM1,16);
LBits_arr = inp(1,1:8);
HBits_arr = inp(1,9:16);
ACW_LBitsM1 = bi2de(LBits_arr);
ACW_HBitsM1 = bi2de(HBits_arr);

inp= de2bi(CCW_AngleLimitM1,16);
LBits_arr = inp(1,1:8);
HBits_arr = inp(1,9:16);
ACCW_LBitsM1 = bi2de(LBits_arr);
ACCW_HBitsM1 = bi2de(HBits_arr);

inp= de2bi(CW_AngleLimitM2,16);
LBits_arr = inp(1,1:8);
HBits_arr = inp(1,9:16);
ACW_LBitsM2 = bi2de(LBits_arr);
ACW_HBitsM2 = bi2de(HBits_arr);

inp= de2bi(CCW_AngleLimitM2,16);
LBits_arr = inp(1,1:8);
HBits_arr = inp(1,9:16);
ACCW_LBitsM2 = bi2de(LBits_arr);
ACCW_HBitsM2 = bi2de(HBits_arr);

inp= de2bi(CW_AngleLimitM3,16);
LBits_arr = inp(1,1:8);
HBits_arr = inp(1,9:16);
ACW_LBitsM3 = bi2de(LBits_arr);
ACW_HBitsM3 = bi2de(HBits_arr);

inp= de2bi(CCW_AngleLimitM3,16);
LBits_arr = inp(1,1:8);
HBits_arr = inp(1,9:16);
ACCW_LBitsM3 = bi2de(LBits_arr);
ACCW_HBitsM3 = bi2de(HBits_arr);

Arr(1,1) =  122;
Arr(1,2) =  2;

Arr(1,3) =  setAL; %SET ANGLE LIMIT   0:0° 512:150°  a 1023:300°   
Arr(1,4) =  ACW_LBitsM1; %CW M1
Arr(1,5) =  ACW_HBitsM1; %CW M1
Arr(1,6) =  ACW_LBitsM2; %CW M2
Arr(1,7) =  ACW_HBitsM2; %CW M2
Arr(1,8) =  ACW_LBitsM3; %CW M3 
Arr(1,9) =  ACW_HBitsM3; %CW M3

Arr(1,10) =  ACCW_LBitsM1; %CCW M1
Arr(1,11) =  ACCW_HBitsM1; %CCW M1
Arr(1,12) =  ACCW_LBitsM2; %CCW M2
Arr(1,13) =  ACCW_HBitsM2; %CCW M2
Arr(1,14) =  ACCW_LBitsM3; %CCW M3
Arr(1,15) =  ACCW_HBitsM3; %CCW M3

Arr(1,16) =  setVel; %SET MOVING SPEED
Arr(1,17) =  VLBitsM1;
Arr(1,18) =  VHBitsM1;
Arr(1,19) =  VLBitsM2;
Arr(1,20) =  VHBitsM2;
Arr(1,21) =  VLBitsM3;
Arr(1,22) =  VHBitsM3;

Arr(1,23) =  setPos; %SET POSITION
Arr(1,24) =  LBitsM1;
Arr(1,25) =  HBitsM1;
Arr(1,26) =  LBitsM2;
Arr(1,27) =  HBitsM2;
Arr(1,28) =  LBitsM3;
Arr(1,29) =  HBitsM3;

Arr(1,30) =  0;
Arr(1,31) =  0; %not used
Arr(1,32) =  123;

fprintf(puerto_serial,Arr);

end