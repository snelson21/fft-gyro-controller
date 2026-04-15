

/*********************************************/
/*              SET POSIITON                 */
/*********************************************/

public void SetPositionCallbak(){
  SetPosition(7,7);
}

public void SetPosition(int setVelin, int setPosin){
  //println("Set Position!");
  /*
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
  Arr(1,32) =  123;*/
  
  int Max   = int(MotorRepBytes);//4095;//4095;//1023
  float res = MotorRes; //0.088;// 0.088; //0.2932
  
  //Position
  int slM1 = int(SliderM1.getValue()/res);// /0.2932);
  int slM2 = int(SliderM2.getValue()/res);// /0.2932);
  int slM3 = int(SliderM3.getValue()/res);// /0.2932);
  
  
  if(slM1>Max){
    slM1=Max;//1023;
  }
  
  if(slM2>Max){
    slM2=Max;
  }
  
  if(slM3>Max){
    slM3=Max;
  }
  
  println("Setting Position  PosM1= " + slM1 + " PosM2= " + slM2 + "  PosM3= " + slM3);

  //Moving Speed
  int slMSM1 =  (int)(float(Integer.parseInt(MovingSpeedTextFieldM1.getText()))/0.1113);
  int slMSM2 =  (int)(float(Integer.parseInt(MovingSpeedTextFieldM2.getText()))/0.1113);
  int slMSM3 =  (int)(float(Integer.parseInt(MovingSpeedTextFieldM3.getText()))/0.1113);
  
  if(slMSM1>1023){
    slMSM1 = 1023;
  }else if(slMSM1<0){
    slMSM1 = 0;
  }
  
  if(slMSM2>1023){
    slMSM2 = 1023;
  }else if(slMSM2<0){
    slMSM2 = 0;
  }
  
  if(slMSM3>1023){
    slMSM3 = 1023;
  }else if(slMSM3<0){
    slMSM3 = 0;
  }
  
  ModeMotorJointWheel = 1;
    
  /*char setAL = char(0); //char(63)
  char ACW_LBitsM1=1;
  char ACW_HBitsM1=0;
  char ACW_LBitsM2=1;
  char ACW_HBitsM2=0;
  char ACW_LBitsM3=1;
  char ACW_HBitsM3=0;
  
  char ACCW_LBitsM1=char(0xFF);
  char ACCW_HBitsM1=char(0x03);
  char ACCW_LBitsM2=char(0xFF);
  char ACCW_HBitsM2=char(0x03);
  char ACCW_LBitsM3=char(0xFF);
  char ACCW_HBitsM3=char(0x03);
  
  char setVel = char(7);
  char VLBitsM1 = char(byte(slMSM1));
  char VHBitsM1 = char(byte(slMSM1>>8));
  char VLBitsM2 = char(byte(slMSM2));
  char VHBitsM2 = char(byte(slMSM2>>8));
  char VLBitsM3 = char(byte(slMSM3));
  char VHBitsM3 = char(byte(slMSM3>>8));
  
  char setPos = char(7);//char(7);
  char PLBitsM1= char(byte(slM1));
  char PHBitsM1= char(byte(slM1>>8));
  char PLBitsM2= char(byte(slM2));
  char PHBitsM2= char(byte(slM2>>8));
  char PLBitsM3= char(byte(slM3));
  char PHBitsM3= char(byte(slM3>>8));
  
  String slM1_hex="";
  String hh = hex(slM2,4); 
  int len = hh.length();
  for(int i=0;i<len;i++){
    char c1 = hh.charAt(len-1-i);
    slM1_hex = slM1_hex + c1;
  }
  
  //String Data2SendVel ="" + char(122) + char(2) + setAL + ACW_LBitsM1 + ACW_HBitsM1 + ACW_LBitsM2 + ACW_HBitsM2 + ACW_LBitsM3 + ACW_HBitsM3 + ACCW_LBitsM1 + ACCW_HBitsM1 + ACCW_LBitsM2 + ACCW_HBitsM2 + ACCW_LBitsM3 + ACCW_HBitsM3 + setVel + VLBitsM1 + VHBitsM1+ VLBitsM2 + VHBitsM2+ VLBitsM3 + VHBitsM3 + setPos + PLBitsM1 + PHBitsM1+ PLBitsM2 + PHBitsM2+ PLBitsM3 + PHBitsM3 + char(0) + char(0) + char(123);
  //String Data2SendPos ="" + char(122) + char(2) + setAL + ACW_LBitsM1 + ACW_HBitsM1 + ACW_LBitsM2 + ACW_HBitsM2 + ACW_LBitsM3 + ACW_HBitsM3 + ACCW_LBitsM1 + ACCW_HBitsM1 + ACCW_LBitsM2 + ACCW_HBitsM2 + ACCW_LBitsM3 + ACCW_HBitsM3 + setVel + VLBitsM1 + VHBitsM1+ VLBitsM2 + VHBitsM2+ VLBitsM3 + VHBitsM3 + setPos + PLBitsM1 + PHBitsM1+ PLBitsM2 + PHBitsM2+ PLBitsM3 + PHBitsM3 + char(0) + char(0) + char(123);
  //String Data2SendPos ="" + char(122) + char(2) + setAL + ACW_LBitsM1 + ACW_HBitsM1 + ACW_LBitsM2 + ACW_HBitsM2 + ACW_LBitsM3 + ACW_HBitsM3 + ACCW_LBitsM1 + ACCW_HBitsM1 + ACCW_LBitsM2 + ACCW_HBitsM2 + ACCW_LBitsM3 + ACCW_HBitsM3 + setVel + VLBitsM1 + VHBitsM1+ VLBitsM2 + VHBitsM2+ VLBitsM3 + VHBitsM3 + setPos + PLBitsM1 + PHBitsM1 + PLBitsM2 + PHBitsM2 + PLBitsM3 + PHBitsM3 + char(0) + char(0) + char(123);
  //println("----->>>>" + "" + hex(char(122),2) + "  " + hex(char(2),2)+ "  " + hex(setAL,2)+ "  " + hex(ACW_LBitsM1,2)+ "  " + hex(ACW_HBitsM1,2)+ "  " + hex(ACW_LBitsM2,2)+ "  " + hex(ACW_HBitsM2,2)+ "  " + hex(ACW_LBitsM3,2)+ "  " + hex(ACW_HBitsM3,2)+ "  " + hex(ACCW_LBitsM1,2)+ "  " + hex(ACCW_HBitsM1,2)+ "  " + hex(ACCW_LBitsM2,2)+ "  " + hex(ACCW_HBitsM2,2)+ "  " + hex(ACCW_LBitsM3,2)+ "  " + hex(ACCW_HBitsM3,2)+ "  " + hex(setVel,2)+ "  " + hex(VLBitsM1,2)+ "  " + hex(VHBitsM1,2)+ "  " + hex(VLBitsM2,2)+ "  " + hex(VHBitsM2,2)+ "  " + hex(VLBitsM3,2)+ "  " + hex(VHBitsM3,2)+ "  " + hex(setPos,2)+ "  " + hex(PLBitsM1,2)+ "  " + hex(PHBitsM1,2)+ "  " + hex(PLBitsM2,2)+ "  " + hex(PHBitsM2,2)+ "  " + hex(PLBitsM3,2)+ "  " + hex(PHBitsM3,2)+ "  " + hex(char(0),2)+ "  " + hex(char(0),2)+ "  " + hex(char(123),2)+ "  ");
  
  //println("--->>>slM1_hex_old: " + hh + "  Length:" + len + "  slM1_hex: " + slM1_hex + " LSB:" + (slM1_hex));  
  //println("slMSM1: " + slMSM1 + " slMSM2: " + slMSM2 + " slMSM3: " + slMSM3 +" ModeMotorJointWheel:"+ModeMotorJointWheel);
  //println("Length: " + Data2SendPos.length() + ":  " + Data2SendPos);
  
  Write2Port(Data2SendVel);
  delay(200);
  Write2Port(Data2SendPos);*/
  
  byte[] Packet =  new byte[32];
  Packet[0] = byte((0x7A));    //122
  Packet[1] = byte((0x02));    //2
  Packet[2] = byte((0x00));    //setAl  0X00
  Packet[3] = byte((0x01));    //ACW_LBitsM1
  Packet[4] = byte((0x00));    //ACW_HBitsM1
  Packet[5] = byte((0x01));    //ACW_LBitsM2
  Packet[6] = byte((0x00));    //ACW_HBitsM2
  Packet[7] = byte((0x01));    //ACW_HBitsM3
  Packet[8] = byte((0x00));    //ACW_HBitsM3
  
  /*Packet[9] =  byte((int(MotorRepBytes)));//byte((0xFF));    //ACCW_LBitsM1
  Packet[10] = byte((int(MotorRepBytes)>>8)); //byte((0x0F));   //ACCW_HBitsM1  0X03
  Packet[11] = byte((int(MotorRepBytes)));//byte((0xFF));   //ACCW_LBitsM2
  Packet[12] = byte((int(MotorRepBytes)>>8)); //byte((0x0F));   //ACCW_HBitsM2  0X03
  Packet[13] = byte((int(MotorRepBytes)));//byte((0xFF));   //ACCW_HBitsM3
  Packet[14] = byte((int(MotorRepBytes)>>8)); //byte((0x0F));   //ACCW_HBitsM3  0X03*/
  
  Packet[9]  = byte((0xFF));    //ACCW_LBitsM1
  Packet[10] = byte((0x03));   //ACCW_HBitsM1  0X03
  Packet[11] = byte((0xFF));   //ACCW_LBitsM2
  Packet[12] = byte((0x03));   //ACCW_HBitsM2  0X03
  Packet[13] = byte((0xFF));   //ACCW_HBitsM3
  Packet[14] = byte((0x03));   //ACCW_HBitsM3  0X03
  
  Packet[15] = byte((setVelin));   //0x07 setVel
  Packet[16] = byte((slMSM1));   //VLBitsM1
  Packet[17] = byte((slMSM1>>8));   //VHBitsM1
  Packet[18] = byte((slMSM2));   //VLBitsM2
  Packet[19] = byte((slMSM2>>8));   //VHBitsM2
  Packet[20] = byte((slMSM3));   //VLBitsM3
  Packet[21] = byte((slMSM3>>8));   //VHBitsM3
  Packet[22] = byte((setPosin));   //0x07 SetPos
  Packet[23] = byte((slM1));   //M1 LSB
  Packet[24] = byte((slM1>>8));   //M1 MSB
  Packet[25] = byte((slM2));   //M2 LSB 0xFF  0X9B
  Packet[26] = byte((slM2>>8));   //M2 MSB 0X01
  Packet[27] = byte((slM3));   //M3 LSB 0xff
  Packet[28] = byte((slM3>>8));   //M3 MSB 0x01
  Packet[29] = byte((0x00));   //0
  Packet[30] = byte((0x00));   //0
  Packet[31] = byte((0x7B));   //123
  
  delay(100);  
  Write2PortBytes(Packet);
  delay(100);//250//100
  
  //println(Packet[23] + "," + Packet[24]);
}



/*********************************************/
/*               SET VELOCITY                */
/*********************************************/

public void SetVelocity(){
  //println("Set Velocity!");
/*
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
Arr(1,32) =  123;*/


  if(ModeMotorJointWheel==0){
    setConfigurationPacket(1,1,1,1,1,1);
    WheelModeSetVelocity('7',0,0,0);
  }else if(ModeMotorJointWheel==1){//Modo Joint
    setConfigurationPacket(1,1,1,1,1,1);
    WheelModeSetVelocity('7',0,0,0);
  }
  
  ModeMotorJointWheel = 2;
  
  int slM1 = int(SliderVM1.getValue());
  if(slM1<0){
    slM1= 1024 - slM1;
  }
  
  int slM2 = int(SliderVM2.getValue());
  if(slM2<0){
    slM2 = 1024 - slM2;
  }
  
  int slM3 = int(SliderVM3.getValue());
  if(slM3<0){
    slM3 = 1024 - slM3;
  }
  
  
  
  
  /*byte LSB_M1 = byte(slM1);//(SM1_str.substring(0,7));
  byte MSB_M1 = byte(slM1>>8);//(SM1_str.substring(8,15));
  char LSB_M1ch = char(LSB_M1);//(SM1_str.substring(0,7));
  char MSB_M1ch = char(MSB_M1);//(SM1_str.substring(8,15));
  
  byte LSB_M2 = byte(slM2);//(SM1_str.substring(0,7));
  byte MSB_M2 = byte(slM2>>8);//(SM1_str.substring(8,15));
  char LSB_M2ch = char(LSB_M2);//(SM1_str.substring(0,7));
  char MSB_M2ch = char(MSB_M2);//(SM1_str.substring(8,15));
  
  byte LSB_M3 = byte(slM3);//(SM1_str.substring(0,7));
  byte MSB_M3 = byte(slM3>>8);//(SM1_str.substring(8,15));
  char LSB_M3ch = char(LSB_M3);//(SM1_str.substring(0,7));
  char MSB_M3ch = char(MSB_M3);//(SM1_str.substring(8,15));*/
  
  //println("setelocity: slider M1:" + slM1 + " slider M2:" + slM2 + " slider M3: " + slM3 );//+ "" + " LSB: " + LSB_M1ch + "  MSB: " + MSB_M1ch);
  
  
  char setAL = char(0); //char(63);
  char ACW_LBitsM1=0;
  char ACW_HBitsM1=0;
  char ACW_LBitsM2=0;
  char ACW_HBitsM2=0;
  char ACW_LBitsM3=0;
  char ACW_HBitsM3=0;
  
  char ACCW_LBitsM1=char(0x00);
  char ACCW_HBitsM1=char(0x00);
  char ACCW_LBitsM2=char(0x00);
  char ACCW_HBitsM2=char(0x00);
  char ACCW_LBitsM3=char(0x00);
  char ACCW_HBitsM3=char(0x00);

  char setVel = char(7);
  char VLBitsM1= char(byte(slM1));    //LSB_M1ch;
  char VHBitsM1= char(byte(slM1>>8)); //MSB_M1ch;
  char VLBitsM2= char(byte(slM2));    //LSB_M2ch;
  char VHBitsM2= char(byte(slM2>>8)); //MSB_M2ch;
  char VLBitsM3= char(byte(slM3));    //LSB_M3ch;
  char VHBitsM3= char(byte(slM3>>8));    //MSB_M3ch;
  
  char setPos = char(0);
  char PLBitsM1 = 0;
  char PHBitsM1 = 0;
  char PLBitsM2 = 0;
  char PHBitsM2 = 0;
  char PLBitsM3 = 0;
  char PHBitsM3 = 0;
  
  
  //println("SET VELOCITY!!!!");
  //println("SET VELOCITY: slider M1:" + slM1 + " slider M2:" + slM2 + " slider M3: " + slM3 );//+ "" + " LSB: " + LSB_M1ch + "  MSB: " + MSB_M1ch);
  if(slM1>0 || slM2>0 || slM3>0){    
    setModeJW.lock();
    setModeJW.setColorBackground(color(100,100,100));
  }else if(slM1==0 && slM2==0 && slM3==0){
    setModeJW.unlock();
    setModeJW.setColorBackground(color(0,45,90));
  }
  
  
  //String Data2Send ="" + char(122) + char(2) + setAL + ACW_LBitsM1 + ACW_HBitsM1 + ACW_LBitsM2 + ACW_HBitsM2 + ACW_LBitsM3 + ACW_HBitsM3 + ACCW_LBitsM1 + ACCW_HBitsM1 + ACCW_LBitsM2 + ACCW_HBitsM2 + ACCW_LBitsM3 + ACCW_HBitsM3 + setVel + VLBitsM1 + VHBitsM1+ VLBitsM2 + VHBitsM2+ VLBitsM3 + VHBitsM3 + setPos + PLBitsM1 + PHBitsM1+ PLBitsM2 + PHBitsM2+ PLBitsM3 + PHBitsM3 + char(0) + char(0) + char(123);
  //println("slM1: " + slM1 + " LSB:" + ((slM1)) + "  MSB:" + int(byte(slM1>>8)) + " VLBitsM1:" + byte(VLBitsM1) + " VHBitsM1:" + byte(VHBitsM1));
  //Write2Port(Data2Send);
    
  
  byte[] Packet =  new byte[32];
  Packet[0] = byte((0x7A));    //122
  Packet[1] = byte((0x02));    //2
  Packet[2] = byte((0x00));    //setAl
  Packet[3] = byte((0x00));    //ACW_LBitsM1
  Packet[4] = byte((0x00));    //ACW_HBitsM1
  Packet[5] = byte((0x00));    //ACW_LBitsM2
  Packet[6] = byte((0x00));    //ACW_HBitsM2
  Packet[7] = byte((0x00));    //ACW_HBitsM3
  Packet[8] = byte((0x00));    //ACW_HBitsM3
  Packet[9] = byte((0x00));    //ACCW_LBitsM1
  Packet[10] = byte((0x00));   //ACCW_HBitsM1
  Packet[11] = byte((0x00));   //ACCW_LBitsM2
  Packet[12] = byte((0x00));   //ACCW_HBitsM2
  Packet[13] = byte((0x00));   //ACCW_HBitsM3
  Packet[14] = byte((0x00));   //ACCW_HBitsM3
  Packet[15] = byte((0x07));   //setVel
  Packet[16] = byte((slM1));   //VLBitsM1
  Packet[17] = byte((slM1>>8));   //VHBitsM1
  Packet[18] = byte((slM2));   //VLBitsM2
  Packet[19] = byte((slM2>>8));   //VHBitsM2
  Packet[20] = byte((slM3));   //VLBitsM3
  Packet[21] = byte((slM3>>8));   //VHBitsM3
  Packet[22] = byte((0x00));   //SetPos
  Packet[23] = byte((0x00));   //M1 LSB
  Packet[24] = byte((0x00));   //M1 MSB
  Packet[25] = byte((0x00));   //M2 LSB 0xFF  0X9B
  Packet[26] = byte((0x00));   //M2 MSB 0X01
  Packet[27] = byte((0x00));   //M3 LSB 0xff
  Packet[28] = byte((0x00));   //M3 MSB 0x01
  Packet[29] = byte((0x00));   //0
  Packet[30] = byte((0x00));   //0
  Packet[31] = byte((0x7B));   //123  
  delay(150);  
  Write2PortBytes(Packet);
  delay(200);
}

/*********************************************/
/*            SET TORQUE LIMIT               */
/*********************************************/

void SetTorque(){
 
  int aux1 = (int)TorqueEnable1.getValue();
  int aux2 = (int)TorqueEnable2.getValue();
  int aux3 = (int)TorqueEnable3.getValue();
  
  boolean FlagTorqueEnable1 = false;
  boolean FlagTorqueEnable2 = false;
  boolean FlagTorqueEnable3 = false;
  
  if(aux1==1){
    FlagTorqueEnable1 = true;
  }
  if(aux2==1){
    FlagTorqueEnable2 = true;
  }
  if(aux3==1){
    FlagTorqueEnable3 = true;
  }
  
  
  
  /*if(ModeMotorJointWheel==2){
    
    //WheelMode: Set Velocity =0 
    WheelModeSetVelocity('7',0,0,0);
    delay(300);
    
    //SetTorque();
    //delay(300);
    
    //JointModeSetPacket(char(0),char(7),0,0,0, slMSM1,slMSM2,slMSM3);//(char setPos,char setVel,int PosM1,int PosM2, int PosM3, int VelM1,int VelM2,int VelM3)
    //delay(100);  
  }
  
  
  setConfigurationPacket(1,1,1,2,2,2);
  delay(300);*/
  
  //0,100
  setWritePacket1(0, 10, FlagTorqueEnable1,FlagTorqueEnable2, FlagTorqueEnable3,true, true, true, false,false,false);//(int setDatarate, int mSeg, boolean TE1, boolean TE2, boolean TE3, boolean sTL1, boolean sTL2, boolean sTL3, boolean sTM1, boolean sTM2, boolean sTM3)
 
  //ModeMotorJointWheel=1;    //1=JOINT    2=WHEEL
}




/*********************************************/
/*                MAX TORQUE                 */
/*********************************************/
void SetMaxTorque(){
  
  int aux1 = (int)TorqueEnable1.getValue();
  int aux2 = (int)TorqueEnable2.getValue();
  int aux3 = (int)TorqueEnable3.getValue();
  
  boolean FlagTorqueEnable1 = false;
  boolean FlagTorqueEnable2 = false;
  boolean FlagTorqueEnable3 = false;
  
  if(aux1==1){
    FlagTorqueEnable1 = true;
  }
  if(aux2==1){
    FlagTorqueEnable2 = true;
  }
  if(aux3==1){
    FlagTorqueEnable3 = true;
  }
  
  setWritePacket1(0, 10, FlagTorqueEnable1,FlagTorqueEnable2, FlagTorqueEnable3,false, false, false, true,true,true);//(int setDatarate, int mSeg, boolean TE1, boolean TE2, boolean TE3, boolean sTL1, boolean sTL2, boolean sTL3, boolean sTM1, boolean sTM2, boolean sTM3)
  ModeMotorJointWheel=1;
}




/*********************************************/
/*        CONFIGURATION PACKET               */
/*********************************************/

void setConfigurationPacket(int sMode1,int sMode2, int sMode3, int mMode1,int mMode2, int mMode3){
  
  char setMode1 = char(48); //48=0   49=1;
  int sm1= 48;
  if(sMode1 == 1){
    setMode1 = char(49); 
    sm1= 49;
  }
  
  char setMode2 = char(48); //48=0   49=1;
  int sm2= 48;
  if(sMode2 == 1){
    setMode2 = char(49);
    sm2= 49;
  }
  char setMode3 = char(48); //48=0   49=1;
  int sm3 = 48;
  if(sMode3 == 1){
    setMode3 = char(49);
    sm3= 49;
  }
    
  char Mode1 = char(48);
  int mm1= 48;
  if(mMode1==1){
    Mode1 = char(49);
    mm1= 49;
  }else if(mMode1==2){
    Mode1 = char(50);
    mm1= 50;
  }
  
  char Mode2 = char(48);
  int mm2= 48;
  if(mMode2==1){
    Mode2 = char(49);
    mm2 = 49;
  }else if(mMode2==2){
    Mode2 = char(50);
    mm2= 50;
  }
  
  char Mode3 = char(48);
  int mm3 = 48;
  if(mMode3==1){
    Mode3 = char(49);
    mm3 = 49;
  }else if(mMode3==2){
    Mode3 = char(50);
    mm3 = 50;
  }
    
  /*String Data2Send ="" + char(122) + char(3) + setMode1 + setMode2 + setMode3 + Mode1 + Mode2 + Mode3 + char(0)+ char(0)+ char(0)+ char(0)+ char(0)+ char(0)+ char(49)+ char(49)+ char(49)+ char(0)+ char(0)+ char(0)+ char(0)+ char(0)+ char(0)+ char(0)+ char(0)+ char(0)+ char(0)+ char(0)+ char(0)+ char(0)+ char(1) + char(123);
  Write2Port(Data2Send);  
  delay(300);*/
    
  byte[] Packet =  new byte[32];
  Packet[0] = byte((0x7A));    //122
  Packet[1] = byte((0x03));    //3
  Packet[2] = byte((sm1));    //setMode1
  Packet[3] = byte((sm2));    //setMode2
  Packet[4] = byte((sm3));    //setMode3
  Packet[5] = byte((mm1));    //Mode1
  Packet[6] = byte((mm2));    //Mode2
  Packet[7] = byte((mm3));    //Mode3
  Packet[8] = byte((0x00));    //0
  Packet[9] = byte((0x00));    //0
  Packet[10] = byte((0x00));   //0
  Packet[11] = byte((0x00));   //0
  Packet[12] = byte((0x00));   //0
  Packet[13] = byte((0x00));   //0
  Packet[14] = byte((0x31));   //49
  Packet[15] = byte((0x31));   //49
  Packet[16] = byte((0x31));   //49
  Packet[17] = byte((0x00));   //0
  Packet[18] = byte((0x00));   //0
  Packet[19] = byte((0x00));   //0
  Packet[20] = byte((0x00));   //0
  Packet[21] = byte((0x00));   //0
  Packet[22] = byte((0x00));   //0
  Packet[23] = byte((0x00));   //0
  Packet[24] = byte((0x00));   //0
  Packet[25] = byte((0x00));   //0
  Packet[26] = byte((0x00));   //0
  Packet[27] = byte((0x00));   //0
  Packet[28] = byte((0x00));   //0
  Packet[29] = byte((0x00));   //0
  Packet[30] = byte((0x01));   //1
  Packet[31] = byte((0x7B));   //123    
  delay(150);  
  Write2PortBytes(Packet);
  delay(200);
  
}

/*********************************************/
/*               SET WRITE PACKET 1          */
/*********************************************/

public void setWritePacket1(int setDatarate, int mSeg, boolean TE1, boolean TE2, boolean TE3, boolean sTL1, boolean sTL2, boolean sTL3, boolean sTM1, boolean sTM2, boolean sTM3){
  
  char setDR = char(48); //48=0   49=1;
  int setdr =48;
  if(setDatarate == 1){
    setDR = char(49); 
    setdr = 49;
  }
  
  int datarate_aux = mSeg/10;
  if(datarate_aux<1){
    datarate_aux=1;
  }
  char Datarate= char(byte(datarate_aux));
  
  
  int TE3aux = 0;
  if(TE3){
    TE3aux=((TE3aux|1) << 2);
  }
  
  int TE2aux = 0;
  if(TE2){
    TE2aux=((TE2aux|1) << 1);
  }
  
  int TE1aux = 0;
  if(TE1){
    TE1aux=((TE1aux|1));
  }
  char TE = char(byte(TE1aux|TE2aux|TE3aux));
  
   
  int TL3aux = 0;
  if(sTL3){
    TL3aux=((TL3aux|1) << 2);
  }
  
  int TL2aux = 0;
  if(sTL2){
    TL2aux=((TL2aux|1) << 1);
  }
  
  int TL1aux = 0;
  if(sTL1){
    TL1aux=((TL1aux|1));
  }
  char setTL = char(byte(TL1aux|TL2aux|TL3aux));
  
  
  int TM3aux = 0;
  if(sTM3){
    TM3aux=((TM3aux|1) << 2);
  }
  int TM2aux = 0;
  if(sTM2){
    TM2aux=((TM2aux|1) << 2);
  }
  int TM1aux = 0;
  if(sTM1){
    TM1aux=((TM1aux|1) << 2);
  }
  char setTM = char(byte(TM1aux|TM2aux|TM3aux));  
  
  
  int slTM1 = int(SliderTM1.getValue()/0.0977);
  int slTM2 = int(SliderTM2.getValue()/0.0977);
  int slTM3 = int(SliderTM3.getValue()/0.0977);
  
  if(slTM1>1023){
    slTM1= 1023;
  }else if(slTM1<0){
    slTM1= 0;
  }
  
  if(slTM2>1023){
    slTM2 = 1023;
  }else if(slTM2<0){
    slTM2 = 0;
  }
  
  if(slTM3>1023){
    slTM3 = 1023;
  }else if(slTM3<0){
    slTM3 = 0;
  }
  
  int tfTM1 =  int(((float)Integer.parseInt(MaxTorqueTextFieldM1.getText()))/0.0977);
  int tfTM2 =  int(((float)Integer.parseInt(MaxTorqueTextFieldM2.getText()))/0.0977);
  int tfTM3 =  int(((float)Integer.parseInt(MaxTorqueTextFieldM3.getText()))/0.0977);
  
  
  if(tfTM1>1023){
    tfTM1= 1023;
  }else if(tfTM1<0){
    tfTM1= 0;
  }
  
  if(tfTM2>1023){
    tfTM2 = 1023;
  }else if(tfTM2<0){
    tfTM2 = 0;
  }
  
  if(tfTM3>1023){
    tfTM3 = 1023;
  }else if(tfTM3<0){
    tfTM3 = 0;
  }
  
  //println("TL: "+ String.valueOf(byte(TL1aux|TL2aux|TL3aux)) + "Torque Limit 1: " + String.valueOf(slTM1) + " Torque Limit 2: " + String.valueOf(slTM2) +" Torque Limit 3: " + String.valueOf(slTM3));
  
  char TLLBitsM1= char(byte(slTM1));    //LSB_M1ch;
  char TLHBitsM1= char(byte(slTM1>>8)); //MSB_M1ch;
  char TLLBitsM2= char(byte(slTM2));    //LSB_M1ch;
  char TLHBitsM2= char(byte(slTM2>>8)); //MSB_M1ch;
  char TLLBitsM3= char(byte(slTM3));    //LSB_M1ch;
  char TLHBitsM3= char(byte(slTM3>>8)); //MSB_M1ch;  
  
  char TMLBitsM1= char(byte(tfTM1));;    //LSB_M1ch;
  char TMHBitsM1= char(byte(tfTM1>>8)); //MSB_M1ch;
  char TMLBitsM2= char(byte(tfTM2));;    //LSB_M1ch;
  char TMHBitsM2= char(byte(tfTM2>>8)); //MSB_M1ch;
  char TMLBitsM3= char(byte(tfTM3));;    //LSB_M1ch;
  char TMHBitsM3= char(byte(tfTM3>>8)); //MSB_M1ch;
  
  /*String Data2Send = "" + char(122) + char(1) + setDR + Datarate + TE + setTL + TLLBitsM1 + TLHBitsM1 + TLLBitsM2 + TLHBitsM2 + TLLBitsM3 + TLHBitsM3 + setTM + TMLBitsM1 + TMHBitsM1 + TMLBitsM2 + TMHBitsM2 + TMLBitsM3 + TMHBitsM3 + char(0) +char(0) +char(0) +char(0) +char(0) +char(0) +char(0) +char(0) +char(0) +char(0) +char(0) +char(0) + char(123);
  //println("WRITE PACKET 1   Length: " + Data2Send.length() + ":  " + Data2Send);
  Write2Port(Data2Send); 
  delay(200);*/
  
  
  byte[] Packet =  new byte[32];
  Packet[0] = byte((0x7A));    //122
  Packet[1] = byte((0x01));    //1
  Packet[2] = byte((setdr));    //Config Data Rate
  Packet[3] = byte((datarate_aux));    //Data Rate
  Packet[4] = byte((TE1aux|TE2aux|TE3aux));    //Torque Enable(m1,m2,m3)
  Packet[5] = byte((TL1aux|TL2aux|TL3aux));    //Set Torque Limit(m1,m2,m3)
  Packet[6] = byte((slTM1));    //Torque Limit M1
  Packet[7] = byte((slTM1>>8));    //Torque Limit M1
  Packet[8] = byte((slTM2));   //Torque Limit M2 
  Packet[9] = byte((slTM2>>8));   //Torque Limit M2 
  Packet[10] = byte((slTM3));  //Torque Limit M3 
  Packet[11] = byte((slTM3>>8));  //Torque Limit M3 
  Packet[12] = byte((TM1aux|TM2aux|TM3aux));   //Set Max Torque(m1,m2,m3)
  Packet[13] = byte((tfTM1));   //Max Torque M1
  Packet[14] = byte((tfTM1>>8));   //Max Torque M1
  Packet[15] = byte((tfTM2));   //Max Torque M2
  Packet[16] = byte((tfTM2>>8));   //Max Torque M2
  Packet[17] = byte((tfTM3));   //Max Torque M3
  Packet[18] = byte((tfTM3>>8));   //Max Torque M3
  Packet[19] = byte((0x00));   //0
  Packet[20] = byte((0x00));   //0
  Packet[21] = byte((0x00));   //0
  Packet[22] = byte((0x00));   //0
  Packet[23] = byte((0x00));   //0
  Packet[24] = byte((0x00));   //0
  Packet[25] = byte((0x00));   //0
  Packet[26] = byte((0x00));   //0
  Packet[27] = byte((0x00));   //0
  Packet[28] = byte((0x00));   //0
  Packet[29] = byte((0x00));   //0
  Packet[30] = byte((0x00));   //0
  Packet[31] = byte((0x7B));   //123    
  delay(150);  
  Write2PortBytes(Packet);
  delay(200);  
  
  
}





/*********************************************/
/*          WHEEL MODE SET VELOCITY          */
/*********************************************/

void WheelModeSetVelocity(char setVel,int slM1,int slM2, int slM3){
  
  //int slM1 = int(SliderVM1.getValue());
  //int slM2 = int(SliderVM2.getValue());
  //int slM3 = int(SliderVM3.getValue());

  /*byte LSB_M1 = byte(slM1);//(SM1_str.substring(0,7));
  byte MSB_M1 = byte(slM1>>8);//(SM1_str.substring(8,15));
  char LSB_M1ch = char(LSB_M1);//(SM1_str.substring(0,7));
  char MSB_M1ch = char(MSB_M1);//(SM1_str.substring(8,15));
  
  byte LSB_M2 = byte(slM2);//(SM1_str.substring(0,7));
  byte MSB_M2 = byte(slM2>>8);//(SM1_str.substring(8,15));
  char LSB_M2ch = char(LSB_M2);//(SM1_str.substring(0,7));
  char MSB_M2ch = char(MSB_M2);//(SM1_str.substring(8,15));
  
  byte LSB_M3 = byte(slM3);//(SM1_str.substring(0,7));
  byte MSB_M3 = byte(slM3>>8);//(SM1_str.substring(8,15));
  char LSB_M3ch = char(LSB_M3);//(SM1_str.substring(0,7));
  char MSB_M3ch = char(MSB_M3);//(SM1_str.substring(8,15));*/
  
  println("Set Velocities: " + slM1 + " , " + slM2 + " , " + slM3);
  
  
  char setAL = 0;
  char ACW_LBitsM1=0;
  char ACW_HBitsM1=0;
  char ACW_LBitsM2=0;
  char ACW_HBitsM2=0;
  char ACW_LBitsM3=0;
  char ACW_HBitsM3=0;
  
  char ACCW_LBitsM1=char(0x00);
  char ACCW_HBitsM1=char(0x00);
  char ACCW_LBitsM2=char(0x00);
  char ACCW_HBitsM2=char(0x00);
  char ACCW_LBitsM3=char(0x00);
  char ACCW_HBitsM3=char(0x00);

  //char setVel = char(7);
  char VLBitsM1= char(byte(slM1));//LSB_M1ch;
  char VHBitsM1= char(byte(slM1>>8));//MSB_M1ch;
  char VLBitsM2= char(byte(slM2));//LSB_M2ch;
  char VHBitsM2= char(byte(slM2>>8));//MSB_M2ch;
  char VLBitsM3= char(byte(slM3));//LSB_M3ch;
  char VHBitsM3= char(byte(slM3>>8));//MSB_M3ch;
  
  char setPos = char(0);
  char PLBitsM1 = 0;
  char PHBitsM1 = 0;
  char PLBitsM2 = 0;
  char PHBitsM2 = 0;
  char PLBitsM3 = 0;
  char PHBitsM3 = 0;
  
  if(slM1>0 || slM2>0 || slM3>0){    
    setModeJW.lock();
    setModeJW.setColorBackground(color(100,100,100));
  }else if(slM1==0 && slM2==0 && slM3==0){
    setModeJW.unlock();
    setModeJW.setColorBackground(color(0,45,90));
  }
  
  /*String Data2Send ="" + char(122) + char(2) + setAL + ACW_LBitsM1 + ACW_HBitsM1 + ACW_LBitsM2 + ACW_HBitsM2 + ACW_LBitsM3 + ACW_HBitsM3 + ACCW_LBitsM1 + ACCW_HBitsM1 + ACCW_LBitsM2 + ACCW_HBitsM2 + ACCW_LBitsM3 + ACCW_HBitsM3 + setVel + VLBitsM1 + VHBitsM1+ VLBitsM2 + VHBitsM2+ VLBitsM3 + VHBitsM3 + setPos + PLBitsM1 + PHBitsM1+ PLBitsM2 + PHBitsM2+ PLBitsM3 + PHBitsM3 + char(0) + char(0) + char(123);
  println("WheelModeSetVelocity   Data Length: " + Data2Send.length() + ":  " + Data2Send);
  Write2Port(Data2Send);*/  
  //delay(500);
  
  byte[] Packet =  new byte[32];
  Packet[0] = byte((0x7A));    //122
  Packet[1] = byte((0x02));    //2
  Packet[2] = byte((0x00));    //setAl
  Packet[3] = byte((0x00));    //ACW_LBitsM1
  Packet[4] = byte((0x00));    //ACW_HBitsM1
  Packet[5] = byte((0x00));    //ACW_LBitsM2
  Packet[6] = byte((0x00));    //ACW_HBitsM2
  Packet[7] = byte((0x00));    //ACW_HBitsM3
  Packet[8] = byte((0x00));    //ACW_HBitsM3
  Packet[9] = byte((0x00));    //ACCW_LBitsM1
  Packet[10] = byte((0x00));   //ACCW_HBitsM1
  Packet[11] = byte((0x00));   //ACCW_LBitsM2
  Packet[12] = byte((0x00));   //ACCW_HBitsM2
  Packet[13] = byte((0x00));   //ACCW_HBitsM3
  Packet[14] = byte((0x00));   //ACCW_HBitsM3
  Packet[15] = byte((setVel));   //setVel
  Packet[16] = byte((slM1));   //VLBitsM1
  Packet[17] = byte((slM1>>8));   //VHBitsM1
  Packet[18] = byte((slM2));   //VLBitsM2
  Packet[19] = byte((slM2>>8));   //VHBitsM2
  Packet[20] = byte((slM3));   //VLBitsM3
  Packet[21] = byte((slM3>>8));   //VHBitsM3
  Packet[22] = byte((0x00));   //SetPos
  Packet[23] = byte((0x00));   //M1 LSB
  Packet[24] = byte((0x00));   //M1 MSB
  Packet[25] = byte((0x00));   //M2 LSB 0xFF  0X9B
  Packet[26] = byte((0x00));   //M2 MSB 0X01
  Packet[27] = byte((0x00));   //M3 LSB 0xff
  Packet[28] = byte((0x00));   //M3 MSB 0x01
  Packet[29] = byte((0x00));   //0
  Packet[30] = byte((0x00));   //0
  Packet[31] = byte((0x7B));   //123
  delay(150);
  Write2PortBytes(Packet);
  delay(300);

}

/*********************************************/
/*         JOINT MODE SET PACKET              */
/*********************************************/

public void JointModeSetPacket(int setPosaux,int setVelaux,int setALaux, int PosM1,int PosM2, int PosM3, int VelM1,int VelM2,int VelM3){


int slM1 = int(PosM1/0.2932);//int(SliderM1.getValue());
int slM2 = int(PosM2/0.2932);//int(SliderM2.getValue());
int slM3 = int(PosM3/0.2932);//int(SliderM3.getValue());
//println("JointModeSetPacket:: Set Position  slM1= " + slM1 + " slM2= " + slM2 + " slM3= " + slM3);

if(slM1>1023){
  slM1=1023;
}

if(slM2>1023){
  slM2=1023;
}

if(slM3>1023){
  slM3=1023;
}

int slMSM1 =  int(VelM1/0.1113);//Integer.parseInt(MovingSpeedTextFieldM1.getText());
int slMSM2 =  int(VelM2/0.1113);//Integer.parseInt(MovingSpeedTextFieldM2.getText());
int slMSM3 =  int(VelM3/0.1113);//Integer.parseInt(MovingSpeedTextFieldM3.getText());

if(slMSM1>1023){
  slMSM1 = 1023;
}else if(slMSM1<0){
  slMSM1 = 0;
}

if(slMSM2>1023){
  slMSM2 = 1023;
}else if(slMSM2<0){
  slMSM2 = 0;
}

if(slMSM3>1023){
  slMSM3 = 1023;
}else if(slMSM3<0){
  slMSM3 = 0;
}
//println("MS M1: " + slMSM1 +" MS M2: " + slMSM2 +" MS M3: " + slMSM3);
//PARA DEBUG.
//byte LSB_M1 = byte(slM1);//(SM1_str.substring(0,7));
//byte MSB_M1 = byte(slM1>>8);//(SM1_str.substring(8,15));
//char LSB_M1ch = char(LSB_M1);//(SM1_str.substring(0,7));
//char MSB_M1ch = char(MSB_M1);//(SM1_str.substring(8,15));
//println("slider M1:" + slM1 + " slider M2:" + slM2 + " slider M3: " + slM3 + "" + " LSB: " + LSB_M1ch + "  MSB: " + MSB_M1ch);

char setAL = char(setALaux);
char ACW_LBitsM1=1;
char ACW_HBitsM1=0;
char ACW_LBitsM2=1;
char ACW_HBitsM2=0;
char ACW_LBitsM3=1;
char ACW_HBitsM3=0;

char ACCW_LBitsM1=char(0xFF);
char ACCW_HBitsM1=char(0x03);
char ACCW_LBitsM2=char(0xFF);
char ACCW_HBitsM2=char(0x03);
char ACCW_LBitsM3=char(0xFF);
char ACCW_HBitsM3=char(0x03);

char setVel = char(setVelaux);
char VLBitsM1 = char(byte(slMSM1));
char VHBitsM1 = char(byte(slMSM1>>8));
char VLBitsM2 = char(byte(slMSM2));
char VHBitsM2 = char(byte(slMSM2>>8));
char VLBitsM3 = char(byte(slMSM3));
char VHBitsM3 = char(byte(slMSM3>>8));

char setPos = char(setPosaux);
char PLBitsM1= char(byte(slM1));
char PHBitsM1= char(byte(slM1>>8));
char PLBitsM2= char(byte(slM2));
char PHBitsM2=char(byte(slM2>>8));
char PLBitsM3=char(byte(slM3));
char PHBitsM3=char(byte(slM3>>8));

String Data2Send ="" + char(122) + char(2) + setAL + ACW_LBitsM1 + ACW_HBitsM1 + ACW_LBitsM2 + ACW_HBitsM2 + ACW_LBitsM3 + ACW_HBitsM3 + ACCW_LBitsM1 + ACCW_HBitsM1 + ACCW_LBitsM2 + ACCW_HBitsM2 + ACCW_LBitsM3 + ACCW_HBitsM3 + setVel + VLBitsM1 + VHBitsM1+ VLBitsM2 + VHBitsM2+ VLBitsM3 + VHBitsM3 + setPos + PLBitsM1 + PHBitsM1+ PLBitsM2 + PHBitsM2+ PLBitsM3 + PHBitsM3 + char(0) + char(0) + char(123);
//String test=""+char(122) +char(2)+ setAL + ACW_LBitsM1;
//println("Length: " + Data2Send.length() + ":  " + Data2Send);
Write2Port(Data2Send);
delay(300);

}


public void setJointWheelMode(int Value){
  
  if(Value==0){    
   println("Setting WHEEL Mode     Value" + str(Value)  + "  ModeMotorJointWheel:" + ModeMotorJointWheel);
   
   if(ModeMotorJointWheel==1){//joint
     //int pitch=125;
     //int roll=159;
     //int yaw=167;
     //JointModeSetPacket('7','7','0',roll,pitch,yaw,10,10,10);//JointModeSetPacket(char setPos,char setVel,char setAL,int PosM1,int PosM2, int PosM3, int VelM1,int VelM2,int VelM3)
   }
      
   //WheelModeSetVelocity('7',0,0,0);
   setConfigurationPacket(1,1,1,1,1,1);
   WheelModeSetVelocity('7',0,0,0);
   setWritePacket1(0, 10, false,false,false,false,false,false,false,false,false); //MX64T con esto si funciona Si debe de funcionar.
   delay(300);
   
   UnlockWheelMode();
   
  }else if(Value==1){
    println("Setting JOINT Mode     Value" + str(Value) + " ModeMotorJointWheel: "  +ModeMotorJointWheel);
    

    if(ModeMotorJointWheel==2){//wheel 
      
      //println("Velocidad de cada motor [" + VelocityM1 + " , " + VelocityM2 + " , " + VelocityM3 + "]");   
      //SpeedRampFunction(VelocityM1,VelocityM2,VelocityM3);
      //Speed = 0;
      //WheelModeSetVelocity('7',0,0,0);   
      //delay(200); 
      
    }else{
      //JointModeSetPacket('0','0',0,0,0,0,0,0);//JointModeSetPacket(char setPos,char setVel,int PosM1,int PosM2, int PosM3, int VelM1,int VelM2,int VelM3)
    }   
        
    //Mandar Posicion mas cercana,
    //println("PosM1= " + str(PositionM1) + " PosM2=" + str(PositionM2) + " PosM3= " + str(PositionM3));   
    
    setConfigurationPacket(1,1,1,2,2,2);//CONFIGURO A MODO JOINT
    setWritePacket1(0, 10, false,false,false,false,false,false,false,false,false); //MX64T
    /*delay(50);
    JointModeSetPacket(7,7,0,(int)PositionM1,(int)PositionM2,(int)PositionM3,1,1,1);//JointModeSetPacket(char setPos,char setVel,char setAL,int PosM1,int PosM2, int PosM3, int VelM1,int VelM2,int VelM3)
    delay(500);
    setWritePacket1(0, 10, false,false,false,false,false,false,false,false,false);
    delay(100);*/
    
    UnlockJointMode();
    
    MovingSpeedTextFieldM1.setText("5");//MX64T
    MovingSpeedTextFieldM2.setText("5");//MX64T
    MovingSpeedTextFieldM3.setText("5");//MX64T
  }
  
  ModeUnlockControl=true;
}

public void SetVelocityZero()
{
  println("Set Velocity Zero");
  
  byte[] Packet =  new byte[32];
  Packet[0] = byte((0x7A));    //122
  Packet[1] = byte((0x02));    //2
  Packet[2] = byte((0x00));    //setAl
  Packet[3] = byte((0x00));    //ACW_LBitsM1
  Packet[4] = byte((0x00));    //ACW_HBitsM1
  Packet[5] = byte((0x00));    //ACW_LBitsM2
  Packet[6] = byte((0x00));    //ACW_HBitsM2
  Packet[7] = byte((0x00));    //ACW_HBitsM3
  Packet[8] = byte((0x00));    //ACW_HBitsM3
  Packet[9] = byte((0x00));    //ACCW_LBitsM1
  Packet[10] = byte((0x00));   //ACCW_HBitsM1
  Packet[11] = byte((0x00));   //ACCW_LBitsM2
  Packet[12] = byte((0x00));   //ACCW_HBitsM2
  Packet[13] = byte((0x00));   //ACCW_HBitsM3
  Packet[14] = byte((0x00));   //ACCW_HBitsM3
  Packet[15] = byte((0x07));   //setVel
  Packet[16] = byte((0x00));   //VLBitsM1
  Packet[17] = byte((0x00));   //VHBitsM1
  Packet[18] = byte((0x00));   //VLBitsM2
  Packet[19] = byte((0x00));   //VHBitsM2
  Packet[20] = byte((0x00));   //VLBitsM3
  Packet[21] = byte((0x00));   //VHBitsM3
  Packet[22] = byte((0x00));   //SetPos
  Packet[23] = byte((0x00));   //M1 LSB
  Packet[24] = byte((0x00));   //M1 MSB
  Packet[25] = byte((0x00));   //M2 LSB 0xFF  0X9B
  Packet[26] = byte((0x00));   //M2 MSB 0X01
  Packet[27] = byte((0x00));   //M3 LSB 0xff
  Packet[28] = byte((0x00));   //M3 MSB 0x01
  Packet[29] = byte((0x00));   //0
  Packet[30] = byte((0x00));   //0
  Packet[31] = byte((0x7B));   //123  
  
  delay(150);  
  Write2PortBytes(Packet);
  delay(200);
  
  SliderVM1.setValue(0);
  SliderVM2.setValue(0);
  SliderVM3.setValue(0);
  
  setModeJW.unlock();
  setModeJW.setColorBackground(color(0,45,90));
}
