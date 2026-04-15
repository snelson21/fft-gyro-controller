const getAxisKey = (index: number) => {
  switch (index) {
      case 0:
          return 'x';
      case 1:
          return 'y';
      case 2:
          return 'z';
      default:
          return 'x';
  }
};


export async function setMotorPosition(position: any, axisMode: { x: boolean, y: boolean, z: boolean },inverted:{ x: boolean, y: boolean, z: boolean }, velocity: number[]) {
  // await SetVelocity(velocity);
  // Convert position values from -180 to 180 into 0 to 360 if axisMode is true
  position = position.map((value: number, index: number) => {
    if (axisMode[getAxisKey(index)]) {
      return value + (MotorType == 0?  180: 150);
    }
    return value;
  });

  const positionClone = [...position]
  positionClone
    .forEach((value, index) => {
      const axisKey = getAxisKey(index);
      if (inverted[axisKey]) {
        positionClone[index] = (MotorType == 0 ? 360 : 300) - positionClone[index];
      }
    });

  let Max = MotorType === MotorTypeEnum.MX28T ? 4095 : 1023;//4095;//4095;//1023
  let res = MotorType === MotorTypeEnum.MX28T ? 0.088 : 0.2932; //0.088;// 0.088; //0.2932

  //Position
  let slM1 = Math.floor(positionClone[0] / res);// /0.2932);
  let slM2 = Math.floor(positionClone[1] / res);// /0.2932);
  let slM3 = Math.floor(positionClone[2] / res);// /0.2932);

  if (slM1 > Max) {
    slM1 = Max;//1023;
  }

  if (slM2 > Max) {
    slM2 = Max;
  }

  if (slM3 > Max) {
    slM3 = Max;
  }

  //Moving Speed
  let slMSM1 = Math.floor(velocity[0] / 0.1113);
  let slMSM2 = Math.floor(velocity[1] / 0.1113);
  let slMSM3 = Math.floor(velocity[2] / 0.1113);

  if (slMSM1 > 1023) {
    slMSM1 = 1023;
  } else if (slMSM1 < 0) {
    slMSM1 = 0;
  }

  if (slMSM2 > 1023) {
    slMSM2 = 1023;
  } else if (slMSM2 < 0) {
    slMSM2 = 0;
  }

  if (slMSM3 > 1023) {
    slMSM3 = 1023;
  } else if (slMSM3 < 0) {
    slMSM3 = 0;
  }


  let Packet = new Int8Array(32);
  Packet[0] = 0x7A;    //122
  Packet[1] = 0x02;    //2
  Packet[2] = 0x00;    //setAl  0X00
  Packet[3] = 0x01;    //ACW_LBitsM1
  Packet[4] = 0x00;    //ACW_HBitsM1
  Packet[5] = 0x01;    //ACW_LBitsM2
  Packet[6] = 0x00;    //ACW_HBitsM2
  Packet[7] = 0x01;    //ACW_HBitsM3
  Packet[8] = 0x00;    //ACW_HBitsM3
  Packet[9] = 0xFF;    //ACCW_LBitsM1
  Packet[10] = 0x03;   //ACCW_HBitsM1  0X03
  Packet[11] = 0xFF;   //ACCW_LBitsM2
  Packet[12] = 0x03;   //ACCW_HBitsM2  0X03
  Packet[13] = 0xFF;   //ACCW_HBitsM3
  Packet[14] = 0x03;   //ACCW_HBitsM3  0X03
  Packet[15] = 7;   //0x07 setVel
  Packet[16] = slMSM1;   //VLBitsM1
  Packet[17] = (slMSM1 >> 8);   //VHBitsM1
  Packet[18] = slMSM2;   //VLBitsM2
  Packet[19] = (slMSM2 >> 8);   //VHBitsM2
  Packet[20] = slMSM3;   //VLBitsM3
  Packet[21] = (slMSM3 >> 8);   //VHBitsM3
  Packet[22] = 7;   //0x07 SetPos
  Packet[23] = slM1;   //M1 LSB
  Packet[24] = (slM1 >> 8);   //M1 MSB
  Packet[25] = slM2;   //M2 LSB 0xFF  0X9B
  Packet[26] = (slM2 >> 8);   //M2 MSB 0X01
  Packet[27] = slM3;   //M3 LSB 0xff
  Packet[28] = (slM3 >> 8);   //M3 MSB 0x01
  Packet[29] = 0x00;   //0
  Packet[30] = 0x00;   //0
  Packet[31] = 0x7B;   //123


  console.log("SetPosition");

  window.electron.serialPort.writeSocket(Packet);
}

//create an enum for motor type 0 is MX64T and 1 is MX106T
export enum MotorTypeEnum {
  MX28T = 0,
  AX12A = 1,
}

export let MotorType: number = 0;
export const setMotorType = (newVale: number) => {
  MotorType = newVale
}

export let isStopped : boolean = true;

export let MotorMode: string = "joint";
export const setMotorMode = (newVale: string) => {
  MotorMode = newVale;
}

function customMapSliders(sliderValues: number[]): number[] {
  return sliderValues.map(value => {
    if (value < 0) {
      // Map [-124, 0] -> [1023, 0]
      return Math.round(((value + 114) * (0 - 1023)) / (0 - (-114)) + 1023);
    } else {
      // Map [0, 124] -> [1024, 2047]
      return Math.round((value * (2047 - 1024)) / 114 + 1024);
    }
  });
}


export function SetVelocity(velocity: any): Promise<any> {
  velocity = customMapSliders(velocity);

  if (isStopped) {
    isStopped = false;
  }

  let slM1 = parseInt(velocity[0]);
  if (slM1 < 0) {
    slM1 = 1024 - slM1;
  }

  let slM2 = parseInt(velocity[1]);
  if (slM2 < 0) {
    slM2 = 1024 - slM2;
  }

  let slM3 = parseInt(velocity[2]);
  if (slM3 < 0) {
    slM3 = 1024 - slM3;
  }


  let Packet = new Int8Array(32);
  Packet[0] = 0x7A;    //122
  Packet[1] = 0x02;    //2
  Packet[2] = 0x00;    //setAl
  Packet[3] = 0x00;    //ACW_LBitsM1
  Packet[4] = 0x00;    //ACW_HBitsM1
  Packet[5] = 0x00;    //ACW_LBitsM2
  Packet[6] = 0x00;    //ACW_HBitsM2
  Packet[7] = 0x00;    //ACW_HBitsM3
  Packet[8] = 0x00;    //ACW_HBitsM3
  Packet[9] = 0x00;    //ACCW_LBitsM1
  Packet[10] = 0x00;   //ACCW_HBitsM1
  Packet[11] = 0x00;   //ACCW_LBitsM2
  Packet[12] = 0x00;   //ACCW_HBitsM2
  Packet[13] = 0x00;   //ACCW_HBitsM3
  Packet[14] = 0x00;   //ACCW_HBitsM3
  Packet[15] = 0x07;   //setVel
  Packet[16] = slM1;   //VLBitsM1
  Packet[17] = (slM1 >> 8);   //VHBitsM1
  Packet[18] = slM2;   //VLBitsM2
  Packet[19] = (slM2 >> 8);   //VHBitsM2
  Packet[20] = slM3;   //VLBitsM3
  Packet[21] = (slM3 >> 8);   //VHBitsM3
  Packet[22] = 0x00;   //SetPos
  Packet[23] = 0x00;   //M1 LSB
  Packet[24] = 0x00;   //M1 MSB
  Packet[25] = 0x00;   //M2 LSB 0xFF  0X9B
  Packet[26] = 0x00;   //M2 MSB 0X01
  Packet[27] = 0x00;   //M3 LSB 0xff
  Packet[28] = 0x00;   //M3 MSB 0x01
  Packet[29] = 0x00;   //0
  Packet[30] = 0x00;   //0
  Packet[31] = 0x7B;   //123  

  console.log("SetVelocity");

  return window.electron.serialPort.writeSocket(Packet);
}


export function SetTorque(torque: any) {


  let FlagTorqueEnable1 = true;
  let FlagTorqueEnable2 = true;
  let FlagTorqueEnable3 = true;


  setWritePacket1(0, 10, FlagTorqueEnable1, FlagTorqueEnable2, FlagTorqueEnable3, true, true, true, false, false, false, torque);//(int setDatarate, int mSeg, boolean TE1, boolean TE2, boolean TE3, boolean sTL1, boolean sTL2, boolean sTL3, boolean sTM1, boolean sTM2, boolean sTM3)

  console.log("SetTorque");

}




export function setWritePacket1(setDatarate: number, mSeg: number, TE1: boolean, TE2: boolean, TE3: boolean, sTL1: boolean, sTL2: boolean, sTL3: boolean, sTM1: boolean, sTM2: boolean, sTM3: boolean, torque: number[]): Promise<any> {

  let setDR = '48'; //48=0   49=1;
  let setdr = 48;

  if (setDatarate == 1) {
    let setDR = '49';
    let setdr = 49;
  }

  let datarate_aux = parseInt((mSeg / 10).toString());
  if (datarate_aux < 1) {
    datarate_aux = 1;
  }
  let datarate_aux_8byte = new Int8Array(1);
  datarate_aux_8byte[0] = datarate_aux;


  let Datarate = String(datarate_aux_8byte[0]);


  let TE3aux = 0;
  if (TE3) {
    TE3aux = ((TE3aux | 1) << 2);
  }

  let TE2aux = 0;
  if (TE2) {
    TE2aux = ((TE2aux | 1) << 1);
  }

  let TE1aux = 0;
  if (TE1) {
    TE1aux = ((TE1aux | 1));
  }

  let aux_byte = new Int8Array(1);
  aux_byte[0] = TE1aux | TE2aux | TE3aux;
  let TE = String(aux_byte[0]);


  let TL3aux = 0;
  if (sTL3) {
    TL3aux = ((TL3aux | 1) << 2);
  }

  let TL2aux = 0;
  if (sTL2) {
    TL2aux = ((TL2aux | 1) << 1);
  }

  let TL1aux = 0;
  if (sTL1) {
    TL1aux = ((TL1aux | 1));
  }

  let aux_byte_L = new Int8Array(1);
  aux_byte_L[0] = TL1aux | TL2aux | TL3aux;
  let setTL = String(aux_byte_L[0]);


  let TM3aux = 0;
  if (sTM3) {
    TM3aux = ((TM3aux | 1) << 2);
  }
  let TM2aux = 0;
  if (sTM2) {
    TM2aux = ((TM2aux | 1) << 2);
  }
  let TM1aux = 0;
  if (sTM1) {
    TM1aux = ((TM1aux | 1) << 2);
  }



  let slTM1 = Math.floor(torque[0] / 0.0977);
  let slTM2 = Math.floor(torque[1] / 0.0977);
  let slTM3 = Math.floor(torque[2] / 0.0977);

  if (slTM1 > 1023) {
    slTM1 = 1023;
  } else if (slTM1 < 0) {
    slTM1 = 0;
  }

  if (slTM2 > 1023) {
    slTM2 = 1023;
  } else if (slTM2 < 0) {
    slTM2 = 0;
  }

  if (slTM3 > 1023) {
    slTM3 = 1023;
  } else if (slTM3 < 0) {
    slTM3 = 0;
  }

  let tfTM1 = Math.floor(100 / 0.0977);
  let tfTM2 = Math.floor(100 / 0.0977);
  let tfTM3 = Math.floor(100 / 0.0977);

  if (tfTM1 > 1023) {
    tfTM1 = 1023;
  } else if (tfTM1 < 0) {
    tfTM1 = 0;
  }

  if (tfTM2 > 1023) {
    tfTM2 = 1023;
  } else if (tfTM2 < 0) {
    tfTM2 = 0;
  }

  if (tfTM3 > 1023) {
    tfTM3 = 1023;
  } else if (tfTM3 < 0) {
    tfTM3 = 0;
  }



  let Packet = new Int8Array(32);
  Packet[0] = 0x7A;    //122
  Packet[1] = 0x01;    //1
  Packet[2] = setdr;    //Config Data Rate
  Packet[3] = datarate_aux;    //Data Rate
  Packet[4] = TE1aux | TE2aux | TE3aux;    //Torque Enable(m1,m2,m3)
  Packet[5] = TL1aux | TL2aux | TL3aux;    //Set Torque Limit(m1,m2,m3)
  Packet[6] = -1;    //Torque Limit M1
  Packet[7] = 3;    //Torque Limit M1
  Packet[8] = -1;   //Torque Limit M2 
  Packet[9] = 3;   //Torque Limit M2 
  Packet[10] = -1;  //Torque Limit M3 
  Packet[11] = 3;  //Torque Limit M3 
  Packet[12] = TM1aux | TM2aux | TM3aux;   //Set Max Torque(m1,m2,m3)
  Packet[13] = tfTM1;   //Max Torque M1
  Packet[14] = tfTM1 >> 8;   //Max Torque M1
  Packet[15] = tfTM2;   //Max Torque M2
  Packet[16] = tfTM2 >> 8;   //Max Torque M2
  Packet[17] = tfTM3;   //Max Torque M3
  Packet[18] = tfTM3 >> 8;   //Max Torque M3
  Packet[19] = 0x00;   //0
  Packet[20] = 0x00;   //0
  Packet[21] = 0x00;   //0
  Packet[22] = 0x00;   //0
  Packet[23] = 0x00;   //0
  Packet[24] = 0x00;   //0
  Packet[25] = 0x00;   //0
  Packet[26] = 0x00;   //0
  Packet[27] = 0x00;   //0
  Packet[28] = 0x00;   //0
  Packet[29] = 0x00;   //0
  Packet[30] = 0x00;   //0
  Packet[31] = 0x7B;   //123    

  console.log("Setwritepacket1");


  return window.electron.serialPort.writeSocket(Packet);


  // for(let i=0; i < 32; i++){
  //   console.log(Packet[i])
  //  }


}

export function WheelModeSetVelocity(setVel: any, velocity: any): Promise<any> {

  let slM1 = parseInt(velocity[0]);
  let slM2 = parseInt(velocity[1]);
  let slM3 = parseInt(velocity[2]);


  let Packet = new Int8Array(32);
  Packet[0] = 0x7A;    //122
  Packet[1] = 0x02;    //2
  Packet[2] = 0x00;    //setAl
  Packet[3] = 0x00;    //ACW_LBitsM1
  Packet[4] = 0x00;    //ACW_HBitsM1
  Packet[5] = 0x00;    //ACW_LBitsM2
  Packet[6] = 0x00;    //ACW_HBitsM2
  Packet[7] = 0x00;    //ACW_HBitsM3
  Packet[8] = 0x00;    //ACW_HBitsM3
  Packet[9] = 0x00;    //ACCW_LBitsM1
  Packet[10] = 0x00;   //ACCW_HBitsM1
  Packet[11] = 0x00;   //ACCW_LBitsM2
  Packet[12] = 0x00;   //ACCW_HBitsM2
  Packet[13] = 0x00;   //ACCW_HBitsM3
  Packet[14] = 0x00;   //ACCW_HBitsM3
  Packet[15] = setVel;   //setVel
  Packet[16] = slM1;   //VLBitsM1
  Packet[17] = (slM1 >> 8);   //VHBitsM1
  Packet[18] = (slM2);   //VLBitsM2
  Packet[19] = (slM2 >> 8);   //VHBitsM2
  Packet[20] = (slM3);   //VLBitsM3
  Packet[21] = (slM3 >> 8);   //VHBitsM3
  Packet[22] = 0x00;   //SetPos
  Packet[23] = 0x00;   //M1 LSB
  Packet[24] = 0x00;   //M1 MSB
  Packet[25] = 0x00;   //M2 LSB 0xFF  0X9B
  Packet[26] = 0x00;   //M2 MSB 0X01
  Packet[27] = 0x00;   //M3 LSB 0xff
  Packet[28] = 0x00;   //M3 MSB 0x01
  Packet[29] = 0x00;   //0
  Packet[30] = 0x00;   //0
  Packet[31] = 0x7B;   //123

  console.log("WheelModeSetVelocity");


  return window.electron.serialPort.writeSocket(Packet);
}

export async function setJointWheelMode(ModeMotorJointWheel: string, torque: number[], velocity: number[]) {
  if (ModeMotorJointWheel == "wheel") {
    await setConfigurationPacket(1, 1, 1, 1, 1, 1);
    await new Promise(resolve => setTimeout(resolve, 100));
    await WheelModeSetVelocity('7', [0,0,0]);
    await new Promise(resolve => setTimeout(resolve, 100));
    await setWritePacket1(0, 10, false, false, false, false, false, false, false, false, false, torque); //MX64T
  }
  if (ModeMotorJointWheel == "joint") {
    await setConfigurationPacket(1, 1, 1, 2, 2, 2);//CONFIGURO A MODO JOINT
    await new Promise(resolve => setTimeout(resolve, 100));
    await setWritePacket1(0, 10, false, false, false, false, false, false, false, false, false, torque); //MX64T
  }


}

export function setConfigurationPacket(sMode1: number, sMode2: number, sMode3: number, mMode1: number, mMode2: number, mMode3: number): Promise<any> {
  let setMode1 = '48'; //48=0   49=1;
  let sm1 = 48;
  if (sMode1 == 1) {
    setMode1 = '49';
    sm1 = 49;
  }

  let setMode2 = '48'; //48=0   49=1;
  let sm2 = 48;
  if (sMode2 == 1) {
    setMode2 = '49';
    sm2 = 49;
  }

  let setMode3 = '48'; //48=0   49=1;
  let sm3 = 48;
  if (sMode3 == 1) {
    setMode3 = '49';
    sm3 = 49;
  }

  let Mode1 = '48';
  let mm1 = 48;
  if (mMode1 == 1) {
    Mode1 = '49';
    mm1 = 49;
  } else if (mMode1 == 2) {
    Mode1 = '50';
    mm1 = 50;
  }

  let Mode2 = '48';
  let mm2 = 48;
  if (mMode2 == 1) {
    Mode2 = '49';
    mm2 = 49;
  } else if (mMode2 == 2) {
    Mode2 = '50';
    mm2 = 50;
  }

  let Mode3 = '48';
  let mm3 = 48;
  if (mMode3 == 1) {
    Mode3 = '49';
    mm3 = 49;
  } else if (mMode3 == 2) {
    Mode3 = '50';
    mm3 = 50;
  }

  /*String Data2Send ="" + char(122) + char(3) + setMode1 + setMode2 + setMode3 + Mode1 + Mode2 + Mode3 + char(0)+ char(0)+ char(0)+ char(0)+ char(0)+ char(0)+ char(49)+ char(49)+ char(49)+ char(0)+ char(0)+ char(0)+ char(0)+ char(0)+ char(0)+ char(0)+ char(0)+ char(0)+ char(0)+ char(0)+ char(0)+ char(0)+ char(1) + char(123);
  Write2Port(Data2Send);  
  delay(300);*/

  let Packet = new Int8Array(32);
  Packet[0] = 0x7A;    //122
  Packet[1] = 0x03;    //3
  Packet[2] = sm1;    //setMode1
  Packet[3] = sm2;    //setMode2
  Packet[4] = sm3;    //setMode3
  Packet[5] = mm1;    //Mode1
  Packet[6] = mm2;    //Mode2
  Packet[7] = mm3;    //Mode3
  Packet[8] = 0x00;    //0
  Packet[9] = 0x00;    //0
  Packet[10] = 0x00;   //0
  Packet[11] = 0x00;   //0
  Packet[12] = 0x00;   //0
  Packet[13] = 0x00;   //0
  Packet[14] = 0x31;   //49
  Packet[15] = 0x31;   //49
  Packet[16] = 0x31;   //49
  Packet[17] = 0x00;   //0
  Packet[18] = 0x00;   //0
  Packet[19] = 0x00;   //0
  Packet[20] = 0x00;   //0
  Packet[21] = 0x00;   //0
  Packet[22] = 0x00;   //0
  Packet[23] = 0x00;   //0
  Packet[24] = 0x00;   //0
  Packet[25] = 0x00;   //0
  Packet[26] = 0x00;   //0
  Packet[27] = 0x00;   //0
  Packet[28] = 0x00;   //0
  Packet[29] = 0x00;   //0
  Packet[30] = 0x01;   //1
  Packet[31] = 0x7B;   //123    

  console.log("SetConfigurationPacket");

  return window.electron.serialPort.writeSocket(Packet)
}

export async function EmergencyStop(ModeMotorJointWheel: string, torque: number[]) {

  if (ModeMotorJointWheel == "joint") {
    await setWritePacket1(0, 10, false, false, false, false, false, false, false, false, false, torque);//Torque
  } else {
    await setConfigurationPacket(1, 1, 1, 1, 1, 1);
    setTimeout(async() => {
      await setWritePacket1(0, 10, false, false, false, false, false, false, false, false, false, torque); //MX64T
    }, 100);
  }


  isStopped = true;
}


