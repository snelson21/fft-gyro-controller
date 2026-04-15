class YawDisplay {
  
  color c;
  int xcenter;
  int ycenter;
  float xspeed;
  boolean dispRadians;
  int radius;
  float angleR;
  float Last_angle;
  
  // The Constructor is defined with arguments.
  YawDisplay(int tempXpos,int tempYpos, int r) {
    xcenter = tempXpos;
    ycenter = tempYpos;
    
    Last_angle = 0;
    dispRadians = true;
    radius = r;
  }

  void display(boolean Flag) {
        
    if(Flag){
      drawAll(false);
    }
          
  }
  
  void update(float angle,int type){
    int len=30;
    int lenarrow = 20;
    float comp1 = angle + 270;
    
    /*float dif = Last_angle - comp1;
    if(dif>180)
    {      
      comp1 = 360+comp1;
    }else if(dif<180)
    {
      comp1 = 360-comp1;
    }else{
      comp1 = comp1;
    }*/
    
    if(type==1)
    {
      //println("angle: " + angle + " type: " + type + " comp1 : " + comp1);//<<21/jun/22
    }
    
    
    pushMatrix(); 
    translate(xcenter,ycenter);    
    rotate(radians(comp1));  //AQUI
    
    strokeWeight(3);
    stroke(255,0,0);    
    circle(0, 0, radius*2);
    noFill();
    
    strokeWeight(4);
    
    if(type==1){  //Pitch
      stroke(0,0,150);
    }else if(type==2){//Roll      
      stroke(255,0,255);
    }else if(type==3){//Yaw
      stroke(0,255,0);
    }else{
      stroke(0,0,150);
    }
    
    
    line(-radius,0,radius,0);//line(-90,0,90,0); 
    line(-len, 0, -len+lenarrow, -10);
    line(-len, 0, -len+lenarrow, 10);
    
    //Last_angle = comp1;
    //rotate(radians(angle));
    popMatrix();
  }



   void drawAll(boolean dr){
     dispRadians = dr;
      for(int i=0;i<360;i++){
        drawPoint(i,radius,20);
      }
    }
    
    void drawPoint(int angleD, int r, int tI){ //tI = tickInterval;
      //strokeWeight(1);
      int xpos;
      int ypos;
    
      strokeWeight(4);
      //stroke(255,0,0,150);
      //fill(150);    
      pushMatrix(); 
      translate(xcenter,ycenter);
      //xcenter=0;
      //ycenter=0;
      
      angleR = (angleD) * (PI/180);    //angleD+90
      xpos = int(float(0)  + sin(angleR)*radius);//xpos = int(float(xcenter)  + sin(angleR)*radius);
      ypos = int(float(0)  + cos(angleR)*radius);//ypos = int(float(ycenter)  + cos(angleR)*radius);
      
      //point(xpos,ypos);                  
      if(angleD % tI == 0){
        if(angleD % 45 == 0){
          displayText(angleD,angleR,int(float(0)+sin(angleR)*(r+30)),int(float(0)+cos(angleR)*(r+30)));//displayText(angleD,angleR,int(float(xcenter)+sin(angleR)*(r+30)),int(float(xcenter)+cos(angleR)*(r+30)));
        }else if(angleD % 10 == 0){
          displayText(angleD,angleR,int(float(0)+sin(angleR)*(r+30)),int(float(0)+cos(angleR)*(r+30)));//displayText(angleD,angleR,int(float(xcenter)+sin(angleR)*(r+30)),int(float(xcenter)+cos(angleR)*(r+30)));
        }
        drawTicks(angleR,angleD,0,0);//drawTicks(angleR,angleD,xcenter,ycenter);
      }
      
      popMatrix();
     
    }

    void displayText(int aD,float aR, int x, int y){
      textSize(12);
      //text((aD) + "°",x-15,y);
      text((aD) + "°",-x-15,y);
      
      if(dispRadians){
        aR = float(round(aR*100))/100;
        text("R:"+aR,x-15,y+10);
      }
    }
  
    void drawTicks(float aR,int aD, int xcent, int ycent){
      int x1;
      int y1;
      if(aD % 90 == 0){
        x1 = int(float(xcent)+sin(aR)*(radius-120));
        y1 = int(float(xcent)+cos(aR)*(radius-120));
      }else if(aD % 45 == 0){
        x1 = int(float(xcent)+sin(aR)*(radius-60));
        y1 = int(float(xcent)+cos(aR)*(radius-60));
      }else{
        x1 = int(float(xcent)+sin(aR)*(radius-30));
        y1 = int(float(xcent)+cos(aR)*(radius-30));
      }
      int x2 = int(float(xcent)+sin(aR)*(radius+10));
      int y2 = int(float(xcent)+cos(aR)*(radius+10));
      
      //pushMatrix(); 
      //translate(xcenter,ycenter); 
      strokeWeight(2);
      stroke(200,200,200,240);
      line(x1,y1,x2,y2);
      //line(0,0,x1-x2,y1-y2);
      //popMatrix();
    }
  
}
