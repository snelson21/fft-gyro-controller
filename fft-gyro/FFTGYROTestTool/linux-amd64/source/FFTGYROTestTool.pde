/*
Aixware Technologies  
*/

import controlP5.*;
import java.util.*;
import processing.serial.*;
import static javax.swing.JOptionPane.*;
import java.awt.Frame;
import grafica.*;
import java.util.Random;

// *********************** I N I C I A L I Z A C I O N **************************
ControlP5 cp5;
color bodyColor = #FFF703;//#6E0595;
color hoverColor = #F5B502;

float[] fgoal_i={0.0,0.0};
float[] Sum_fint_ij={0.0,0.0};
float[] Sum_fint_io={0.0,0.0};
float[] Fint_i = {0.0,0.0};
float[] Fi = {0.0,0.0};
float[] V={0.0,0.0};
float[] epi = {0.0,0.0};

String myName;

float myX;
float myY;
int SizePanelX;
int SizePanelY;

Serial myPort;

Button Explorar,CrearSensor,Enviar0x01,Enviar0x0A,Enviar0x07, RefreshPorts, ConectarPort, CerrarPort;
Slider slider;
Textarea myTextarea,myTextarea2,myTextarea3,TextAreaCom;
Textarea Xtext,Ytext,Ztext;

Tab Tab1;
DropdownList d1, d2;
ListBox l;
ScrollableList SerialList;

PImage img;

String PORT ="";
int PORT_n = -999;

ArrayList AT = new ArrayList();
ArrayList VAT = new ArrayList();
String[] At = {};
String[] VAt = {};
int NAt = 0;

boolean FlagACK=false;
boolean FlagPortAvailable = false;
boolean FlagOneReset = false;
int ContReliableFlagAck = 0;
int ContReliableFlagPortAv = 0;
boolean FlagACKRel =  false;
boolean FlagPortAvRel =  false;
boolean FlagPortDataAvailable = false;
 String DataInfo_str = "";
 
 int contUB=0;
 
/****************** G r a f i c a *******************/
public GPlot plotx_1;
public GPlot plot_mpos;
public GPlot plot_mvel;
public GPlot plot_mtor;
public GPlot plot_mtemp;
public GPlot plot_mvolt;
 
String BufferUART = "";
String myString = "";
String BufferUARTAux; 
String BufferUARTwithDate="";
String[] BufferUARTArr = {};
String BufferUSBAux="";
String BufferUSB="";
String DateTime ="";
 
PrintWriter TxtFile;
char[] BufferBytes = new char[255];
int contBufferBytes = 0;

int Npoints = 100;//100000;
GPointsArray pointsx1,pointsy1,pointsz1,pointsx2,pointsy2,pointsz2;
int contPoint = 0;

//Encoders
float[] ValuesX = new float[Npoints]; 
float[] ValuesY = new float[Npoints];
float[] ValuesZ = new float[Npoints];


//Motors
float[] ValuesPos1 = new float[Npoints]; 
float[] ValuesPos2 = new float[Npoints]; 
float[] ValuesPos3 = new float[Npoints]; 

float[] ValuesVel1 = new float[Npoints]; 
float[] ValuesVel2 = new float[Npoints]; 
float[] ValuesVel3 = new float[Npoints]; 

float[] ValuesTor1 = new float[Npoints]; 
float[] ValuesTor2 = new float[Npoints]; 
float[] ValuesTor3 = new float[Npoints]; 

float[] ValuesVolt1 = new float[Npoints]; 
float[] ValuesVolt2 = new float[Npoints]; 
float[] ValuesVolt3 = new float[Npoints]; 

float[] ValuesTemp1 = new float[Npoints]; 
float[] ValuesTemp2 = new float[Npoints]; 
float[] ValuesTemp3 = new float[Npoints]; 


float[] ValuesXGauss = new float[101];
float[] ValuesYGauss = new float[101];
float[] ValuesZGauss = new float[101];

float[] GaussXValue = new float[101];
float[] GaussYValue = new float[101];
float[] GaussZValue = new float[101];

int GaussCont = 0;

float maxX = -1000;
float minX = 1000;
float maxY = -1000;
float minY = 1000;
float maxZ = -1000;
float minZ = 1000;

int seclast = 0;
int seclastcont = 0;
int seclastN = 0;

//MyThread thread;
boolean gottemp= false;

int contValArr = 0;    
int  NValArr = 100; 
float[] ArrXValMean = new float[NValArr];
float[] ArrYValMean = new float[NValArr];
float[] ArrZValMean = new float[NValArr];
float SumaX;
float SumaY;
float SumaZ;

float MeanX;
float MeanY;
float MeanZ;

float DevStdX;
float DevStdY;
float DevStdZ;
    
int t=0;

float MotorTypeConnected = 1;  //1=ax12a  2=mx28t
float MotorRes = 0.2932;
float MaxAngle = 300;
float MotorRepBytes = 1023;

//************************* P A R A M E T R O S ******************************************

float scPx=50;  //33 //100  //sxPX pixeles son 1 metro
int FontSize_12 = 12;
int FontSize_A = 15;
int FontSize_B = 25;

CheckBox checkbox;
CheckBox checkboxMotors;
RadioButton radiobuttonTypeMotors;
Toggle plotbutton,SyncPosbutton,SyncVelbutton,TorqueEnable1,TorqueEnable2,TorqueEnable3,Filtro,setHomeT,setModeJW,setHomeMotors,GuardarBtn;
Button SetPosition,SetVelocity,SetVelocityZero,SetTorque,SetMaxTorque,EmergencyStop,setHome;

Slider SliderTM1,SliderTM2,SliderTM3;
Slider SliderM1,SliderM2,SliderM3;
Slider SliderVM1,SliderVM2,SliderVM3;

Textfield MaxTorqueTextFieldM1,MaxTorqueTextFieldM2,MaxTorqueTextFieldM3;
Textfield TorqueTextFieldM1,TorqueTextFieldM2,TorqueTextFieldM3;
Textfield PositionTextFieldM1,PositionTextFieldM2,PositionTextFieldM3;
Textfield MovingSpeedTextFieldM1,MovingSpeedTextFieldM2,MovingSpeedTextFieldM3;
Textfield VelocityTextFieldM1,VelocityTextFieldM2,VelocityTextFieldM3;
Textfield TxtFileName;

Textarea PitchTextArea,RollTextArea,YawTextArea,JointWheelMode;
Textarea PitchTextAreaE,RollTextAreaE,YawTextAreaE;
Textarea TorqueLabel,MovingSpeedLabel,PositionLabel,VelocityLabel,TorqueEnableLabel;

int sliderValue = 100;
int sliderTicks1 = 100;
int sliderTicks2 = 30;
Slider Pos1,Pos2,Pos3;

int SystemMode = 0; 
int SystemModeMotorEncoder = 0;
int ModeMotorJointWheel = 0;

boolean ModeUnlockControl = false;
boolean GraficarFlag = false;
boolean GuardarFlag = false;
boolean BufferUARTFlag = false;
boolean FlagInicio = false;
boolean HideFlag=false;
boolean plotButtonOneShot = false;
boolean EmergencyStopFlag=false;
boolean SyncPosFlag=false;
boolean SyncVelFlag=false;
boolean StartConnectionOneShot = false; 
boolean FiltroSwitchFlag=false;
boolean FlagHomeCompensation = false;

float PitchCompHome = 0.0;
float RollCompHome = 0.0;
float YawCompHome = 0.0;

ControlFont font;

float DataE1 = 0;
float DataE2 = 0;
float DataE3 = 0;

float DataE1Filter = 0;
float DataE2Filter = 0;
float DataE3Filter = 0;
   
float PositionM1 = 0;
float PositionM2 = 0;
float PositionM3 = 0;
         
float VelocityM1 = 0;
float VelocityM2 = 0;
float VelocityM3 = 0;
   
float TorqueM1 = 0;
float TorqueM2 = 0;
float TorqueM3 = 0;
   
float VoltageM1 = 0;
float VoltageM2 = 0;
float VoltageM3 = 0;
   
float TemperatureM1 = 15;
float TemperatureM2 = 25;
float TemperatureM3 = 40;
   
float ErrorM1 = 0;
float ErrorM2 = 0;
float ErrorM3 = 0;

//Arcball arcball;
//PFD pfd;
ChildApplet child;
PFDApplet pfdchild;
YawDisplay pitchdisplay;
YawDisplay rolldisplay;
YawDisplay yawdisplay;

YawDisplay pitchdisplayE;
YawDisplay rolldisplayE;
YawDisplay yawdisplayE;


/*GPointsArray pointsVoid;  
GPointsArray pointsx1test;
GPointsArray pointsy1test;
GPointsArray pointsz1test;  
GPointsArray pointsm1pos;
GPointsArray pointsm2pos;
GPointsArray pointsm3pos;  
GPointsArray pointsm1vel;
GPointsArray pointsm2vel;
GPointsArray pointsm3vel;  
GPointsArray pointsm1tor;
GPointsArray pointsm2tor;
GPointsArray pointsm3tor;  
GPointsArray pointsm1volt;
GPointsArray pointsm2volt;
GPointsArray pointsm3volt;  
GPointsArray pointsm1temp;
GPointsArray pointsm2temp;
GPointsArray pointsm3temp;*/

boolean mousePressedOnParent = false;


PShape fuselage, cockpit, wingF, wingB, plane;

void settings(){
  size(1250, 700); //x,y  (1800, 1010);
  smooth();
}

void setup() {
  frameRate(60);//120
  cp5= new ControlP5(this);
  
  
  /*********************************************/
  /*                 FUENTES                   */
  /*********************************************/
  PFont XYZ = createFont("Arial",40,true);
  ControlFont XYZcf = new ControlFont(XYZ,40); 
  
  PFont pfont12 = createFont("Arial",FontSize_12,true);//12
  ControlFont font12 = new ControlFont(pfont12,FontSize_12);
  
  PFont pfont = createFont("Arial",FontSize_A,true);//15
  font = new ControlFont(pfont,FontSize_A);
  
  PFont pfontB = createFont("Arial",FontSize_B,true);//25
  ControlFont fontBigger = new ControlFont(pfontB,FontSize_B); 
  
  PFont pfont18 = createFont("Arial",18,true);//25
  ControlFont font18 = new ControlFont(pfont18,18); 
  
  
  /******************************************************/
  /*                  OTRA VENTANA                      */ 
  /******************************************************/
  //arcball = new Arcball(this, 300);
  child = new ChildApplet();  //DESCOMENTAR
  
  //pfd = new PFD(450,350,250,1);
  pfdchild = new PFDApplet();  //DESCOMENTAR
  
  
  
  /******************************************************/
  /*            Graficas Circulares: YAE                */
  /******************************************************/
  pitchdisplay =  new YawDisplay(410,120,80);  
  PitchTextArea =cp5.addTextarea("PitchTextFieldM")
     .setPosition(90,235)
     .setSize(200,400)
     .setFont(createFont("Arial",15,true))
     //.setColorLabel(color(180,180,180,255)) 
     .setColor(color(50,50,50,255))     
  ;
  
  
  rolldisplay=  new YawDisplay(150,120,80);  
  RollTextArea =cp5.addTextarea("RollTextFieldM")
     .setPosition(360,235)
     .setSize(250,50)
     .setFont(createFont("Arial",15,true))
     //.setColorLabel(color(180,180,180,255)) 
     .setColor(color(50,50,50,255))     
  ;
  
  yawdisplay =  new YawDisplay(660,120,80);  
  YawTextArea =cp5.addTextarea("YawTextFieldM")
     .setPosition(600,235)
     .setSize(200,50)
     .setFont(createFont("Arial",15,true))
     //.setColorLabel(color(180,180,180,255)) 
     .setColor(color(100,100,100,255))     
  ;  
  
  
  /* * * * * * * * ** ENCODER  * * * * * * * * */
  
  rolldisplayE =  new YawDisplay(180,160,100);  
  RollTextAreaE =cp5.addTextarea("RollTextFieldE")
     .setPosition(110,300)
     .setSize(200,50)
     .setFont(pfont18)
     //.setColorLabel(color(180,180,180,255)) 
     .setColor(color(100,100,100,255))     
  ;
  
  
  pitchdisplayE =  new YawDisplay(500,160,100);  
  PitchTextAreaE =cp5.addTextarea("PitchTextFieldE")  
     .setPosition(440,300)
     .setSize(250,50)
     .setFont(pfont18)
     //.setColorLabel(color(180,180,180,255)) 
     .setColor(color(100,100,100,255))     
  ;
  
  
  yawdisplayE =  new YawDisplay(820,160,100);  
  YawTextAreaE =cp5.addTextarea("YawTextFieldE")
     .setPosition(770,300)
     .setSize(200,50)
     .setFont(pfont18)
     //.setColorLabel(color(180,180,180,255)) 
     .setColor(color(100,100,100,255))     
  ;  
  
  pointsx1 = new GPointsArray(Npoints);
  pointsy1 = new GPointsArray(Npoints);
  pointsz1 = new GPointsArray(Npoints);
  
  pointsx2 = new GPointsArray(101);
  pointsy2 = new GPointsArray(101);
  pointsz2 = new GPointsArray(101);
  
  /****************Grafica: plotx_1 ENCODERS********************/
  plotx_1 = new GPlot(this);
  plotx_1.setDim(820, 230);  //(x,y)
  plotx_1.setPos(-800,-800); //(30, 30);  
  plotx_1.setXLim(0, Npoints);
  plotx_1.setYLim(0, 360);
  plotx_1.setLineColor(#4640FF);   
  plotx_1.setPointColor(#0A03FF);
  plotx_1.setLineWidth(2);
  plotx_1.setPointSize(8);
  plotx_1.getYAxis().getAxisLabel().setText("Angle");
  plotx_1.setBgColor(255);
  plotx_1.setBoxBgColor(255);
  plotx_1.setBoxLineColor(255);
  plotx_1.setAllFontProperties("Arial",0,12);
  plotx_1.setGridLineColor(210);
  plotx_1.setGridLineWidth(0.8);
  plotx_1.setVerticalAxesNTicks(4);
  plotx_1.setHorizontalAxesNTicks(20);  
  plotx_1.setPoints(pointsx1);
  plotx_1.addLayer("Encoder 2", pointsy1);
  plotx_1.getLayer("Encoder 2").setLineColor(color(255, 100,255, 255));
  plotx_1.getLayer("Encoder 2").setPointColor(color(255,100, 255, 255));
  plotx_1.addLayer("Encoder 3", pointsz1);
  plotx_1.getLayer("Encoder 3").setLineColor(color(0,255, 0, 255));
  plotx_1.getLayer("Encoder 3").setPointColor(color(0,255, 0, 255));
  plotx_1.activateZooming();
  plotx_1.activatePanning();
  plotx_1.activateCentering(RIGHT, GPlot.CTRLMOD);

 
  //Plot Motor Position 
  //plot_mpos = new GPlot(this);
  //plot_mpos = InitializeMotorPlots(plot_mpos,-800,-800,300,160,360,"Motor Position(0-1024)");//(GPlot plot,int posx, int posy,int size_x, int size_y,int Ylimit,String YAxisLabel)
  
  plot_mvel = new GPlot(this);
  plot_mvel = InitializeMotorPlots(plot_mvel,-800,-800,300,110,125,"Present Speed(rpm)");//(GPlot plot,int posx, int posy,int size_x, int size_y,int Ylimit,String YAxisLabel)
  
  plot_mtor = new GPlot(this);
  plot_mtor = InitializeMotorPlots(plot_mtor,-800,-800,300,110,110,"Torque Limit(%)");//(GPlot plot,int posx, int posy,int size_x, int size_y,int Ylimit,String YAxisLabel)

  plot_mtemp = new GPlot(this);
  plot_mtemp = InitializeMotorPlots(plot_mtemp,-800,-800,300,110,100,"Temperature(°)");//(GPlot plot,int posx, int posy,int size_x, int size_y,int Ylimit,String YAxisLabel)
  
  plot_mvolt = new GPlot(this);
  plot_mvolt = InitializeMotorPlots(plot_mvolt,-800,-800,300,110,20,"Voltage(V)");//(GPlot plot,int posx, int posy,int size_x, int size_y,int Ylimit,String YAxisLabel)
  
  
  /*pointsVoid = new GPointsArray(Npoints);  
  pointsx1test = new GPointsArray(Npoints);
  pointsy1test = new GPointsArray(Npoints);
  pointsz1test = new GPointsArray(Npoints);  
  pointsm1pos = new GPointsArray(Npoints);
  pointsm2pos = new GPointsArray(Npoints);
  pointsm3pos = new GPointsArray(Npoints);  
  pointsm1vel = new GPointsArray(Npoints);
  pointsm2vel = new GPointsArray(Npoints);
  pointsm3vel = new GPointsArray(Npoints);  
  pointsm1tor = new GPointsArray(Npoints);
  pointsm2tor = new GPointsArray(Npoints);
  pointsm3tor = new GPointsArray(Npoints);  
  pointsm1volt = new GPointsArray(Npoints);
  pointsm2volt = new GPointsArray(Npoints);
  pointsm3volt = new GPointsArray(Npoints);  
  pointsm1temp = new GPointsArray(Npoints);
  pointsm2temp = new GPointsArray(Npoints);
  pointsm3temp = new GPointsArray(Npoints);*/
  
  
  
  RefreshPorts = cp5.addButton("Refresh")
      .setBroadcast(false)
      .setFont(font12)
      .setValue(0)
      .setPosition(255,630)
      .setSize(120,50)
      .setBroadcast(true)
      ;
      
  ConectarPort = cp5.addButton("Connect")
      .setBroadcast(false)
      .setFont(fontBigger)
      .setValue(0)
      .setPosition(390,630)
      .setSize(180,50)
      .setBroadcast(true)
      ;
  CerrarPort = cp5.addButton("Disconnect")
      .setBroadcast(false)
      .setFont(font)
      .setValue(0)
      .setPosition(585,630)
      .setSize(180,50)
      .setBroadcast(true)
      ;
      
  SerialList = cp5.addScrollableList("Ports")
     .setPosition(55, 630)
     .setSize(180, 120)
     .setBarHeight(28)
     .setItemHeight(30)
     .setOpen(false)
     //.addItems(l)
     ;      
     
     
    /*********************************************/
    /*              EMERGENCY STOP               */
    /*********************************************/  
      
      EmergencyStop = cp5.addButton("EmergencyStop")
      .setBroadcast(false)
      .setFont(createFont("arial",15))
      .setCaptionLabel("Stop")
      .setColorBackground(#FF5A5A)
      .setColorForeground(#FF2C2C)      
      .setColorActive(#DE0202)
      .setColorLabel(color(255))
      .setValue(0)
      .setPosition(1080,630)
      .setSize(160,50)
      .setBroadcast(true)
      ;
     
     
     
     
     // create a toggle
  plotbutton = cp5.addToggle("Pause")
     .setBroadcast(false)
     .setFont(font)
     .setPosition(870,10)
     .setSize(70,30)
     .setColorLabel(color(20,22,131)) 
     .setBroadcast(true)
     ;
     
  Filtro = cp5.addToggle("FiltroSwitch")
     .setBroadcast(false)
     .setFont(font)
     .setPosition(940,10)
     //.setMode(ControlP5.SWITCH) 
     .setSize(70,30)     
     .setColorLabel(color(100,100,100))
     .setCaptionLabel("Filter")
     //.align(10,10,30,3)
     .setBroadcast(true)
     ;
     
  setHomeMotors = cp5.addToggle("setHomeMotors")
      .setBroadcast(false)
      .setCaptionLabel("Set Home")
      .setValue(0)
      .setFont(font)
      //.setColorBackground(#FF5A5A)
      //.setColorForeground(#FF2C2C)      
      //.setColorActive(#DE0202)
      .setColorLabel(color(20,22,131)) //.setColorLabel(color(255))      
      .setPosition(1000,20)
      .setSize(30,30)
      .setBroadcast(true)
      ;
      
     setHomeT = cp5.addToggle("setHomePosition")
      .setBroadcast(false)
      .setCaptionLabel("Set Home")
      .setValue(0)
      .setFont(font)
      //.setColorBackground(#FF5A5A)
      //.setColorForeground(#FF2C2C)      
      //.setColorActive(#DE0202)
      .setColorLabel(color(20,22,131)) //.setColorLabel(color(255))      
      .setPosition(1100,60)
      .setSize(90,30)
      .setBroadcast(true)
      ;
      
  setModeJW = cp5.addToggle("setJointWheelMode")
      .setBroadcast(false)
      .setCaptionLabel("")
      .setValue(0)
      .setFont(pfont12)
      .setLabel("Press to Start")
      //.setColorBackground(#FF5A5A)   
      //.setColorActive(#DE0202)
      .setState(false)
      .setColorLabel(color(20,22,131)) //.setColorLabel(color(255))      
      .setPosition(1100,20)
      .setSize(120,30)
      .setBroadcast(true)
      ;
  controlP5.Label l = setModeJW.getCaptionLabel();  
  l.setColor(#ffffff);
  l.getStyle().marginTop = -28;
  l.getStyle().marginLeft = 10;
      
      
  JointWheelMode = cp5.addTextarea("JWModeTextField")
     .setPosition(1120,30)
     .setSize(200,50)
     .setFont(pfont18)
     //.setColorLabel(color(180,180,180,255)) 
     .setColor(color(100,100,100,255))          
  ;
  JointWheelMode.hide();
     
     
     // SOLO PARA TESTEAR EL CAMBIO DE MODO MOTOR A ENCODER
    /*cp5.addToggle("setSystemModePlots")
     .setBroadcast(false)
     .setFont(font)
     .setPosition(950,30)
     .setSize(80,40)
     .setColorLabel(color(20,22,131)) 
     .setBroadcast(true)
     ;*/
     
     
     
  float[] ArrChbox = {1,1,1};
  checkbox = cp5.addCheckBox("checkBox")
             .setPosition(1010, 180)
             .setColorForeground(color(120))
             .setColorActive(#22FA03)
             .setColorLabel(color(0))             
             .setSize(20, 20)             
             .setItemsPerRow(1)
             .setSpacingColumn(30)
             .setSpacingRow(20)
             .addItem("Encoder 1", 1)
             .addItem("Encoder 2", 2)
             .addItem("Encoder 3", 3)
             .setArrayValue(ArrChbox)
             .setFont(createFont("arial",22))
             ;
             
  checkbox.getItem(0).setFont(createFont("arial",20));
  checkbox.getItem(0).setColorActive(color(21,73,255,255));
  checkbox.getItem(0).setColorForeground(color(111,143,255,255));
  checkbox.getItem(0).setColorBackground(color(70,70,70,255));
  
  checkbox.getItem(1).setFont(createFont("arial",20));
  checkbox.getItem(1).setColorActive(color(245,35,245,255));
  checkbox.getItem(1).setColorForeground(color(244,147,255,255));
  checkbox.getItem(1).setColorBackground(color(70,70,70,255));
  
  checkbox.getItem(2).setFont(createFont("arial",20));
  checkbox.getItem(2).setColorActive(color(53,250,28,255));
  checkbox.getItem(2).setColorForeground(color(124,255,144,255));
  checkbox.getItem(2).setColorBackground(color(70,70,70,255));
             
  
  checkboxMotors = cp5.addCheckBox("checkBoxMotors")
             .setPosition(810, 90)
             .setColorForeground(color(120,255,255,255))
             .setColorActive(#22FA03)
             .setColorLabel(color(0))
             .setSize(20, 20)             
             .setItemsPerRow(3)
             .setSpacingColumn(100)
             .setSpacingRow(20)
             .addItem("Pitch",1)//.addItem("Motor 1", 1)//.setFont(font)
             .addItem("Roll",1)//.addItem("Motor 2", 2)
             .addItem("Yaw",1)//.addItem("Motor 3", 3)
             .setArrayValue(ArrChbox)
             .setFont(createFont("arial",22))
             ;
             
  checkboxMotors.getItem(0).setFont(createFont("arial",16));
  checkboxMotors.getItem(0).setColorActive(color(21,73,255,255));
  checkboxMotors.getItem(0).setColorForeground(color(111,143,255,255));
  checkboxMotors.getItem(0).setColorBackground(color(70,70,70,255));
  
  checkboxMotors.getItem(1).setFont(createFont("arial",16));
  checkboxMotors.getItem(1).setColorActive(color(245,35,245,255));
  checkboxMotors.getItem(1).setColorForeground(color(244,147,255,255));
  checkboxMotors.getItem(1).setColorBackground(color(70,70,70,255));
  
  checkboxMotors.getItem(2).setFont(createFont("arial",16));
  checkboxMotors.getItem(2).setColorActive(color(53,250,28,255));
  checkboxMotors.getItem(2).setColorForeground(color(124,255,144,255));
  checkboxMotors.getItem(2).setColorBackground(color(70,70,70,255));
     
  checkbox.hide();
  checkboxMotors.hide();     
     
  float[] ArrChbox2 = {1,0};
  radiobuttonTypeMotors = cp5.addRadioButton("radiobuttonTypeMotors")
             .setPosition(1150, 80)
             .setColorLabel(color(0))
             .setSize(20, 20)             
             .setItemsPerRow(1)
             .setSpacingColumn(100)
             .setSpacingRow(15)
             .addItem("AX12a",1)//.addItem("Motor 1", 1)//.setFont(font)
             .addItem("MX28T",1)//.addItem("Motor 2", 2)             
             .setArrayValue(ArrChbox2)
             .setFont(createFont("arial",16))
             ;
             
   radiobuttonTypeMotors.getItem(0).setFont(createFont("arial",14));       
   radiobuttonTypeMotors.getItem(1).setFont(createFont("arial",14));
             
   radiobuttonTypeMotors.hide();
   /*myTextarea = cp5.addTextarea("txt")
                  .setPosition(850,250)
                  .setSize(200,200)
                  .setFont(createFont("arial",20))
                  .setLineHeight(14)
                  .setColor(color(128))
                  .setColorBackground(color(255,100))
                  .setColorForeground(color(255,100));
                  ;
  myTextarea.setText("Position");*/
  
  
  /***************************************************/
  /*                   MAX TORQUE                      */
  /***************************************************/
  
  MaxTorqueTextFieldM1 = cp5.addTextfield("MaxTorque1Text")     
     .setPosition(810,160)
     .setSize(60,25)
     .setFont(createFont("arial",15))
     //.setAutoClear(false)
     .setText("100")
     .setColorValueLabel(color(255,255,255,255))
     .setCaptionLabel("Motor 1")          
     .setColorLabel(color(0))     
     //.setLabelVisible(false)
     ;
  MaxTorqueTextFieldM1.getValueLabel().setPadding(8,0);
  MaxTorqueTextFieldM1.getCaptionLabel().setPadding(0,-50);
 
  
  MaxTorqueTextFieldM2 = cp5.addTextfield("MaxTorque2Text")     
     .setPosition(890,160)
     .setSize(60,25)
     .setFont(createFont("arial",15))
     //.setAutoClear(false)
     .setText("100")
     .setColorValueLabel(color(255,255,255,255))
     .setCaptionLabel("Motor 2")          
     .setColorLabel(color(0))  
     //.setLabelVisible(false)
     ;
  MaxTorqueTextFieldM2.getValueLabel().setPadding(8,0);
  MaxTorqueTextFieldM2.getCaptionLabel().setPadding(0,-50);
  
  
  MaxTorqueTextFieldM3 = cp5.addTextfield("MaxTorque3Text")     
     .setPosition(970,160)
     .setSize(60,25)
     .setFont(createFont("arial",15))
     //.setAutoClear(false)
     .setText("100")
     .setColorValueLabel(color(255,255,255,255))
     .setCaptionLabel("Motor 3")          
     .setColorLabel(color(0))  
     //.setLabelVisible(false)
     ;
  MaxTorqueTextFieldM3.getValueLabel().setPadding(8,0);
  MaxTorqueTextFieldM3.getCaptionLabel().setPadding(0,-50);
  
  SetMaxTorque = cp5.addButton("SetMaxTorque")
      .setBroadcast(false)
      .setFont(createFont("arial",14))
      .setCaptionLabel("Set Max Torque")
      .setValue(0)
      .setPosition(1080,160)
      .setSize(160,25)
      .setBroadcast(true)
      ;
  
  
   /***************************************************/
   /*                   TORQUE LIMIT                  */
   /***************************************************/
  
  TorqueLabel= cp5.addTextarea("TorqueLimitLabel")
     .setPosition(810,200)
     .setSize(175,25)
     .setFont(pfont12)
     //.setColorLabel(color(180,180,180,255)) 
     .setColor(color(100,100,100,255))     
  ;
  TorqueLabel.setText("Torque Limit (0% - 100%)");
  
  SliderTM1 = cp5.addSlider("sliderTorM1")
     .setPosition(810,260)//.setPosition(810,220)//
     .setSize(160,25)
     .setRange(1,100)
     .setValue(100)
     .setDecimalPrecision(0)
     .setFont(createFont("arial",16))
     .setSliderMode(Slider.FLEXIBLE)     
     .setLabel("")
     ;
     
     
  SliderTM2 = cp5.addSlider("sliderTorM2")
     .setPosition(810,220)//.setPosition(810,260)//
     .setSize(160,25)
     .setValue(100)
     .setRange(1,100)
     .setDecimalPrecision(0)
     .setFont(createFont("arial",16))
     .setSliderMode(Slider.FLEXIBLE)
     .setLabel("")
     ;
     
  SliderTM3 = cp5.addSlider("sliderTorM3")
     .setPosition(810,300)
     .setSize(160,25)
     .setValue(100)
     .setRange(1,100)
     .setDecimalPrecision(0)
     .setFont(createFont("arial",16))
     .setSliderMode(Slider.FLEXIBLE)
     .setLabel("")
     ;
  
  TorqueTextFieldM1 = cp5.addTextfield("Torque1Text")     
     .setPosition(980,260)//.setPosition(980,220)//
     .setSize(50,25)
     .setFont(createFont("arial",16))
     //.setAutoClear(false)
     .setText("100")
     .setColorValueLabel(color(255,255,255,255))
     //.setCaptionLabel("Moving Speed M1")          
     //.setColorLabel(color(0))  
     .setLabelVisible(false)
     .setLabel("")
     ;
  TorqueTextFieldM1.getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER);  
  TorqueTextFieldM1.addCallback(new CallbackListener() {
       public void controlEvent(CallbackEvent theEvent) {         
         if (theEvent.getAction()==ControlP5.ACTION_LEAVE) {
           float val = float(((Textfield)theEvent.getController()).getText());
           cp5.get(Slider.class, "sliderTorM1").setValue(val);
           //println("..."+((Textfield)theEvent.getController()).getText());
         }
       }});
       
  
  TorqueTextFieldM2 = cp5.addTextfield("Torque2Text")     
     .setPosition(980,220)//.setPosition(980,260)//
     .setSize(50,25)
     .setFont(createFont("arial",16))
     //.setAutoClear(false)
     .setText("100")
     .setColorValueLabel(color(255,255,255,255))
     //.setCaptionLabel("Moving Speed M1")          
     //.setColorLabel(color(0))     
     .setLabelVisible(false)
     .setLabel("")
     ;
  TorqueTextFieldM2.getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  TorqueTextFieldM2.addCallback(new CallbackListener() {
       public void controlEvent(CallbackEvent theEvent) {         
         if (theEvent.getAction()==ControlP5.ACTION_LEAVE) {
           float val = float(((Textfield)theEvent.getController()).getText());
           cp5.get(Slider.class, "sliderTorM2").setValue(val);
         }
       }});
       
       
  TorqueTextFieldM3 = cp5.addTextfield("Torque3Text")     
     .setPosition(980,300)
     .setSize(50,25)
     .setFont(createFont("arial",16))
     //.setAutoClear(false)
     .setText("100")
     .setColorValueLabel(color(255,255,255,255))
     //.setCaptionLabel("Moving Speed M1")          
     //.setColorLabel(color(0))  
     .setLabelVisible(false)
     .setLabel("")
     ;
  TorqueTextFieldM3.getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  TorqueTextFieldM3.addCallback(new CallbackListener() {
       public void controlEvent(CallbackEvent theEvent) {         
         if (theEvent.getAction()==ControlP5.ACTION_LEAVE) {
           float val = float(((Textfield)theEvent.getController()).getText());
           cp5.get(Slider.class, "sliderTorM3").setValue(val);
         }
       }});
       
       
  TorqueEnableLabel= cp5.addTextarea("TorqueEnableLabel")
     .setPosition(1030,200)
     .setSize(175,25)
     .setFont(pfont12)
     //.setColorLabel(color(180,180,180,255)) 
     .setColor(color(100,100,100,255))     
  ;
  TorqueEnableLabel.setText("Torque Enable");
       
  TorqueEnable1 = cp5.addToggle("T1Enable")
     .setBroadcast(false)
     .setFont(createFont("arial",12))
     .setPosition(1040,260)//.setPosition(1040,220)//
     .setSize(70,25)      
     .setCaptionLabel("Enable")
     .align(2,1,3,3)
     .setColorLabel(color(255,255,255,255))
     .setBroadcast(true)
     ;
  
  TorqueEnable2 = cp5.addToggle("T2Enable")
     .setBroadcast(false)
     .setFont(createFont("arial",12))
     .setPosition(1040,220)//.setPosition(1040,260)//
     .setSize(70,25)      
     .setCaptionLabel("Enable")
     .align(2,1,3,3)
     .setColorLabel(color(255,255,255,255))
     .setBroadcast(true)
     ;
     
  TorqueEnable3 = cp5.addToggle("T3Enable")
     .setBroadcast(false)
     .setFont(createFont("arial",12))
     .setPosition(1040,300)
     .setSize(70,25)      
     .setCaptionLabel("Enable")
     .align(2,1,3,3)
     .setColorLabel(color(255,255,255,255))
     .setBroadcast(true)
     ;
  
  
  
   SetTorque = cp5.addButton("SetTorque")
      .setBroadcast(false)
      .setFont(createFont("arial",12))
      .setCaptionLabel("Set Torque Limit")
      .setValue(0)
      .setPosition(1120,220)
      .setSize(120,70)
      .setBroadcast(true)
      ;
      
      
  /***************************************************/
  /*                   POSICIÓN                      */
  /***************************************************/
  
  PositionLabel= cp5.addTextarea("PositionLabel")
     .setPosition(810,330)
     .setSize(175,25)
     .setFont(pfont12)
     //.setColorLabel(color(180,180,180,255)) 
     .setColor(color(100,100,100,255))     
  ;
  PositionLabel.setText("Position (0° - 300°)");
  
  
  SliderM1 = cp5.addSlider("sliderPosM1")
     .setPosition(810,390)//.setPosition(810,350)//
     .setSize(160,25)
     .setRange(1,300)
     .setValue(150)
     .setDecimalPrecision(0)
     .setFont(createFont("arial",16))
     .setSliderMode(Slider.FLEXIBLE)     
     .setLabel("")
     ;
     
  SliderM2 = cp5.addSlider("sliderPosM2")
     .setPosition(810,350)//.setPosition(810,390)//
     .setSize(160,25)
     .setValue(150)
     .setRange(1,300)
     .setDecimalPrecision(0)
     .setFont(createFont("arial",16))
     .setSliderMode(Slider.FLEXIBLE)
     .setLabel("")
     ;
     
  SliderM3 = cp5.addSlider("sliderPosM3")
     .setPosition(810,430)
     .setSize(160,25)
     .setValue(150)
     .setRange(1,300)
     .setDecimalPrecision(0)
     .setFont(createFont("arial",16))
     .setSliderMode(Slider.FLEXIBLE)
     .setLabel("")
     ;
     
     
  PositionTextFieldM1 = cp5.addTextfield("Position1Text")     
     .setPosition(980,390)//.setPosition(980,350)//
     .setSize(50,25)
     .setFont(createFont("arial",16))
     //.setAutoClear(false)
     .setText("150")
     .setColorValueLabel(color(255,255,255,255))
     //.setCaptionLabel("Moving Speed M1")          
     //.setColorLabel(color(0))  
     .setLabelVisible(false)
     .setLabel("")
     ;
  PositionTextFieldM1.getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  PositionTextFieldM1.addCallback(new CallbackListener() {
       public void controlEvent(CallbackEvent theEvent) {         
         if (theEvent.getAction()==ControlP5.ACTION_LEAVE) {
           float val = float(((Textfield)theEvent.getController()).getText());
           cp5.get(Slider.class, "sliderPosM1").setValue(val);
         }
       }});
     
  PositionTextFieldM2 = cp5.addTextfield("Position2Text")     
     .setPosition(980,350)//.setPosition(980,390)//
     .setSize(50,25)
     .setFont(createFont("arial",16))
     //.setAutoClear(false)
     .setText("150")
     .setColorValueLabel(color(255,255,255,255))
     .setLabelVisible(false)
     .setLabel("")
     ;
  PositionTextFieldM2.getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  PositionTextFieldM2.addCallback(new CallbackListener() {
       public void controlEvent(CallbackEvent theEvent) {         
         if (theEvent.getAction()==ControlP5.ACTION_LEAVE) {
           float val = float(((Textfield)theEvent.getController()).getText());
           cp5.get(Slider.class, "sliderPosM2").setValue(val);
         }
       }});
  PositionTextFieldM2.setLabelVisible(false);       
       
  PositionTextFieldM3 = cp5.addTextfield("Position3Text")     
     .setPosition(980,430)
     .setSize(50,25)
     .setFont(createFont("arial",16))
     //.setAutoClear(false)
     .setText("150")
     .setColorValueLabel(color(255,255,255,255))
     .setLabelVisible(false)
     .setLabel("")
     ;   
  PositionTextFieldM3.getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  PositionTextFieldM3.addCallback(new CallbackListener() {
       public void controlEvent(CallbackEvent theEvent) {         
         if (theEvent.getAction()==ControlP5.ACTION_LEAVE) {
           float val = float(((Textfield)theEvent.getController()).getText());
           cp5.get(Slider.class, "sliderPosM3").setValue(val);
         }
       }});
  
  
  MovingSpeedLabel = cp5.addTextarea("MovingSpeed")
     .setPosition(1030,330)
     .setSize(180,25)
     .setFont(pfont12)
     //.setColorLabel(color(180,180,180,255)) 
     .setColor(color(100,100,100,255))     
  ;
  MovingSpeedLabel.setText("Moving Speed(0rpm-114rpm)");
  
   
  MovingSpeedTextFieldM1 = cp5.addTextfield("MovingSpeed1Text")     
     .setPosition(1050,390)//.setPosition(1050,350)//
     .setSize(50,25)
     .setFont(createFont("arial",16))
     //.setAutoClear(false)
     .setText("5")
     .setColorValueLabel(color(0,0,0,255))     
     //.setCaptionLabel("Moving Speed M1")          
     //.setColorLabel(color(0))  
     .setColorBackground(color(228,245,0))
     .setLabelVisible(false)
     .setLabel("")
     ;     
  MovingSpeedTextFieldM1.getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  
  MovingSpeedTextFieldM2 = cp5.addTextfield("MovingSpeed2Text")     
     .setPosition(1050,350)//.setPosition(1050,390)//
     .setSize(50,25)
     .setFont(createFont("arial",16))
     //.setAutoClear(false)
     .setText("5")
     .setColorValueLabel(color(0,0,0,255))     
     //.setCaptionLabel("Moving Speed M1")          
     //.setColorLabel(color(0))  
     .setColorBackground(color(228,245,0))
     .setLabelVisible(false)
     .setLabel("")
     ;     
  MovingSpeedTextFieldM2.getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  
  MovingSpeedTextFieldM3 = cp5.addTextfield("MovingSpeed3Text")     
     .setPosition(1050,430)
     .setSize(50,25)
     .setFont(createFont("arial",16))
     //.setAutoClear(false)
     .setText("5")
     .setColorValueLabel(color(20,20,20,255))     
     //.setCaptionLabel("Moving Speed M1")          
     //.setColorLabel(color(0))  
     .setColorBackground(color(228,245,0))     
     .setLabelVisible(false)
     .setLabel("")
     ;     
  MovingSpeedTextFieldM3.getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER);     
     
  SetPosition = cp5.addButton("SetPositionCallbak")
      .setBroadcast(false)
      .setFont(createFont("arial",12))
      .setCaptionLabel("Set Position")
      .setValue(0)
      .setPosition(1120,350)
      .setSize(110,70)      
      .setBroadcast(true)
      ;
      
  // create a toggle
  SyncPosbutton = cp5.addToggle("SyncPos")
     .setBroadcast(false)
     .setFont(createFont("arial",12))
     .setPosition(1120,430)
     .setSize(110,30)      
     .setCaptionLabel("Sync Position")
     .align(2,1,3,3)
     .setColorLabel(color(255,255,255,255))
     .setBroadcast(true)
     ;
      
  /*********************************************/
  /*                   VELOCIDAD               */
  /*********************************************/
      
   VelocityLabel = cp5.addTextarea("VelocityLabel")
     .setPosition(810,460)
     .setSize(180,25)
     .setFont(pfont12)
     //.setColorLabel(color(180,180,180,255)) 
     .setColor(color(100,100,100,255))     
  ;
  VelocityLabel.setText("Velocity(0 - 2047)");
  
  SliderVM1 = cp5.addSlider("sliderVelM1")
     .setPosition(810,520)//.setPosition(810,480)//
     .setSize(160,25)
     .setRange(-1024,1024)//(0,2047)
     .setValue(0)//(1024)
     .setDecimalPrecision(0)
     .setFont(createFont("arial",16))
     .setSliderMode(Slider.FLEXIBLE)
     .setLabel("")
     ;
     
  SliderVM2 = cp5.addSlider("sliderVelM2")
     .setPosition(810,480)//.setPosition(810,520)//
     .setSize(160,25)
     .setRange(-1024,1024)//(0,2047)
     .setValue(0)//(1024)
     .setDecimalPrecision(0)
     .setFont(createFont("arial",16))
     .setSliderMode(Slider.FLEXIBLE)
     .setLabel("")
     ;
     
  SliderVM3 = cp5.addSlider("sliderVelM3")
     .setPosition(810,560)
     .setSize(160,25)
     .setRange(-1024,1024)//(0,2047)
     .setValue(0)//(1024)
     .setDecimalPrecision(0)
     .setFont(createFont("arial",16))
     .setSliderMode(Slider.FLEXIBLE)
     .setLabel("")
     ;
     
     
  VelocityTextFieldM1 = cp5.addTextfield("Velocity1Text")     
     .setPosition(980,520)//.setPosition(980,480)//
     .setSize(50,25)
     .setFont(createFont("arial",16))
     .setText("0")//("1024")
     .setColorValueLabel(color(255,255,255,255))
     .setLabelVisible(false)
     .setLabel("")
     ;
  VelocityTextFieldM1.getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  VelocityTextFieldM1.addCallback(new CallbackListener() {
       public void controlEvent(CallbackEvent theEvent) {         
         if (theEvent.getAction()==ControlP5.ACTION_LEAVE) {
           float val = float(((Textfield)theEvent.getController()).getText());
           cp5.get(Slider.class, "sliderVelM1").setValue(val);
         }
       }});
       
       
  VelocityTextFieldM2 = cp5.addTextfield("Velocity2Text")     
     .setPosition(980,480)//.setPosition(980,520)//
     .setSize(50,25)
     .setFont(createFont("arial",16))
     .setText("0")//("1024").setText("1024")
     .setColorValueLabel(color(255,255,255,255))
     .setLabelVisible(false)
     .setLabel("")
     ;
  VelocityTextFieldM2.getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  VelocityTextFieldM2.addCallback(new CallbackListener() {
       public void controlEvent(CallbackEvent theEvent) {         
         if (theEvent.getAction()==ControlP5.ACTION_LEAVE) {
           float val = float(((Textfield)theEvent.getController()).getText());
           cp5.get(Slider.class, "sliderVelM2").setValue(val);
         }
       }});
       
  VelocityTextFieldM3 = cp5.addTextfield("Velocity3Text")     
     .setPosition(980,560)
     .setSize(50,25)
     .setFont(createFont("arial",16))
     .setText("0")//("1024").setText("1024")
     .setColorValueLabel(color(255,255,255,255))
     .setLabelVisible(false)
     .setLabel("")
     ;
  VelocityTextFieldM3.getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  VelocityTextFieldM3.addCallback(new CallbackListener() {
       public void controlEvent(CallbackEvent theEvent) {         
         if (theEvent.getAction()==ControlP5.ACTION_LEAVE) {
           float val = float(((Textfield)theEvent.getController()).getText());
           cp5.get(Slider.class, "sliderVelM3").setValue(val);
         }
       }});
       
       
      
  SetVelocity = cp5.addButton("SetVelocity")
      .setBroadcast(false)
      .setFont(createFont("arial",12))
      .setCaptionLabel("Set Velocity")
      .setValue(0)
      .setPosition(1110,480)
      .setSize(110,70)
      .setBroadcast(true)
      ;
   
  SyncVelbutton = cp5.addToggle("SyncVel")
     .setBroadcast(false)
     .setFont(createFont("arial",12))
     .setPosition(1110,560)
     .setSize(110,30)      
     .setCaptionLabel("Sync Velocity")
     .align(2,1,3,3)
     .setColorLabel(color(255,255,255,255))
     .setBroadcast(true)
     ;
      
  SetVelocityZero = cp5.addButton("SetVelocityZero")
      .setBroadcast(false)
      .setFont(createFont("arial",10))
      .setCaptionLabel("Set Zero")
      .setValue(0)
      .setPosition(1040,500)
      .setSize(60,60)
      .setBroadcast(true)
      ;
  
  /*********************************************/
  /*              GET TEXT(.TXT)               */
  /*********************************************/  
      
  //ScrollableList
  SerialList.getCaptionLabel().setFont(font);
  SerialList.getValueLabel().setFont(font);

  GuardarBtn = cp5.addToggle("SaveFunc")
     .setBroadcast(false)
     .setFont(font)
     .setPosition(930,635)
     .setSize(50,30)
     .setColorLabel(color(20,22,131)) 
     .setBroadcast(true)
     ;
  GuardarBtn.getCaptionLabel().setFont(createFont("arial",14));
  
  TxtFileName =cp5.addTextfield("Txt File")
     .setPosition(810,635)//850
     .setSize(110,30)
     //.setFont(font)
     .setFont(createFont("arial",15))
     .setFocus(true)
     .setColorLabel(color(20,22,131)) 
     .setColor(255)     
  ;  
  TxtFileName.setText("Test1.txt");
  TxtFileName.getCaptionLabel().setFont(createFont("arial",14));
  
  
  plotbutton.hide();
  Filtro.hide();
  HideAll();
  LockAllControlls();
  
}


void draw() {
  background(255);
  
  //shape(fuselage,100,100);  
  //image(img,1010, 20,150,140);
  
  
  
  //**********************************************************************
  //***************************JUST FOR DEBUG*****************************
  //**********************************************************************
  
  /*StartConnectionOneShot = true;//JUST FOR DEBUG
  SystemMode=1; //JUST FOR DEBUG  1:MOTOR 2:ENCODER
  ModeMotorJointWheel=0;//JUST FOR DEBUG
  ModeUnlockControl=true;//JUST FOR DEBUG
  GraficarFlag = true;//JUST FOR DEBUG
  
  if(SystemMode==2)
  {
    rolldisplayE.update(DataE1,1);         
    RollTextAreaE.setText("Roll= " + DataE1 + "°" );//(correccionPosM1display) + "[" + PositionM1 +"]");   
     
    pitchdisplayE.update(DataE2,2);
    PitchTextAreaE.setText("Pitch= " + (DataE2) + "°" );//(correccionPosM1display) + "[" + PositionM1 +"]");
     
    yawdisplayE.update(DataE3,3);         
    YawTextAreaE.setText("Yaw= " + DataE3 + "°" );//(correccionPosM1display) + "[" + PositionM1 +"]");    
  }else
  {  
    
    PositionM1 = 100;
    PositionM2 = 150;
    PositionM3 = 200;
    
    pitchdisplay.update(PositionM2,2);         //PositionM2
    PitchTextArea.setText("Roll= " + PositionM2+ "°" );//(correccionPosM1display) + "[" + PositionM1 +"]");
    
    rolldisplay.update(PositionM1,1);         //PositionM1
    RollTextArea.setText("Pitch= " + PositionM1+ "°" );//(correccionPosM1display) + "[" + PositionM1 +"]");
         
    yawdisplay.update(PositionM3,3);        //PositionM3 
    YawTextArea.setText("Yaw= " + PositionM3+ "°" );//(correccionPosM1display) + "[" + PositionM1 +"]");
    
  }*/
  
  //**********************************************************************
  //**********************************************************************
  
  
  
  
  if(StartConnectionOneShot && SystemMode==1){
    pitchdisplay.display(true);
    rolldisplay.display(true);
    yawdisplay.display(true);
    
    if(ModeMotorJointWheel==0){
      JointWheelMode.setText("");
      setModeJW.setLabel("");
    }else if(ModeMotorJointWheel==1){
      if(ModeUnlockControl){
        JointWheelMode.setText("Joint Mode");
        setModeJW.setLabel("Joint Mode");
        UnlockJointMode();
      }
      plot_mvel.getYAxis().getAxisLabel().setText("Present Speed(rpm)");
    }else if(ModeMotorJointWheel==2){
      if(ModeUnlockControl){
        JointWheelMode.setText("Wheel Mode");
        setModeJW.setLabel("Wheel Mode");
        UnlockWheelMode();
      }
      
      plot_mvel.getYAxis().getAxisLabel().setText("Present Speed(%)");
    }
       
  }else if(StartConnectionOneShot && SystemMode==2){
     pitchdisplayE.display(true);
     rolldisplayE.display(true);
     yawdisplayE.display(true);
    
  }
  
  
  GPointsArray pointsVoid = new GPointsArray(Npoints);  
  GPointsArray pointsx1test = new GPointsArray(Npoints);
  GPointsArray pointsy1test = new GPointsArray(Npoints);
  GPointsArray pointsz1test = new GPointsArray(Npoints);  
  GPointsArray pointsm1pos = new GPointsArray(Npoints);
  GPointsArray pointsm2pos = new GPointsArray(Npoints);
  GPointsArray pointsm3pos = new GPointsArray(Npoints);  
  GPointsArray pointsm1vel = new GPointsArray(Npoints);
  GPointsArray pointsm2vel = new GPointsArray(Npoints);
  GPointsArray pointsm3vel = new GPointsArray(Npoints);  
  GPointsArray pointsm1tor = new GPointsArray(Npoints);
  GPointsArray pointsm2tor = new GPointsArray(Npoints);
  GPointsArray pointsm3tor = new GPointsArray(Npoints);  
  GPointsArray pointsm1volt = new GPointsArray(Npoints);
  GPointsArray pointsm2volt = new GPointsArray(Npoints);
  GPointsArray pointsm3volt = new GPointsArray(Npoints);  
  GPointsArray pointsm1temp = new GPointsArray(Npoints);
  GPointsArray pointsm2temp = new GPointsArray(Npoints);
  GPointsArray pointsm3temp = new GPointsArray(Npoints);
  
  
  if(FlagPortAvailable){ // Si si se establecio la conexion y el puerto esta disponible
  
    ConectarPort.setColorBackground(#22FA03);
    ConectarPort.setColorForeground(#22FA03);
    ConectarPort.setCaptionLabel("Connected");        
    
    if(!plotButtonOneShot){
      plotButtonOneShot=true;
      plotbutton.show();
      plotbutton.setState(true);
      
      Filtro.show();
      Filtro.setState(true);
     
    }
    
    /******************************************/
    /*                LEER SERIAL             */
    /******************************************/
    //ReadSerial(myPort);
    ReadSerial32Bytes(myPort);
    
  }else{
    ConectarPort.setColorBackground(#171D81);
    ConectarPort.setColorForeground(#307FFA);
    ConectarPort.setCaptionLabel("Connect"); 
    DataInfo_str = "Esperando Conexión...";
    
    FlagOneReset = true;
    if(FlagOneReset){
      FlagOneReset = false;
    }
    
    if(HideFlag){
      HideFlag=false;
      //HideAll();
      plotbutton.setState(false);
      Filtro.setState(false);
    }
    //println("Esperando conexiones<<<<<<<<<<<<<<<");
  }

   
   /******************************************/
   /*            Proceso la Informacion      */
   /******************************************/
   
   //println("FlagPortDataAvailable:" + FlagPortDataAvailable + " SystemMode:" + SystemMode + " BufferUSB.length():" + BufferUSB.length() + " BufferUSB: " + BufferUSB);//<<21/jun/22
   
   if(FlagPortDataAvailable || (BufferUSB.length()==32  && BufferUSB.charAt(BufferUSB.length()-1) == '{') ){
     FlagPortDataAvailable=false;     
     
     //println("L: " +  str(BufferUSB.length()) +"-->>>"+ BufferUSB);//<<21/jun/22
     
     //DEBUG
     /*for(int l=0;l<BufferUSB.length();l++){
       print("[" + str(l) + ":" + hex(BufferUSB.charAt(l),2) + "]  ");
     }
     println();*/
     
     if(BufferUSB.length()==32){
       
       SystemMode = int(BufferUSB.charAt(1));
       
       if(SystemMode==2){//Encoders
         SystemModeMotorEncoder = 2;
       
       /**************************************************************************************/
       /*                                       ENCODERS                                     */
       /**************************************************************************************/
         
         String[] DataEncoders = split(BufferUSB, ',');   
         //println(t+ ".- Encoder 1:" + DataEncoders[1]  + " Encoder2: " + DataEncoders[2] + " Encoder 3: " + DataEncoders[3]);
         //pointsx1.add(t,float(DataEncoders[1]));
                  
         float DataE1Aux = float(DataEncoders[1]);// - PitchCompHome;
         float DataE2Aux = float(DataEncoders[2]);// - RollCompHome;
         float DataE3Aux = float(DataEncoders[3]);// - YawCompHome;
                  
         float Aux = 0;
         if(FlagHomeCompensation){
           DataE1Aux = DataE1Aux - PitchCompHome;
           DataE2Aux = DataE2Aux - RollCompHome;
           DataE3Aux = DataE3Aux - YawCompHome;
           
           DataE1Aux = normaliseAngle(DataE1Aux);
           DataE2Aux = normaliseAngle(DataE2Aux);
           DataE3Aux = normaliseAngle(DataE3Aux);           
         }       
         
         DataE1Filter = DataE1Aux;
         DataE2Filter = DataE2Aux;
         DataE3Filter = DataE3Aux;         
         
         if(FiltroSwitchFlag){
           if(contPoint>=Npoints){
             
             ValuesX[Npoints-1] = DataE1;          
             ValuesY[Npoints-1] = DataE2;
             ValuesZ[Npoints-1] = DataE3;
            
             DataE1Filter = Filter2(DataE1Aux,ValuesX,Npoints,3);
             DataE2Filter = Filter2(DataE2Aux,ValuesY,Npoints,3);
             DataE3Filter = Filter2(DataE3Aux,ValuesZ,Npoints,3);
             
           }
         }
         
         DataE1 = DataE1Filter;
         DataE2 = DataE2Filter;
         DataE3 = DataE3Filter;  
         
         child.yaw_ch    = DataE1;
         child.pitch_ch  = DataE2;
         child.roll_ch   = DataE3;
         
         pfdchild.pitch = DataE1;
         pfdchild.roll = DataE2;
         pfdchild.yaw = DataE3;
         //println("DataE1: " + DataE1  + " DataE1Filter: " + DataE1Filter + " PitchCompHome: " + PitchCompHome + " DataE1Aux: "+ DataE1Aux);
         
         //println("update:   DataE1: " + DataE1 +  " Data E1 Compensado "+ Aux + " yaw+270:" + (DataE1+270));
         
         //UPDATE:22/Jul/2022
         rolldisplayE.update(DataE1,1);         
         RollTextAreaE.setText("Roll= " + DataE1 + "°" );//(correccionPosM1display) + "[" + PositionM1 +"]");   
         
         pitchdisplayE.update(DataE2,2);
         PitchTextAreaE.setText("Pitch= " + (DataE2) + "°" );//(correccionPosM1display) + "[" + PositionM1 +"]");
         
         yawdisplayE.update(DataE3,3);         
         YawTextAreaE.setText("Yaw= " + DataE3 + "°" );//(correccionPosM1display) + "[" + PositionM1 +"]");
         
         
       }else if(SystemMode ==1){  //Motores
         SystemModeMotorEncoder=1;
         
         /**************************************************************************************/
         /*                                       MOTORES                                      */
         /**************************************************************************************/
         
         
         int Error1  =  int(BufferUSB.charAt(3));
         int Error2  =  int(BufferUSB.charAt(4));
         int Error3  =  int(BufferUSB.charAt(5));
        
         int Torque1Bytes = int(BufferUSB.charAt(6)) | int(BufferUSB.charAt(7))<<8 ;//int(BufferUSB.substring(6,7));
         int Torque2Bytes = int(BufferUSB.charAt(8)) | int(BufferUSB.charAt(9))<<8;//int(BufferUSB.substring(8,9));
         int Torque3Bytes = int(BufferUSB.charAt(10))| int(BufferUSB.charAt(11))<<8 ;//int(BufferUSB.substring(10,11));
        
         int Velocity1Bytes = int(BufferUSB.charAt(12)) | int(BufferUSB.charAt(13))<<8 ;//int(BufferUSB.substring(12,13)); int Velocity1Bytes = byte(BufferUSB.charAt(12)) | byte(BufferUSB.charAt(13))<<8;//int(BufferUSB.substring(12,13));  
         int Velocity2Bytes = int(BufferUSB.charAt(14)) | int(BufferUSB.charAt(15))<<8 ;//int(BufferUSB.substring(14,15));
         int Velocity3Bytes = int(BufferUSB.charAt(16)) | int(BufferUSB.charAt(17))<<8 ;//int(BufferUSB.substring(16,17));

         int Pos1Bytes = (int(BufferUSB.charAt(18))) | (int(BufferUSB.charAt(19)))<<8;
         int Pos2Bytes = (int(BufferUSB.charAt(20))) | (int(BufferUSB.charAt(21)))<<8;//int(BufferUSB.substring(20,21));
         int Pos3Bytes = (int(BufferUSB.charAt(22))) | (int(BufferUSB.charAt(23)))<<8;//int(BufferUSB.substring(22,23));
         
         int Volt1Bytes = int(BufferUSB.charAt(24));
         int Volt2Bytes = int(BufferUSB.charAt(25));
         int Volt3Bytes = int(BufferUSB.charAt(26));
         
         int Temp1Bytes = int(BufferUSB.charAt(27));
         int Temp2Bytes = int(BufferUSB.charAt(28));
         int Temp3Bytes = int(BufferUSB.charAt(29));
         
         int aux_mode = int(BufferUSB.charAt(30));
         int Motor1_mode =  (aux_mode & 48)>>4;
         int Motor2_mode =  (aux_mode & 12)>>2;
         int Motor3_mode =  (aux_mode & 3);
         
         
         //println("MOTORS ----->> [ " + Pos1Bytes + "," + Pos2Bytes + "," + Pos3Bytes + "]");
         //println("MOTORS MODE----->>" + aux_mode + " Motor1 : " + Motor1_mode + " Motor2: " + Motor2_mode + " Motor3: " + Motor3_mode);
         //println("TEMPERATURE DEBUG ---->>    Temp1 :" + int(BufferUSB.charAt(27)) + " Temp 2: " + int(BufferUSB.charAt(28)) + " Temp 3: " + int(BufferUSB.charAt(29)));
         //println("TEMPERATURE DEBUG HEX---->> Temp1 :" + hex(BufferUSB.charAt(27)) + " Temp 2: " + hex(BufferUSB.charAt(28)) + " Temp 3: " + hex(BufferUSB.charAt(29)));
         
         if(Motor1_mode == Motor2_mode && Motor1_mode ==Motor3_mode){
           if(Motor1_mode==1){
             ModeMotorJointWheel= 2; //wheel
           }else if(Motor1_mode==2){
             ModeMotorJointWheel= 1; //joint
           }
           
         }else if(Motor1_mode==0 && Motor2_mode ==0 && Motor3_mode==0){
           JointWheelMode.setText("MOTORS UNKNOW STATE");
         }else{           
           println("Los motores estan en diferentes modos...MOTORS MODE----->>" + aux_mode + " Motor1 : " + Motor1_mode + " Motor2: " + Motor2_mode + " Motor3: " + Motor3_mode + "  HEX= " + (hex(aux_mode)));
           JointWheelMode.setText("ERROR: MOTORES DESC");
         }
         
                  
         //FILTRO
         float PositionM1Aux = float(Pos1Bytes)*MotorRes;//*0.088;//*0.2932;
         float PositionM2Aux = float(Pos2Bytes)*MotorRes;//*0.088;//*0.2932;
         float PositionM3Aux = float(Pos3Bytes)*MotorRes;//*0.088;//*0.2932;
         
         float VelocityM1Aux = float(Velocity1Bytes & int(1023));//*0.1;
         float VelocityM2Aux = float(Velocity2Bytes & int(1023));//*0.1;
         float VelocityM3Aux = float(Velocity3Bytes & int(1023));//*0.1;
         
         //println("1.- Present PositionMxAux [" + PositionM1Aux + "," + PositionM2Aux + "," + PositionM3Aux + "]");//<<21/jun/22
        
         if(ModeMotorJointWheel==1){//Join
           
           VelocityM1Aux = VelocityM1Aux*0.1113;
           VelocityM2Aux = VelocityM2Aux*0.1113;
           VelocityM3Aux = VelocityM3Aux*0.1113;
           
         }else if(ModeMotorJointWheel==2){//Wheel
         
           VelocityM1Aux = VelocityM1Aux*0.1;
           VelocityM2Aux = VelocityM2Aux*0.1;
           VelocityM3Aux = VelocityM3Aux*0.1;
           
         }
         
                  
         float TorqueM1Aux = float(Torque1Bytes)*0.0977;
         float TorqueM2Aux = float(Torque2Bytes)*0.0977;
         float TorqueM3Aux = float(Torque3Bytes)*0.0977;
         
         float VoltageM1Aux = float(Volt1Bytes)/10.0;
         float VoltageM2Aux = float(Volt2Bytes)/10.0;
         float VoltageM3Aux = float(Volt3Bytes)/10.0;
         
         float TemperatureM1Aux = (float)Temp1Bytes;
         float TemperatureM2Aux = (float)Temp2Bytes;
         float TemperatureM3Aux = (float)Temp3Bytes;
         
         
         //Filtros
         float PositionM1filter = PositionM1Aux;
         float PositionM2filter = PositionM2Aux;
         float PositionM3filter = PositionM3Aux;
         
         float VelocityM1filter = VelocityM1Aux;
         float VelocityM2filter = VelocityM2Aux;
         float VelocityM3filter = VelocityM3Aux;
         
         float TorqueM1filter = TorqueM1Aux;
         float TorqueM2filter = TorqueM2Aux;
         float TorqueM3filter = TorqueM3Aux;
         
         float VoltageM1filter = VoltageM1Aux;
         float VoltageM2filter = VoltageM2Aux;
         float VoltageM3filter = VoltageM3Aux;
         
         float TemperatureM1filter = TemperatureM1Aux;
         float TemperatureM2filter = TemperatureM2Aux;
         float TemperatureM3filter = TemperatureM3Aux;
         
         
         if(FiltroSwitchFlag){
           if(contPoint>=Npoints){
             PositionM1filter = Filter1(PositionM1Aux,ValuesPos1,Npoints,3);
             PositionM2filter = Filter1(PositionM2Aux,ValuesPos2,Npoints,3);
             PositionM3filter = Filter1(PositionM3Aux,ValuesPos3,Npoints,3);
           
             VelocityM1filter = Filter2(VelocityM1Aux,ValuesVel1,Npoints,3);
             VelocityM2filter = Filter2(VelocityM2Aux,ValuesVel2,Npoints,3);
             VelocityM3filter = Filter2(VelocityM3Aux,ValuesVel3,Npoints,3);
             
             //TorqueM1filter = Filter1(TorqueM1Aux,ValuesVel1,Npoints,3);
             //TorqueM2filter = Filter1(TorqueM2Aux,ValuesVel2,Npoints,3);
             //TorqueM3filter = Filter1(TorqueM3Aux,ValuesVel3,Npoints,3);
             
             VoltageM1filter = Filter2(VoltageM1Aux,ValuesVolt1,Npoints,3);
             VoltageM2filter = Filter2(VoltageM2Aux,ValuesVolt2,Npoints,3);
             VoltageM3filter = Filter2(VoltageM3Aux,ValuesVolt3,Npoints,3);
              
             TemperatureM1filter = Filter2(TemperatureM1Aux,ValuesTemp1,Npoints,3);
             TemperatureM2filter = Filter2(TemperatureM2Aux,ValuesTemp2,Npoints,3);
             TemperatureM3filter = Filter2(TemperatureM3Aux,ValuesTemp3,Npoints,3);
           }
         }
         
                  
         PositionM1 = PositionM1filter;//float(Pos1Bytes)*0.2932;
         PositionM2 = PositionM2filter; //float(Pos2Bytes)*0.2932;
         PositionM3 = PositionM3filter; //float(Pos3Bytes)*0.2932;
         
         VelocityM1 = VelocityM1filter;//float(Velocity1Bytes & int(1023))*0.1;
         VelocityM2 = VelocityM2filter;//float(Velocity2Bytes & int(1023))*0.1;
         VelocityM3 = VelocityM3filter;//float(Velocity3Bytes & int(1023))*0.1;
         
         TorqueM1 = TorqueM1filter;//float(Torque1Bytes & int(1023))*0.1;
         TorqueM2 = TorqueM2filter;//float(Torque2Bytes & int(1023))*0.1;
         TorqueM3 = TorqueM3filter;//float(Torque3Bytes & int(1023))*0.1;
         
         VoltageM1= VoltageM1filter;//float(Volt1Bytes)/10.0;
         VoltageM2= VoltageM2filter;//float(Volt2Bytes)/10.0;
         VoltageM3= VoltageM3filter;//float(Volt3Bytes)/10.0;
         
         TemperatureM1 = TemperatureM1filter;//(float)Temp1Bytes;
         TemperatureM2 = TemperatureM2filter;//(float)Temp2Bytes;
         TemperatureM3 = TemperatureM3filter;//(float)Temp3Bytes;
     
         child.yaw_ch     = PositionM1;
         child.pitch_ch   = PositionM2;
         child.roll_ch    = PositionM3;         
         
         pfdchild.pitch = PositionM1;
         pfdchild.roll = PositionM2;
         pfdchild.yaw = PositionM3;
         
         //println("Position M1: " + PositionM1 + "  Present Position Bytes [" + Pos1Bytes + "," + Pos2Bytes + "," + Pos3Bytes +  "]  PRESENT SPEED "  + (Velocity1Bytes & int(1023))  +   " PRESENT SPEED:    [" + VelocityM1Aux + ","+VelocityM2Aux+","+VelocityM2Aux+"] ");
         //println("Velocidad de cada motor [" + VelocityM1 + " , " + VelocityM2 + " , " + VelocityM3 + "]");
         
         //println("2.- Present PositionMxAux [" + PositionM1Aux + "," + PositionM2Aux + "," + PositionM3Aux + "]");  //<<21/jun/22
         
         //UPDATE:30/SEP/2021         
         rolldisplay.update(PositionM1Aux,2);         //PositionM1
         RollTextArea.setText("Roll= " + PositionM1+ "°" );//(correccionPosM1display) + "[" + PositionM1 +"]");
                  
         pitchdisplay.update(PositionM2Aux,1);         //PositionM2
         PitchTextArea.setText("Pitch= " + PositionM2+ "°" );//(correccionPosM1display) + "[" + PositionM1 +"]");
         
         yawdisplay.update(PositionM3Aux,3);        //PositionM3 
         YawTextArea.setText("Yaw= " + PositionM3+ "°" );//(correccionPosM1display) + "[" + PositionM1 +"]");
                  
                  
                  
         /*if(VelocityM1 <= 1 && VelocityM2 <= 1 && VelocityM3 <= 1 && EmergencyStopFlag){
           EmergencyStopFlag=false;
           setModeJW.setState(true);
         }else{
           setModeJW.setState(false);
         }*/
         
         
       }
       
       
       //BufferUSB="";
     }else{//DEBUG:PAQUETES DIFERENTES  A 32 BYTES
       println("L: " +  str(BufferUSB.length()) +"-->>>"+ BufferUSB);
       int L = BufferUSB.length();
       for(int i=0;i<L;i++){
         println(str(i) + ".- " + str(byte(BufferUSB.charAt(i))));
       }
       println("***********");
     }
     
   }
   
   
    if(GuardarFlag){
     
     int d = day();    // Values from 1 - 31
     int m = month();  // Values from 1 - 12
     int y = year();   // 2003, 2004, 2005, etc
  
     int s = second();  // Values from 0 - 59
     int mn = minute();  // Values from 0 - 59
     int h = hour();    // Values from 0 - 23
     String Timestamp = d + "/"+ m + "/" + y + "," + h + ":" + mn + ":" + s;
     if(SystemMode==1){ //Motores
       //String Data = Timestamp + "," + PositionM1 + "," + VelocityM1 + "," + TorqueM1 + "," + VoltageM1 + "," + TemperatureM1 + "," + PositionM2 + "," + VelocityM2 + "," + TorqueM2 + "," + VoltageM2 + "," + TemperatureM2 + "," + PositionM3 + "," + VelocityM3 + "," + TorqueM3 + "," + VoltageM3 + "," + TemperatureM3;
       String Data = Timestamp + "," + PositionM2 + "," + VelocityM2 + "," + TorqueM2 + "," + VoltageM2 + "," + TemperatureM2 + "," + PositionM1 + "," + VelocityM1 + "," + TorqueM1 + "," + VoltageM1 + "," + TemperatureM1 + "," + PositionM3 + "," + VelocityM3 + "," + TorqueM3 + "," + VoltageM3 + "," + TemperatureM3;
       
       TxtFile.println(Data);
     }else if(SystemMode==2){//Encoder
       String Data = Timestamp + "," + DataE1 + "," + DataE2 + "," + DataE3;
       TxtFile.println(Data);
     }     
   }
   
   
   /******************************************/
   /*             TRANSMITE INFO             */
   /******************************************/
     //println("");
     if((SyncPosFlag || SyncVelFlag)){
       //1.- MANDAR PAQUETE CADA 500 ms
       float FC = frameCount%15;//%25//%10
         if(FC== 0){             
           println("SYNC: se envia...");
           if(SyncPosFlag){             
             SetPosition(7,7);    //0,7  setVEL, setPos
           }else if(SyncVelFlag){
             SetVelocity();
             //println("Sync Vel");
           }
           println("SYNC: Enviado...");  
         }          
     }
   
   
   /******************************************/
   /*             GRAFICAR  INFO             */
   /******************************************/
   
   if(GraficarFlag){
     
       
     if(SystemMode==2){//Encoders
     
       //******************************************************************
       //                           ENCODERS       
       //******************************************************************
       
       //SystemModeMotorEncoder = 2;
       setSystemModePlots(false);
       int E1 = (int)checkbox.getArrayValue()[0];       
       int E2 = (int)checkbox.getArrayValue()[1];     
       int E3 = (int)checkbox.getArrayValue()[2];
       
       if(contPoint>=Npoints){
                  
         for(int i=0;i<Npoints-1;i++){
           ValuesX[i] = ValuesX[i+1];
           pointsx1test.add(i, ValuesX[i]);// ValuesX[contPoint]);           
           
           ValuesY[i] = ValuesY[i+1];
           pointsy1test.add(i, ValuesY[i]);// ValuesX[contPoint]);
           
           ValuesZ[i] = ValuesZ[i+1];
           pointsz1test.add(i, ValuesZ[i]);// ValuesX[contPoint]);           
          }            
                
          ValuesX[Npoints-1] = DataE1;          
          ValuesY[Npoints-1] = DataE2;
          ValuesZ[Npoints-1] = DataE3;
              
       }else{
         
         ValuesX[contPoint] = DataE1;         
         ValuesY[contPoint] = DataE2;
         ValuesZ[contPoint] = DataE3;
         
         for(int i=0;i<contPoint;i++){
           pointsx1test.add(i, ValuesX[i]);// ValuesX[contPoint]);
           pointsy1test.add(i, ValuesY[i]);// ValuesX[contPoint]);
           pointsz1test.add(i, ValuesZ[i]);// ValuesX[contPoint]);
           
           //println("" + i  + " Values[i]: " + ValuesX[i]);
         }           
       }
          
       
       if(E1==1){
         plotx_1.setPoints(pointsx1test);  
       }else{
         plotx_1.setPoints(pointsVoid);
       }
       
       if(E2==1){
         plotx_1.getLayer("Encoder 2").setPoints(pointsy1test);
       }else{
         plotx_1.getLayer("Encoder 2").setPoints(pointsVoid);
       }
              
       if(E3==1){
         plotx_1.getLayer("Encoder 3").setPoints(pointsz1test);
       }else{
         plotx_1.getLayer("Encoder 3").setPoints(pointsVoid);
       }
       
        
     }else if(SystemMode ==1){  //Motores
    
       //******************************************************************
       //                            MOTORES       
       //******************************************************************    
              
       //SystemModeMotorEncoder = 1;
       setSystemModePlots(true);
       int M1 = (int)checkboxMotors.getArrayValue()[0];       
       int M2 = (int)checkboxMotors.getArrayValue()[1];     
       int M3 = (int)checkboxMotors.getArrayValue()[2];       
       
       if(contPoint>=Npoints){
                  
         for(int i=0;i<Npoints-1;i++){
           
           //***************Posicion*****************
           ValuesPos1[i] = ValuesPos1[i+1];
           pointsm1pos.add(i, ValuesPos1[i]);// ValuesX[contPoint]);           
           
           ValuesPos2[i] = ValuesPos2[i+1];
           pointsm2pos.add(i, ValuesPos2[i]);// ValuesX[contPoint]);
           
           ValuesPos3[i] = ValuesPos3[i+1];
           pointsm3pos.add(i, ValuesPos3[i]);// ValuesX[contPoint]);
           
           
           //****************Velocidad****************
           ValuesVel1[i] = ValuesVel1[i+1];
           pointsm1vel.add(i, ValuesVel1[i]);// ValuesX[contPoint]);
           
           ValuesVel2[i] = ValuesVel2[i+1];
           pointsm2vel.add(i, ValuesVel2[i]);// ValuesX[contPoint]);
           
           ValuesVel3[i] = ValuesVel3[i+1];
           pointsm3vel.add(i, ValuesVel3[i]);// ValuesX[contPoint]);
           
           
           //****************Torque****************
           ValuesTor1[i] = ValuesTor1[i+1];
           pointsm1tor.add(i, ValuesTor1[i]);// ValuesX[contPoint]);
           
           ValuesTor2[i] = ValuesTor2[i+1];
           pointsm2tor.add(i, ValuesTor2[i]);// ValuesX[contPoint]);
           
           ValuesTor3[i] = ValuesTor3[i+1];
           pointsm3tor.add(i, ValuesTor3[i]);// ValuesX[contPoint]);
           
           
           //****************Voltaje****************
           ValuesVolt1[i] = ValuesVolt1[i+1];
           pointsm1volt.add(i, ValuesVolt1[i]);// ValuesX[contPoint]);
           
           ValuesVolt2[i] = ValuesVolt2[i+1];
           pointsm2volt.add(i, ValuesVolt2[i]);// ValuesX[contPoint]);
           
           ValuesVolt3[i] = ValuesVolt3[i+1];
           pointsm3volt.add(i, ValuesVolt3[i]);// ValuesX[contPoint]);
           
           
            //****************Temperature****************
           ValuesTemp1[i] = ValuesTemp1[i+1];
           pointsm1temp.add(i, ValuesTemp1[i]);// ValuesX[contPoint]);
           
           ValuesTemp2[i] = ValuesTemp2[i+1];
           pointsm2temp.add(i, ValuesTemp2[i]);// ValuesX[contPoint]);
           
           ValuesTemp3[i] = ValuesTemp3[i+1];
           pointsm3temp.add(i, ValuesTemp3[i]);// ValuesX[contPoint]);
           
          }            
                
          ValuesPos1[Npoints-1] = PositionM1;          
          ValuesPos2[Npoints-1] = PositionM2;
          ValuesPos3[Npoints-1] = PositionM3;
          
          ValuesVel1[Npoints-1] = VelocityM1;          
          ValuesVel2[Npoints-1] = VelocityM2;
          ValuesVel3[Npoints-1] = VelocityM3;
          
          ValuesTor1[Npoints-1] = TorqueM1;          
          ValuesTor2[Npoints-1] = TorqueM2;
          ValuesTor3[Npoints-1] = TorqueM3;
          
          ValuesVolt1[Npoints-1] = VoltageM1;
          ValuesVolt2[Npoints-1] = VoltageM2;
          ValuesVolt3[Npoints-1] = VoltageM3;
          
          ValuesTemp1[Npoints-1] = TemperatureM1;
          ValuesTemp2[Npoints-1] = TemperatureM2;
          ValuesTemp3[Npoints-1] = TemperatureM3;
              
       }else{
         
         ValuesPos1[contPoint] = PositionM1;         
         ValuesPos2[contPoint] = PositionM2;
         ValuesPos3[contPoint] = PositionM3;
         
         ValuesVel1[contPoint] = VelocityM1;          
         ValuesVel2[contPoint] = VelocityM2;
         ValuesVel3[contPoint] = VelocityM3;
         
         ValuesTor1[contPoint] = TorqueM1;          
         ValuesTor2[contPoint] = TorqueM2;
         ValuesTor3[contPoint] = TorqueM3;
         
         ValuesVolt1[contPoint] = VoltageM1;          
         ValuesVolt2[contPoint] = VoltageM2;
         ValuesVolt3[contPoint] = VoltageM3;
         
         ValuesTemp1[contPoint] = TemperatureM1;
         ValuesTemp2[contPoint] = TemperatureM2;
         ValuesTemp3[contPoint] = TemperatureM3;
         
         
         for(int i=0;i<contPoint;i++){
           //******************Posicion*********************        
           pointsm1pos.add(i, ValuesPos1[i]);// ValuesX[contPoint]);
           pointsm2pos.add(i, ValuesPos2[i]);// ValuesX[contPoint]);
           pointsm3pos.add(i, ValuesPos3[i]);// ValuesX[contPoint]);
           
           
           //******************Velocidad***********************
           pointsm1vel.add(i, ValuesVel1[i]);// ValuesX[contPoint]);
           pointsm2vel.add(i, ValuesVel2[i]);// ValuesX[contPoint]);
           pointsm3vel.add(i, ValuesVel3[i]);// ValuesX[contPoint]);
           //println("" + i  + " Values[i]: " + ValuesX[i]);
           
           //******************Velocidad***********************
           pointsm1tor.add(i, ValuesTor1[i]);// ValuesX[contPoint]);
           pointsm2tor.add(i, ValuesTor2[i]);// ValuesX[contPoint]);
           pointsm3tor.add(i, ValuesTor3[i]);// ValuesX[contPoint]);
           //println("" + i  + " Values[i]: " + ValuesX[i]);
 
           //******************Voltage***********************
           pointsm1volt.add(i, ValuesVolt1[i]);// ValuesX[contPoint]);
           pointsm2volt.add(i, ValuesVolt2[i]);// ValuesX[contPoint]);
           pointsm3volt.add(i, ValuesVolt3[i]);// ValuesX[contPoint]);
           //println("" + i  + " Values[i]: " + ValuesX[i]);
           
           //******************Temperature***********************
           pointsm1temp.add(i, ValuesTemp1[i]);// ValuesX[contPoint]);
           pointsm2temp.add(i, ValuesTemp2[i]);// ValuesX[contPoint]);
           pointsm3temp.add(i, ValuesTemp3[i]);// ValuesX[contPoint]);
           
         }
           
       }
          
       
       if(M1==1){
         //plot_mpos.setPoints(pointsm1pos);
         plot_mvel.setPoints(pointsm2vel);  
         plot_mtor.setPoints(pointsm2tor); 
         plot_mvolt.setPoints(pointsm2volt);
         plot_mtemp.setPoints(pointsm2temp);
       }else{
         //plot_mpos.setPoints(pointsVoid);
         plot_mvel.setPoints(pointsVoid);
         plot_mtor.setPoints(pointsVoid); 
         plot_mvolt.setPoints(pointsVoid);
         plot_mtemp.setPoints(pointsVoid);
       }
       
       if(M2==1){
         //plot_mpos.getLayer("Motor 2").setPoints(pointsm2pos);
         plot_mvel.getLayer("Motor 2").setPoints(pointsm1vel);
         plot_mtor.getLayer("Motor 2").setPoints(pointsm1tor);
         plot_mvolt.getLayer("Motor 2").setPoints(pointsm1volt);
         plot_mtemp.getLayer("Motor 2").setPoints(pointsm1temp);
       }else{
         //plot_mpos.getLayer("Motor 2").setPoints(pointsVoid);
         plot_mvel.getLayer("Motor 2").setPoints(pointsVoid);
         plot_mtor.getLayer("Motor 2").setPoints(pointsVoid);
         plot_mvolt.getLayer("Motor 2").setPoints(pointsVoid);
         plot_mtemp.getLayer("Motor 2").setPoints(pointsVoid);
       }
              
       if(M3==1){
         //plot_mpos.getLayer("Motor 3").setPoints(pointsm3pos);
         plot_mvel.getLayer("Motor 3").setPoints(pointsm3vel);
         plot_mtor.getLayer("Motor 3").setPoints(pointsm3tor);
         plot_mvolt.getLayer("Motor 3").setPoints(pointsm3volt);
         plot_mtemp.getLayer("Motor 3").setPoints(pointsm3temp);
       }else{
         //plot_mpos.getLayer("Motor 3").setPoints(pointsVoid);
         plot_mvel.getLayer("Motor 3").setPoints(pointsVoid);
         plot_mtor.getLayer("Motor 3").setPoints(pointsVoid);
         plot_mvolt.getLayer("Motor 3").setPoints(pointsVoid);
         plot_mtemp.getLayer("Motor 3").setPoints(pointsVoid);
       }
       
     }
     
     
     
     contPoint++;   
   }
  
  plotx_1     = DrawMotorPlot(plotx_1,DataE1,DataE2,DataE3);//Encoders  
  //plot_mpos   = DrawMotorPlot(plot_mpos,PositionM1,PositionM2,PositionM3);
  plot_mvel   = DrawMotorPlot(plot_mvel,VelocityM1,VelocityM2,VelocityM3);
  plot_mtor   = DrawMotorPlot(plot_mtor,TorqueM1,TorqueM2,TorqueM3);
  plot_mtemp  = DrawMotorPlot(plot_mtemp,TemperatureM1,TemperatureM2,TemperatureM3);
  plot_mvolt  = DrawMotorPlot(plot_mvolt,VoltageM1,VoltageM1,VoltageM3);
  
  t=t+1;
 
}









/********************************************************************/
/************************* FUNCIONES ********************************/
/********************************************************************/

GPlot DrawMotorPlot(GPlot plot, float M1,float M2,float M3){
  plot.beginDraw();
  plot.drawBackground();
  plot.drawXAxis();
  plot.drawYAxis();
  plot.drawTitle();
  plot.drawGridLines(GPlot.BOTH);
  plot.drawLines();
  plot.drawPoints();
  //plot.drawLegend(["Motor 1", "Motor 2","Motor 3"],[ 0.07, 0.30 ], [ 0.92, 0.92 ]);
  
  
  String v1 = nf(M1, 0, 4);
  String v2 = nf(M2, 0, 4);
  String v3 = nf(M3, 0, 4);
  
  String []legends = {"R=" + v1,"P="+ v2,"Y="+ v3}; //M1,M2,M3 
  float []xrel = {0.10, 0.45, 0.80}; 
  float []yrel = {1.0, 1.0, 1.0}; 
  plot.setAllFontProperties("Arial",0,13);
  plot.drawLegend(legends, xrel,yrel);
  plot.drawLabels();  
  //plotx_1.activatePointLabels();
  plot.endDraw();
  
  return plot;
  
}


GPlot InitializeMotorPlots(GPlot plot,int posx, int posy,int size_x, int size_y,int Ylimit,String YAxisLabel){
  
  plot.setDim(size_x,size_y);  //(x,y)
  plot.setPos(posx, posy);  
  plot.getYAxis().getAxisLabel().setText(YAxisLabel);
  plot.setXLim(0, Npoints);
  plot.setYLim(0, Ylimit);//360);
  plot.setLineColor(#4640FF); 
  plot.setLineWidth(2);
  plot.setPointColor(#0A03FF);
  plot.setPointSize(8);
  plot.setBgColor(255);
  plot.setBoxBgColor(255);
  plot.setBoxLineColor(255);
  plot.setAllFontProperties("Arial",0,11);//Roboto
  plot.setGridLineColor(210);
  plot.setGridLineWidth(0.8);
  plot.setVerticalAxesNTicks(4);
  plot.setHorizontalAxesNTicks(10);
  plot.setPoints(pointsx1);
  plot.addLayer("Motor 2", pointsy1);
  plot.getLayer("Motor 2").setLineColor(color(255, 100,255, 255));
  plot.getLayer("Motor 2").setPointColor(color(255,100, 255, 255));
  plot.addLayer("Motor 3", pointsz1);
  plot.getLayer("Motor 3").setLineColor(color(0,255, 0, 255));
  plot.getLayer("Motor 3").setPointColor(color(0,255, 0, 255));
  
  /*plot.activateZooming();
  plot.activatePanning();
  plot.activateCentering(RIGHT, GPlot.CTRLMOD);*/  
  return plot;
}

void drawLines(){
  int sizeX=SizePanelX;
  int sizeY=SizePanelY;
  
  float nx= round(sizeX/scPx);
  float contx=0;
  for(int j=0; j<nx; j++){
    contx=contx+scPx;
    line(contx, 0, contx, sizeY);
  }
  float ny= round(sizeY/scPx);
  float conty=0;
  for(int j=0; j<ny; j++){
    conty=conty+scPx;
    line(0, conty, sizeX, conty);
  }
}


void Ports(int n) {
  /* Selecciono de la lista el */
  PORT = SerialList.getItem(n).get("name").toString();
  PORT_n = n;
  println("Puerto Seleccionado: " + PORT) ;
  
}


void Pause(boolean theFlag) {
  if(theFlag==true) {
    //println("Graficar!!!.");
    GraficarFlag = true;
    
    contValArr=0;    
    for(int i=0;i<NValArr;i++){
      ArrXValMean[i] = -999.0;
      ArrYValMean[i] = -999.0;
      ArrZValMean[i] = -999.0;
    }
    
    
  } else {
    println("NO Graficar!!!.");
    GraficarFlag= false;
  }
  
}

void SaveFunc(boolean theFlag) //Guardar
{
  if(theFlag==true) {
    String PathFile = "./Data/" + TxtFileName.getText().toString() + ".txt";
    TxtFile = createWriter(PathFile);
    String headers;
    if (SystemMode == 1) { // Motores
      //headers = "Date,Time,PositionM2,VelocityM2,TorqueM2,VoltageM2,TemperatureM2,PositionM1,VelocityM1,TorqueM1,VoltageM1,TemperatureM1,PositionM3,VelocityM3,TorqueM3,VoltageM3,TemperatureM3";
      headers = "Date,Time,Position Pitch,Velocity Pitch,Torque Pitch,Voltage Pitch,Temperature Pitch,Position Roll,Velocity Roll,Torque Roll,Voltage Roll,Temperature Roll,Position Yaw,Velocity Yaw,Torque Yaw,Voltage Yaw,Temperature Yaw";
    } else { // Encoder
      headers = "Date,Time,Roll,Pitch,Yaw";
    }
    TxtFile.println(headers);
    TxtFile.flush();
    GuardarFlag = true;
  } else {
    TxtFile.flush(); // Writes the remaining data to the file 
    TxtFile.close();
    GuardarFlag = false;
  }
}


public void Refresh(int theValue) {
  
  String [] ListS =  null;
  if (!FlagPortAvailable){//(SerialList.getItems().size() == 0 ){
    
    if(myPort==null){
      SerialList.setCaptionLabel("Ports");
    }
    //Desconectar(1);
    ListS =  Serial.list();    
    SerialList.clear();
    SerialList.addItems(Serial.list());
    SerialList.update();
    
    /*    
    SerialList.clear();
    SerialList.update();    
    PORT = "";
    PORT_n = -999;
    */
   
  }
  
  println("Refresh button   SerialList.Size: " + SerialList.getItems().size()  + "   Serial.list(): "+ ListS.length +  "  myPort:" + myPort + " NAt:" + NAt + "  Flag Port Available: " + FlagPortAvailable + "  Flag ACK: " + FlagACK);
}

public void Connect(int theValue){
  //println("Conectar " + myPort);
  
  int BAUDRATE = 57600;//9600;// 19200; //57600; //9600;
  if(myPort == null){    
    println("PORT;"  + PORT);
    if(PORT != ""){       
      
      FlagPortAvailable = true;  //Esto va con el metodo de ReadSerial (manualmente sin thread)
      
      println("myPort:" + myPort + " PORT:" + PORT);
      //println("BUG A1");
      myPort = new Serial(this, PORT, BAUDRATE); //9600);  //myPort = new Serial(this, Serial.list()[PORT_n], 9600);
      //println("myPort2:" + myPort);
      delay(1000);
      //Write2Port("ACK");
      //ReadDataPort();
      
      
      //ModeMotorJointWheel=1;
      if(myPort!=null){
        StartConnectionOneShot=true;
      }
    }else{
      showMessageDialog(null, "Port not selected", 
    "Info", INFORMATION_MESSAGE);
    }
    
    
  }else{
    //println("BUG B");
    myPort.clear();
    myPort.stop();     
    myPort = new Serial(this, PORT, BAUDRATE); //myPort = new Serial(this, Serial.list()[PORT_n], 9600); 
    //Write2Port("ACK");
  }
  println("Conectado a Puerto: " + PORT);  
  
}

public void Disconnect(int theValue){
  if(myPort != null){ 
    //Write2Port("0");
    myPort.clear();
    myPort.stop();
    myPort=null;    
    //PORT = "";
    //PORT_n = -999;
  }
  
  FlagACK=false;
  FlagPortAvailable = false;
  HideFlag=true;
  plotButtonOneShot=false;
  TorqueEnable1.setState(false);
  TorqueEnable2.setState(false);
  TorqueEnable3.setState(false);
  
  SyncPosbutton.setState(false);
  SyncVelbutton.setState(false);
  
  SyncPos(0);
  SyncVel(0); 
    
  ModeMotorJointWheel=0;
    
  println("Cerrando Puerto: " + PORT);
}

void keyPressed() {
  if (keyCode == 32) {
      println("¡STOP!");
      EmergencyStop();
  }
}


public void EmergencyStop(){
  EmergencyStopFlag = true;
  
  if(SystemMode ==1){  //MOTORES

    if(ModeMotorJointWheel==0){//No mode
      
    }else if(ModeMotorJointWheel==1)//Joint
    {
      println("EMERGENCY STOP MODE JOINT" );
      setWritePacket1(0, 10, false,false,false,false,false,false,false,false,false);//Torque
      delay(200);
    }else if(ModeMotorJointWheel==2)//Wheel    
    { 
      println("EMERGENCY STOP MODE WHEEL" );
      println("PosM1= " + str(PositionM1) + " PosM2=" + str(PositionM2) + " PosM3= " + str(PositionM3));
      //WheelModeSetVelocity('7',0,0,0);
      setConfigurationPacket(1,1,1,1,1,1);//<<<<<<06/07/2022   
      setWritePacket1(0, 10, false,false,false,false,false,false,false,false,false); //MX64T
      delay(200);      
    }
  
  }else if(SystemMode ==2){ //ENCODERS 
  
    setHomeT.setState(false);
    Disconnect(0);
  }
    
  
  FlagPortDataAvailable =false;  
  TorqueEnable1.setState(false);
  TorqueEnable2.setState(false);
  TorqueEnable3.setState(false);  
  SyncPosbutton.setState(false);
  SyncVelbutton.setState(false);  
  //GuardarBtn.setState(false);  
  
  SyncPos(0);
  SyncVel(0); 
  
  delay(500);      
}

public void SyncPos(int Value){
  
  if(Value==1){
    SyncPosFlag=true;
    //Deshabilitar botones y textfields y el toggle del otro sync
    
     setModeJW.lock();
     setModeJW.setColorBackground(color(100,100,100));      
     setModeJW.setColorActive(#C0C0C0);
     
    /*************************/
    /*       TORQUE          */
    /*************************/
    MaxTorqueTextFieldM1.lock();
    MaxTorqueTextFieldM2.lock();
    MaxTorqueTextFieldM3.lock();    
    SetMaxTorque.lock();
    
    SliderTM1.lock();
    SliderTM2.lock();
    SliderTM3.lock();
    
    TorqueTextFieldM1.lock();
    TorqueTextFieldM2.lock();
    TorqueTextFieldM3.lock();
    
    TorqueEnable1.lock();
    TorqueEnable2.lock();
    TorqueEnable3.lock();
    
    SetTorque.lock();
    
    /*************************/
    /*       POSICIÓN        */
    /*************************/    
   
    PositionTextFieldM1.lock();
    PositionTextFieldM2.lock();
    PositionTextFieldM3.lock();
        
    MovingSpeedTextFieldM1.lock();
    MovingSpeedTextFieldM2.lock();
    MovingSpeedTextFieldM3.lock();
    
    SetPosition.lock();
    
    /*************************/
    /*       VELOCIDAD       */
    /*************************/
    SliderVM1.lock();
    SliderVM2.lock();
    SliderVM3.lock();
    
    VelocityTextFieldM1.lock();
    VelocityTextFieldM2.lock();
    VelocityTextFieldM3.lock();
    
    SetVelocity.lock();
    SyncVelbutton.lock();
    SetVelocityZero.lock();
    
  }else{
    SyncPosFlag=false;
    //Habilitarlos botones y textfields y el toggle del otro sync
    
    setModeJW.unlock();
    setModeJW.setColorBackground(color(0,45,90));
    setModeJW.setColorActive(#3333FF);
    /*************************/
    /*       TORQUE          */
    /*************************/
    
    MaxTorqueTextFieldM1.unlock();
    MaxTorqueTextFieldM2.unlock();
    MaxTorqueTextFieldM3.unlock();
    
    SetMaxTorque.unlock();
    
    TorqueTextFieldM1.unlock();
    TorqueTextFieldM2.unlock();
    TorqueTextFieldM3.unlock();
    
    SliderTM1.unlock();
    SliderTM2.unlock();
    SliderTM3.unlock();
    
    TorqueEnable1.unlock();
    TorqueEnable2.unlock();
    TorqueEnable3.unlock();
    
    SetTorque.unlock();
    
    /*************************/
    /*       POSICIÓN        */
    /*************************/    
   
    PositionTextFieldM1.unlock();
    PositionTextFieldM2.unlock();
    PositionTextFieldM3.unlock();
        
    MovingSpeedTextFieldM1.unlock();
    MovingSpeedTextFieldM2.unlock();
    MovingSpeedTextFieldM3.unlock();
    
    SetPosition.unlock();
    
    /*************************/
    /*       VELOCIDAD       */
    /*************************/
    SliderVM1.unlock();
    SliderVM2.unlock();
    SliderVM3.unlock();    
    
    VelocityTextFieldM1.unlock();
    VelocityTextFieldM2.unlock();
    VelocityTextFieldM3.unlock();
    
    SetVelocity.unlock();
    SyncVelbutton.unlock();    
    SetVelocityZero.unlock();
  }
}

public void SyncVel(int Value){
  
  if(Value==1){
    SyncVelFlag=true;
    //Deshabilitar botones y textfields y el toggle del otro sync
    setModeJW.lock();
    setModeJW.setColorBackground(color(100,100,100));      
    setModeJW.setColorActive(#C0C0C0);
    /*************************/
    /*       TORQUE          */
    /*************************/
    
    MaxTorqueTextFieldM1.lock();
    MaxTorqueTextFieldM2.lock();
    MaxTorqueTextFieldM3.lock();
    SetMaxTorque.lock();
   
    
    SliderTM1.lock();
    SliderTM2.lock();
    SliderTM3.lock();
    
    TorqueTextFieldM1.lock();
    TorqueTextFieldM2.lock();
    TorqueTextFieldM3.lock();
    
    TorqueEnable1.lock();
    TorqueEnable2.lock();
    TorqueEnable3.lock();
    
    SetTorque.lock();
    
    /*************************/
    /*       POSICIÓN        */
    /*************************/
    
    SliderM1.lock();
    SliderM2.lock();
    SliderM3.lock();
        
    PositionTextFieldM1.lock();
    PositionTextFieldM2.lock();
    PositionTextFieldM3.lock();
        
    MovingSpeedTextFieldM1.lock();
    MovingSpeedTextFieldM2.lock();
    MovingSpeedTextFieldM3.lock();
    
    SetPosition.lock();
    SyncPosbutton.lock();
    
    /*************************/
    /*       VELOCIDAD       */
    /*************************/
    
    VelocityTextFieldM1.lock();
    VelocityTextFieldM2.lock();
    VelocityTextFieldM3.lock();
    
    SetVelocity.lock();
    SetVelocityZero.lock();
    
  }else{
    SyncVelFlag=false;
    //Habilitarlos botones y textfields y el toggle del otro sync
    setModeJW.unlock();
    setModeJW.setColorBackground(color(0,45,90));
    setModeJW.setColorActive(#3333FF);
    /*************************/
    /*       TORQUE          */
    /*************************/
    MaxTorqueTextFieldM1.unlock();
    MaxTorqueTextFieldM2.unlock();
    MaxTorqueTextFieldM3.unlock();
    SetMaxTorque.unlock();
    
    SliderTM1.unlock();
    SliderTM2.unlock();
    SliderTM3.unlock();
    
    TorqueTextFieldM1.unlock();
    TorqueTextFieldM2.unlock();
    TorqueTextFieldM3.unlock();
    
    TorqueEnable1.unlock();
    TorqueEnable2.unlock();
    TorqueEnable3.unlock();
    
    SetTorque.unlock();
    
    /*************************/
    /*       POSICIÓN        */
    /*************************/
    
    SliderM1.unlock();
    SliderM2.unlock();
    SliderM3.unlock();
        
    PositionTextFieldM1.unlock();
    PositionTextFieldM2.unlock();
    PositionTextFieldM3.unlock();
        
    MovingSpeedTextFieldM1.unlock();
    MovingSpeedTextFieldM2.unlock();
    MovingSpeedTextFieldM3.unlock();
    
    SetPosition.unlock();
    SyncPosbutton.unlock();
    
    /*************************/
    /*       VELOCIDAD       */
    /*************************/
    
    VelocityTextFieldM1.unlock();
    VelocityTextFieldM2.unlock();
    VelocityTextFieldM3.unlock();
    
    SetVelocity.unlock();
    SetVelocityZero.unlock();
  }
}


public void FiltroSwitch(int Value){
  FiltroSwitchFlag=false;
  if(Value==1){
    FiltroSwitchFlag=true;
  }
}


public void setHomePosition(int Value){
  
  FlagHomeCompensation = true;
  if(Value==1){
      if(SystemMode==1){ //MOTOR
        PitchCompHome = PositionM1;
        RollCompHome = PositionM2;
        YawCompHome = PositionM3;    
      }else if(SystemMode==2){ //ENCODER
        PitchCompHome = DataE1Filter;
        RollCompHome  = DataE2Filter;
        YawCompHome   = DataE3Filter;    
      }
  }else{
    PitchCompHome = 0;
    RollCompHome  = 0;
    YawCompHome   = 0;
  }
  
  //println("SystemMode: " + SystemMode + " PitchHome: " + PitchCompHome + " RollCompHome: " + RollCompHome + " YawCompHome:" + YawCompHome);  
} 

public void setHomeMotors(int Value){
  
  if(Value==1){
      if(SystemMode==1){ //MOTOR
      
        child.yaw_comp     = PositionM1;
        child.pitch_comp   = PositionM2;
        child.roll_comp    = PositionM3;
        
        pfdchild.pitchComp = PositionM1;
        pfdchild.rollComp = PositionM2;
        pfdchild.yawComp = PositionM3;  
        
      }else if(SystemMode==2){ //ENCODER
        child.yaw_comp     = DataE1Filter;
        child.pitch_comp   = DataE2Filter;
        child.roll_comp    = DataE3Filter;
        
        pfdchild.pitchComp = DataE1Filter;
        pfdchild.rollComp = DataE2Filter;
        pfdchild.yawComp = DataE3Filter;        
      }
  }else{
    child.yaw_comp     = 0;
    child.pitch_comp   = 0;
    child.roll_comp    = 0;
        
    pfdchild.pitchComp = 0;
    pfdchild.rollComp = 0;
    pfdchild.yawComp = 0;
  }
  
}


public void Write2Port(String text){  
  myPort.write(text); 
}

public void Write2PortBytes(byte[] Packet){
  delay(10);
  myPort.clear();  
  
  try{
    myPort.write(Packet);
  }catch(RuntimeException e){//RuntimeException   //Exception
    //print(e);
    println("---->>>> RUN TIME EXCEPTION ");
  }
 
}

public void setSystemModePlots(boolean theFlag) {
  if(theFlag==true) {  //MOTOR
        
    TorqueLabel.show();
    MovingSpeedLabel.show();
    PositionLabel.show();
    VelocityLabel.show();
    TorqueEnableLabel.show();
    
    radiobuttonTypeMotors.show();
    checkboxMotors.show();
    checkbox.hide();
    plotx_1.setPos(-800, -800);
    
    plotbutton.setPosition(810,20);     
    Filtro.setPosition(910,20);
    setHomeMotors.show();
    setModeJW.show();
    
    //plot_mpos.setPos(0,0);
    plot_mvel.setPos(0,245);
    plot_mtor.setPos(390,245);
    plot_mvolt.setPos(390,420);
    plot_mtemp.setPos(0,420);   
  
    SliderM1.show();
    SliderM2.show();
    SliderM3.show();
    
    SliderVM1.show();
    SliderVM2.show();
    SliderVM3.show();
    
    SliderTM1.show();
    SliderTM2.show();
    SliderTM3.show();
    
    SetPosition.show();
    SetVelocity.show();
    SetVelocityZero.show();
    SetTorque.show();
    SetMaxTorque.show();
    
    SyncPosbutton.show();
    SyncVelbutton.show();
    TorqueEnable1.show();
    TorqueEnable2.show();
    TorqueEnable3.show();
    
    MaxTorqueTextFieldM1.show();
    MaxTorqueTextFieldM2.show();
    MaxTorqueTextFieldM3.show();
    
    TorqueTextFieldM1.show();
    TorqueTextFieldM2.show();
    TorqueTextFieldM3.show();
    
    PositionTextFieldM1.show();
    PositionTextFieldM2.show();
    PositionTextFieldM3.show();
    
    MovingSpeedTextFieldM1.show();
    MovingSpeedTextFieldM2.show();
    MovingSpeedTextFieldM3.show();
    
    VelocityTextFieldM1.show();
    VelocityTextFieldM2.show();
    VelocityTextFieldM3.show();
    
  }else{  //ENCODER
    checkbox.show();
    checkboxMotors.hide();
    radiobuttonTypeMotors.hide();
    plotx_1.setPos(10,310);
    
    plotbutton.setPosition(1010,60);     
    Filtro.setPosition(1110,30);
    Filtro.setValue(0);
    Filtro.hide();
    setHomeT.show();
    setModeJW.hide();
  
    //plot_mpos.setPos(-800,-800);
    plot_mvel.setPos(-800,-800);
    plot_mtor.setPos(-800,-800);
    plot_mvolt.setPos(-800,-800);
    plot_mtemp.setPos(-800,-800);
    
    SliderM1.hide();
    SliderM2.hide();
    SliderM3.hide();
    
    SliderVM1.hide();
    SliderVM2.hide();
    SliderVM3.hide();
    
    SliderTM1.hide();
    SliderTM2.hide();
    SliderTM3.hide();
    
    SetPosition.hide();
    SetVelocity.hide();
    SetVelocityZero.hide();
    SetTorque.hide();
    SetMaxTorque.hide();
    
    SyncPosbutton.hide();
    SyncVelbutton.hide();
    TorqueEnable1.hide();
    TorqueEnable2.hide();
    TorqueEnable3.hide();
    
    MaxTorqueTextFieldM1.hide();
    MaxTorqueTextFieldM2.hide();
    MaxTorqueTextFieldM3.hide();
    
    TorqueTextFieldM1.hide();
    TorqueTextFieldM2.hide();
    TorqueTextFieldM3.hide();
    
    PositionTextFieldM1.hide();
    PositionTextFieldM2.hide();
    PositionTextFieldM3.hide();
    
    MovingSpeedTextFieldM1.hide();
    MovingSpeedTextFieldM2.hide();
    MovingSpeedTextFieldM3.hide();
    
    VelocityTextFieldM1.hide();
    VelocityTextFieldM2.hide();
    VelocityTextFieldM3.hide();
  }
}

public void HideAll(){

    //HIDE ALL
    
    checkboxMotors.show();
    checkbox.hide();
    
    plotx_1.setPos(-800, -800);
    checkboxMotors.hide();
    
    setHomeT.hide();
    setHomeMotors.hide();
    
    //plot_mpos.setPos(-800,-800);
    plot_mvel.setPos(-800,-800);
    plot_mtor.setPos(-800,-800);
    plot_mvolt.setPos(-800,-800);
    plot_mtemp.setPos(-800,-800);
    
    SliderM1.hide();
    SliderM2.hide();
    SliderM3.hide();
    
    SliderVM1.hide();
    SliderVM2.hide();
    SliderVM3.hide();
    
    SliderTM1.hide();
    SliderTM2.hide();
    SliderTM3.hide();
    
    SetPosition.hide();
    SetVelocity.hide();
    SetVelocityZero.hide();
    SetTorque.hide();
    SetMaxTorque.hide();
    
    SyncPosbutton.hide();
    SyncVelbutton.hide();
    TorqueEnable1.hide();
    TorqueEnable2.hide();
    TorqueEnable3.hide();
    
    MaxTorqueTextFieldM1.hide();
    MaxTorqueTextFieldM2.hide();
    MaxTorqueTextFieldM3.hide();
    
    TorqueTextFieldM1.hide();
    TorqueTextFieldM2.hide();
    TorqueTextFieldM3.hide();
    
    PositionTextFieldM1.hide();
    PositionTextFieldM2.hide();
    PositionTextFieldM3.hide();
    
    MovingSpeedTextFieldM1.hide();
    MovingSpeedTextFieldM2.hide();
    MovingSpeedTextFieldM3.hide();
    
    VelocityTextFieldM1.hide();
    VelocityTextFieldM2.hide();
    VelocityTextFieldM3.hide();
    
    TorqueLabel.hide();
    MovingSpeedLabel.hide();
    PositionLabel.hide();
    VelocityLabel.hide();
    TorqueEnableLabel.hide();
    
    setModeJW.hide();
    
}


void UnlockWheelMode(){

  
  /*********** UNLOCK ******************/
  SliderVM1.unlock();
  SliderVM2.unlock();
  SliderVM3.unlock();
  
  SetVelocity.unlock(); 
  SetVelocityZero.unlock();
  SyncVelbutton.unlock();
  VelocityTextFieldM1.unlock();
  VelocityTextFieldM2.unlock();
  VelocityTextFieldM3.unlock();
  
  SliderVM1.setColorBackground(color(0,45,90));
  SliderVM2.setColorBackground(color(0,45,90));
  SliderVM3.setColorBackground(color(0,45,90));
  SetVelocity.setColorBackground(color(0,45,90));
  SetVelocityZero.setColorBackground(color(0,45,90));
  SyncVelbutton.setColorBackground(color(0,45,90));
  VelocityTextFieldM1.setColorBackground(color(0,45,90));
  VelocityTextFieldM2.setColorBackground(color(0,45,90));
  VelocityTextFieldM3.setColorBackground(color(0,45,90));
  
  
  
  
  /************ LOCK ****************/
  SliderM1.lock();
  SliderM2.lock();
  SliderM3.lock();
  
  SetPosition.lock();    
  SyncPosbutton.lock();
  PositionTextFieldM1.lock();
  PositionTextFieldM2.lock();
  PositionTextFieldM3.lock();
  
  MovingSpeedTextFieldM1.lock();
  MovingSpeedTextFieldM2.lock();
  MovingSpeedTextFieldM3.lock();
  
  SliderTM1.lock();
  SliderTM2.lock();
  SliderTM3.lock();
  
  
  SetTorque.lock();
  SetMaxTorque.lock();
  TorqueEnable1.lock();
  TorqueEnable2.lock();
  TorqueEnable3.lock();    
  MaxTorqueTextFieldM1.lock();
  MaxTorqueTextFieldM2.lock();
  MaxTorqueTextFieldM3.lock();    
  TorqueTextFieldM1.lock();
  TorqueTextFieldM2.lock();
  TorqueTextFieldM3.lock();
    
  
   
  SliderM1.setColorBackground(color(100,100,100));
  SliderM2.setColorBackground(color(100,100,100));
  SliderM3.setColorBackground(color(100,100,100));
  
  SetPosition.setColorBackground(color(100,100,100));   
  SyncPosbutton.setColorBackground(color(100,100,100));
  PositionTextFieldM1.setColorBackground(color(100,100,100));
  PositionTextFieldM2.setColorBackground(color(100,100,100));
  PositionTextFieldM3.setColorBackground(color(100,100,100));   
  
  MovingSpeedTextFieldM1.setColorBackground(color(100,100,100));
  MovingSpeedTextFieldM2.setColorBackground(color(100,100,100));
  MovingSpeedTextFieldM3.setColorBackground(color(100,100,100));
   
  SliderTM1.setColorBackground(color(100,100,100));
  SliderTM2.setColorBackground(color(100,100,100));
  SliderTM3.setColorBackground(color(100,100,100));
  
  
  SetTorque.setColorBackground(color(100,100,100));
  SetMaxTorque.setColorBackground(color(100,100,100));
  TorqueEnable1.setColorBackground(color(100,100,100));
  TorqueEnable2.setColorBackground(color(100,100,100));
  TorqueEnable3.setColorBackground(color(100,100,100));   
  MaxTorqueTextFieldM1.setColorBackground(color(100,100,100));
  MaxTorqueTextFieldM2.setColorBackground(color(100,100,100));
  MaxTorqueTextFieldM3.setColorBackground(color(100,100,100));   
  TorqueTextFieldM1.setColorBackground(color(100,100,100));
  TorqueTextFieldM2.setColorBackground(color(100,100,100));
  TorqueTextFieldM3.setColorBackground(color(100,100,100));
   
}


void UnlockJointMode(){
  
  /******UNLOCK*****/
  SliderM1.unlock();
  SliderM2.unlock();
  SliderM3.unlock();
  
  SetPosition.unlock();    
  SyncPosbutton.unlock();
  PositionTextFieldM1.unlock();
  PositionTextFieldM2.unlock();
  PositionTextFieldM3.unlock();
  
  MovingSpeedTextFieldM1.unlock();
  MovingSpeedTextFieldM2.unlock();
  MovingSpeedTextFieldM3.unlock();
  
  SliderTM1.unlock();
  SliderTM2.unlock();
  SliderTM3.unlock();
   
  SetTorque.unlock();
  SetMaxTorque.unlock();
  TorqueEnable1.unlock();
  TorqueEnable2.unlock();
  TorqueEnable3.unlock();
    
  MaxTorqueTextFieldM1.unlock();
  MaxTorqueTextFieldM2.unlock();
  MaxTorqueTextFieldM3.unlock();
    
  TorqueTextFieldM1.unlock();
  TorqueTextFieldM2.unlock();
  TorqueTextFieldM3.unlock();
   
   
   
  SliderM1.setColorBackground(color(0,45,90));
  SliderM2.setColorBackground(color(0,45,90));
  SliderM3.setColorBackground(color(0,45,90));
  
  SetPosition.setColorBackground(color(0,45,90));   
  SyncPosbutton.setColorBackground(color(0,45,90));
  PositionTextFieldM1.setColorBackground(color(0,45,90));
  PositionTextFieldM2.setColorBackground(color(0,45,90));
  PositionTextFieldM3.setColorBackground(color(0,45,90));   
  
  MovingSpeedTextFieldM1.setColorBackground(color(0,45,90));
  MovingSpeedTextFieldM2.setColorBackground(color(0,45,90));
  MovingSpeedTextFieldM3.setColorBackground(color(0,45,90));
  
  MovingSpeedTextFieldM1.setColor(color(255,255,255));
  MovingSpeedTextFieldM2.setColor(color(255,255,255));
  MovingSpeedTextFieldM3.setColor(color(255,255,255));
   
  SliderTM1.setColorBackground(color(0,45,90));
  SliderTM2.setColorBackground(color(0,45,90));
  SliderTM3.setColorBackground(color(0,45,90));
   
  SetTorque.setColorBackground(color(0,45,90));
  SetMaxTorque.setColorBackground(color(0,45,90));
  TorqueEnable1.setColorBackground(color(0,45,90));
  TorqueEnable2.setColorBackground(color(0,45,90));
  TorqueEnable3.setColorBackground(color(0,45,90));   
  MaxTorqueTextFieldM1.setColorBackground(color(0,45,90));
  MaxTorqueTextFieldM2.setColorBackground(color(0,45,90));
  MaxTorqueTextFieldM3.setColorBackground(color(0,45,90));   
  TorqueTextFieldM1.setColorBackground(color(0,45,90));
  TorqueTextFieldM2.setColorBackground(color(0,45,90));
  TorqueTextFieldM3.setColorBackground(color(0,45,90));
  
  
  
  /**** LOCK *******/
  SliderVM1.lock();
  SliderVM2.lock();
  SliderVM3.lock();
  
  SetVelocity.lock();    
  SetVelocityZero.lock();
  SyncVelbutton.lock();
  VelocityTextFieldM1.lock();
  VelocityTextFieldM2.lock();
  VelocityTextFieldM3.lock();
  
  SliderVM1.setColorBackground(color(100,100,100));
  SliderVM2.setColorBackground(color(100,100,100));
  SliderVM3.setColorBackground(color(100,100,100));
  SetVelocity.setColorBackground(color(100,100,100));
  SetVelocityZero.setColorBackground(color(100,100,100));
  SyncVelbutton.setColorBackground(color(100,100,100));
  VelocityTextFieldM1.setColorBackground(color(100,100,100));
  VelocityTextFieldM2.setColorBackground(color(100,100,100));
  VelocityTextFieldM3.setColorBackground(color(100,100,100));
}

void LockAllControlls(){
  
  SliderM1.lock();
  SliderM2.lock();
  SliderM3.lock();
  
  SliderVM1.lock();
  SliderVM2.lock();
  SliderVM3.lock();
  
  SliderTM1.lock();
  SliderTM2.lock();
  SliderTM3.lock();
  
  SetVelocity.lock();    
  SetVelocityZero.lock();
  SyncVelbutton.lock();
  VelocityTextFieldM1.lock();
  VelocityTextFieldM2.lock();
  VelocityTextFieldM3.lock();
  
  SetPosition.lock();    
  SyncPosbutton.lock();
  PositionTextFieldM1.lock();
  PositionTextFieldM2.lock();
  PositionTextFieldM3.lock();
  
  MovingSpeedTextFieldM1.lock();
  MovingSpeedTextFieldM2.lock();
  MovingSpeedTextFieldM3.lock();
  
  SetTorque.lock();
  SetMaxTorque.lock();
  TorqueEnable1.lock();
  TorqueEnable2.lock();
  TorqueEnable3.lock();    
  MaxTorqueTextFieldM1.lock();
  MaxTorqueTextFieldM2.lock();
  MaxTorqueTextFieldM3.lock();    
  TorqueTextFieldM1.lock();
  TorqueTextFieldM2.lock();
  TorqueTextFieldM3.lock();
  
  
   
  SliderM1.setColorBackground(color(100,100,100));
  SliderM2.setColorBackground(color(100,100,100));
  SliderM3.setColorBackground(color(100,100,100));
   
  SliderTM1.setColorBackground(color(100,100,100));
  SliderTM2.setColorBackground(color(100,100,100));
  SliderTM3.setColorBackground(color(100,100,100));  
   
  SliderVM1.setColorBackground(color(100,100,100));
  SliderVM2.setColorBackground(color(100,100,100));
  SliderVM3.setColorBackground(color(100,100,100));
  
  SetVelocity.setColorBackground(color(100,100,100));
  SetVelocityZero.setColorBackground(color(100,100,100));
  SyncVelbutton.setColorBackground(color(100,100,100));
  VelocityTextFieldM1.setColorBackground(color(100,100,100));
  VelocityTextFieldM2.setColorBackground(color(100,100,100));
  VelocityTextFieldM3.setColorBackground(color(100,100,100));
  
  SetPosition.setColorBackground(color(100,100,100));   
  SyncPosbutton.setColorBackground(color(100,100,100));
  PositionTextFieldM1.setColorBackground(color(100,100,100));
  PositionTextFieldM2.setColorBackground(color(100,100,100));
  PositionTextFieldM3.setColorBackground(color(100,100,100));   
  
  MovingSpeedTextFieldM1.setColorBackground(color(100,100,100));
  MovingSpeedTextFieldM2.setColorBackground(color(100,100,100));
  MovingSpeedTextFieldM3.setColorBackground(color(100,100,100));  
  
  MovingSpeedTextFieldM1.setColor(color(255,255,255));
  MovingSpeedTextFieldM2.setColor(color(255,255,255));
  MovingSpeedTextFieldM3.setColor(color(255,255,255));
  
  SetTorque.setColorBackground(color(100,100,100));
  SetMaxTorque.setColorBackground(color(100,100,100));
  TorqueEnable1.setColorBackground(color(100,100,100));
  TorqueEnable2.setColorBackground(color(100,100,100));
  TorqueEnable3.setColorBackground(color(100,100,100));   
  MaxTorqueTextFieldM1.setColorBackground(color(100,100,100));
  MaxTorqueTextFieldM2.setColorBackground(color(100,100,100));
  MaxTorqueTextFieldM3.setColorBackground(color(100,100,100));   
  TorqueTextFieldM1.setColorBackground(color(100,100,100));
  TorqueTextFieldM2.setColorBackground(color(100,100,100));
  TorqueTextFieldM3.setColorBackground(color(100,100,100));
}



void sliderPosM1(){
  //println("Slider 1");
  int V = (int)SliderM1.getValue();
  PositionTextFieldM1.setText(String.valueOf(V));
}

void sliderPosM2(){
  //println("Slider 1");
  int V = (int)SliderM2.getValue();
  PositionTextFieldM2.setText(String.valueOf(V));
}

void sliderPosM3(){
  //println("Slider 1");
  int V = (int)SliderM3.getValue();
  PositionTextFieldM3.setText(String.valueOf(V));
}

void sliderVelM1(){
  int V = (int)SliderVM1.getValue();
  VelocityTextFieldM1.setText(String.valueOf(V));
}

void sliderVelM2(){
  int V = (int)SliderVM2.getValue();
  VelocityTextFieldM2.setText(String.valueOf(V));
}

void sliderVelM3(){
  int V = (int)SliderVM3.getValue();
  VelocityTextFieldM3.setText(String.valueOf(V));
}

void sliderTorM1(){
  int T = (int)SliderTM1.getValue();
  TorqueTextFieldM1.setText(String.valueOf(T));
}

void sliderTorM2(){
  int T = (int)SliderTM2.getValue();
  TorqueTextFieldM2.setText(String.valueOf(T));
}

void sliderTorM3(){
  int T = (int)SliderTM3.getValue();
  TorqueTextFieldM3.setText(String.valueOf(T));
}

public void Torque1Text(int Value){
  println("Torque1Text: "  + Value);
}


public void radiobuttonTypeMotors(int a)
{
 
  MotorTypeConnected = 1; //1=ax12a  2=mx28t
  MotorRepBytes = 1023;
  MotorRes = 0.2932;
  MaxAngle = 300;
  
  int V = (int)radiobuttonTypeMotors.getValue();
  //println("radio  : " +a + " V: " + V);
  
  int cont = 0;
  for(Toggle t:radiobuttonTypeMotors.getItems())
  {
    String name = t.getName();
    Boolean value = t.getBooleanValue();
    //println("t:" + name  + " state: " + value );
    if(name.equals("AX12a") && value==true)
    {
      MotorTypeConnected = 1;
      MotorRepBytes = 1023;
      MotorRes = 0.2932;
      MaxAngle = 300;
      PositionLabel.setText("Position (0° - 300°)");
      SliderM1.setRange(1,300);
      SliderM2.setRange(1,300);
      SliderM3.setRange(1,300);
      break;
    }else if(name.equals("MX28T") && value==true)
    {
      MotorTypeConnected = 2;
      MotorRepBytes = 4095;
      MotorRes = 0.088;
      MaxAngle = 360;
      PositionLabel.setText("Position (0° - 360°)");
      SliderM1.setRange(1,360);
      SliderM2.setRange(1,360);
      SliderM3.setRange(1,360);
      break;
    }
    cont = cont+1;
  }
  
  println("Motor RepBytes = " + MotorRepBytes );
  println("Motor Resolution = " + MotorRes );
  println("Motor Max Angle = " + MaxAngle);
}

void ReadSerial32Bytes(Serial p) { 
  //println(p.available());
  
  boolean flagNull=false;
  if(p == null){
    int nop=1;
    flagNull=true;
  }
  
  if(!flagNull){
    
    int cont_32bytes = 0;
    //while(cont_32bytes<32){
      cont_32bytes = 0;
      while (p.available() > 0) {
        FlagPortAvailable = true;
        char inByte = myPort.readChar();
     
        if(inByte == 'z'){
          //print(contUB++ + ".- ");
          BufferUSBAux="";
          cont_32bytes = 0;
          //BufferUSB = BufferUSB + inByte;
        }
      
        BufferUSBAux = BufferUSBAux + inByte;
        cont_32bytes = cont_32bytes + 1;
        
        if(inByte == '{')
        {// \n'
          //BufferUSB = BufferUSB + inByte;
          //myTextarea3.append(BufferUSB);
          //myTextarea3.scroll(1.0);
          //println("cont_32bytes= "  + str(cont_32bytes));
          if(cont_32bytes>31){
            //println("Se libera === L: " + BufferUSB.length() + " Data--->>" + BufferUSB );
            BufferUSB=BufferUSBAux;
            FlagPortDataAvailable=true;
            cont_32bytes = 0;
            //BufferUSBAux = "";
          }else{
            //cont_32bytes = 0;
            //BufferUSBAux="";
          }
          
        }
        //print(inByte);
      }
    //}
    
  }
  
}

void ReadSerial(Serial p) { 
  //println(p.available());
  boolean flagNull=false;
  if(p == null){
    int nop=1;
    flagNull=true;
  }
  
  if(!flagNull){
    while (p.available() > 0) {
      FlagPortAvailable = true;
      char inByte = myPort.readChar();
   
      if(inByte == 'z'){
        //print(contUB++ + ".- ");
        BufferUSBAux="";
        //BufferUSB = BufferUSB + inByte;
      }
    
      BufferUSBAux = BufferUSBAux + inByte;
      
      if(inByte == '{'){// \n'
        //BufferUSB = BufferUSB + inByte;
        //myTextarea3.append(BufferUSB);
        //myTextarea3.scroll(1.0);
        BufferUSB=BufferUSBAux;
        FlagPortDataAvailable=true;
      }
      //print(inByte);
    }
  }
  
}


float normaliseAngle(float angle) {
  while (angle < 0) angle += 360;
  while (angle > 360) angle -= 360;
  return angle;
}
 
