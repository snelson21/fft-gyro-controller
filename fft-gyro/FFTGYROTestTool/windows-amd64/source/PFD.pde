class PFD {
  
  color c;
  int xcenter;
  int ycenter;
  float xspeed;
  boolean dispRadians;
  int radius;
  float angleR;
  int M;
  //float yaw,pitch,roll;
  PApplet parent;
  
  // The Constructor is defined with arguments.
  PFD(PApplet parent,int tempXpos,int tempYpos, int r, int Mn) {
    this.parent = parent;
    xcenter = tempXpos;
    ycenter = tempYpos;
    
    M=Mn;//INDICE Motor
    
    dispRadians = false;
    radius = r;
  }

  void display(boolean Flag,float pitch,float roll, float yaw) {
        
    if(Flag){
      drawAll(false,pitch,roll,yaw);
    }
    
    parent.fill(0, 255, 0, 255);  //Cambia la letra de color
    parent.textSize(22);
    
    int d = day();    // Values from 1 - 31
    int m = month();  // Values from 1 - 12
    int y = year();   // 2003, 2004, 2005, etc
    int s = second();  // Values from 0 - 59
    int mn = minute();  // Values from 0 - 59
    int h = hour();    // Values from 0 - 23
    String Timestamp = d + "/"+ m + "/" + y + "  " + h + ":" + mn + ":" + s;
    parent.text(Timestamp,650,35);
    
      
  }
  
  void update(float pitch,float roll, float yaw){
    
    int len=30;
    int lenarrow = 20;
    //float comp1 = pitch;//+270;
    
    float pitchtext= pitch;
    if(pitch>180){
      pitchtext= -180 + (pitch-180);
    }
    
    float rolltext= 0;
    if(roll>180){
      rolltext=360-roll;
    }else if(roll>0){
      rolltext = -1.0*roll;
    }
    
    
    float yawtext = 360-yaw;
    if(yaw==0){
      yawtext = 0;
    }
    
    parent.textSize(25);
    parent.fill(255, 255, 255, 255);  //Cambia la letra de color
    parent.text("Pitch: "+ (pitchtext) + "°",20,40);
    
    parent.textSize(25);
    parent.fill(255, 255, 255, 255);  //Cambia la letra de color
    parent.text("Roll: "+ (rolltext) + "°",20,80);
    
    parent.textSize(25);
    parent.fill(255, 255, 255, 255);  //Cambia la letra de color
    parent.text("Yaw: "+ (yawtext) + "°",20,120);
    
    
    parent.pushMatrix(); 
    parent.translate(xcenter,ycenter);
    parent.rotate(radians(roll));
    
    /*************************/
    /*         ROLL          */
    /*************************/
    
    
    
    /*************************/
    /*        PITCH          */
    /*************************/
    
    parent.stroke(255,255,255,255);  
    parent.strokeWeight(2);
    parent.fill(188 , 142, 13, 255);  //TIERRA
    parent.arc(0, 0, radius*2, radius*2, 0, 2*PI, OPEN);
    
    float pitchRad = radians(pitchtext)*3;
    
    parent.stroke(255,255,255,255);  
    parent.strokeWeight(2);
    parent.fill(54 , 109, 255, 255);  //AIRE
    parent.arc(0, 0, radius*2, radius*2, PI-pitchRad, 2*PI + pitchRad, OPEN);
    
    
    if(pitchtext>90){
      
      parent.stroke(255,255,255,255);  
      parent.strokeWeight(2);
      parent.fill(54 , 109, 255, 255);  //AIRE
      parent.arc(0, 0, radius*2, radius*2, 0, 2*PI, OPEN);
      
      pitchRad = radians(pitchtext-180)*3;
      
      parent.stroke(255,255,255,255);  
      parent.strokeWeight(2);      
      parent.fill(188 , 142, 13, 255);  //TIERRA
      parent.arc(0, 0, radius*2, radius*2, PI - pitchRad, 2*PI + pitchRad, OPEN);
    
    } else if(pitchtext<-90){
      
      parent.stroke(255,255,255,255);  
      parent.strokeWeight(2);           
      parent.fill(54 , 109, 255, 255);  //AIRE 
      parent.arc(0, 0, radius*2, radius*2, 0, 2*PI, OPEN);
      
     
      pitchRad = radians(180+pitchtext)*3;
      
      parent.stroke(255,255,255,255);  
      parent.strokeWeight(2);      
      parent.fill(188 , 142, 13, 255);  //TIERRA
      parent.arc(0, 0, radius*2, radius*2, PI- pitchRad, 2*PI+ pitchRad, OPEN);
      
    }
    
    //println("Pitch : "+ pitch + "  pitchtext txt: " +pitchtext + " pitchRad: " + pitchRad);
    
    parent.popMatrix();
    
    
    
    /*************************/
    /*        YAW          */
    /*************************/    
    
    parent.noFill();  
    parent.circle(xcenter, ycenter*3+50, radius*3+90);
    writeAnglesYaw(xcenter, ycenter*3+50, radius*2-100,yaw);
 
    int sizeTriangle=20;
    int newxcent = xcenter;
    int newycent = ycenter*3+40;
    int newrad=  radius*2;
    int distanceFromcenter = 60;
    parent.stroke(237,255,49,255);     
    parent.fill(237,255,49,255);
    parent.triangle(newxcent-(sizeTriangle/2),newycent - newrad+30 , newxcent+(sizeTriangle/2),newycent -newrad+30 ,newxcent,newycent -newrad+50);
    
    /*************************/
    /*        LINES      */
    /*************************/
    
    parent.pushMatrix(); 
    //2.- Lineas horizontales de Pitch
    drawLinesPitch(30,350,70, xcenter,ycenter);    
    parent.popMatrix();
    
    
    /*************************/
    /*        TRIANGULO      */
    /*************************/
    parent.pushMatrix();
    parent.translate(xcenter,ycenter);
    parent.rotate(radians(roll));
    
    //1.- Triangulo de Roll Fijo
    parent.stroke(237,255,49,255);     
    parent.fill(237,255,49,255);
    parent.triangle(0-(sizeTriangle/2)-5, -radius + sizeTriangle+10 , 0+(sizeTriangle/2)+5, -radius + sizeTriangle+10 , 0, -radius+5);
    
    parent.popMatrix();

    
  }


  void drawAll(boolean dr,float pitch,float roll, float yaw){
      
      float LeftLim = 180;
      float RightLim = 360;
      
      for(int i=0;i<=180;i++){      
        
          drawLines(i,radius,10,xcenter,ycenter);

      }
      
    }
    
    
    
    void drawLinesPitch(int distance, int Height,int sizeMaxLine, int xcent,int ycent){
      
      boolean  Flag= false;
      for(int i=0;i<(Height/2);i++){
        
        if(i%distance ==0){
          parent.strokeWeight(3);
          parent.stroke(255,255,255,255);
          
          
          if(Flag){
            Flag=false;
            parent.line(xcent-(sizeMaxLine/2)*0.4, ycent +i , xcent+(sizeMaxLine/2)*0.4, ycent+i);    
            parent.line(xcent-(sizeMaxLine/2)*0.4, ycent -i , xcent+(sizeMaxLine/2)*0.4, ycent-i);
          }else{
            Flag=true;
            parent.line(xcent-(sizeMaxLine/2), ycent +i , xcent+(sizeMaxLine/2), ycent+i);    
            parent.line(xcent-(sizeMaxLine/2), ycent -i , xcent+(sizeMaxLine/2), ycent-i);
          }
              
        }
        
      }
      
      
      parent.strokeWeight(5);
      parent.stroke(0,255,0,255);
      int P1=160;
      int P1L = 60;
      int P2L = 25;
      parent.line(xcent-P1,ycent , xcent-P1+P1L, ycent);
      parent.line(xcent-P1,ycent , xcent-P1, ycent+ P2L);
      
      parent.line(xcent+P1,ycent , xcent+P1-P1L, ycent);
      parent.line(xcent+P1,ycent , xcent+P1, ycent+ P2L);      
    }
   
    
    void drawLines(int angleD, int r, int tI, int xcent,int ycent){ //tI = tickInterval;
     
      parent.strokeWeight(4);
      parent.fill(255, 255, 255, 255);  //Cambia la letra de color
      parent.stroke(255,255,255,255);   
      parent.pushMatrix(); 
      parent.translate(xcent,ycent);
      
      //xcenter=0;
      //ycenter=0;
      
      angleR = (-angleD+180) * (PI/180);    //angleD+90
      //xpos = int(float(0)  + sin(angleR)*radius);//xpos = int(float(xcenter)  + sin(angleR)*radius);
      //ypos = int(float(0)  + cos(angleR)*radius);//ypos = int(float(ycenter)  + cos(angleR)*radius);
      
      //if(angleD<360 && angleD>180){
        //point(xpos,ypos);                  
        if(angleD % tI == 0){
          if(angleD % 45 == 0){//Angulos Rectos
            if(angleD==180){
              displayText(angleD,angleR,int(float(0)+sin(angleR)*(r+30)),int(float(0)+cos(angleR)*(r+30)));//displayText(angleD,angleR,int(float(xcenter)+sin(angleR)*(r+30)),int(float(xcenter)+cos(angleR)*(r+30)));
            }else{
              displayText(angleD,angleR,int(float(0)+sin(angleR)*(r+30)),int(float(0)+cos(angleR)*(r+30)));//displayText(angleD,angleR,int(float(xcenter)+sin(angleR)*(r+30)),int(float(xcenter)+cos(angleR)*(r+30)));
              displayText(-angleD,angleR,int(float(0)+sin(-angleR)*(r+30)),int(float(0)+cos(-angleR)*(r+30)));//displayText(angleD,angleR,int(float(xcenter)+sin(angleR)*(r+30)),int(float(xcenter)+cos(angleR)*(r+30)));
            }
            
          }else if(angleD % 10 == 0){//Los demas
            displayText(angleD,angleR,int(float(0)+sin(angleR)*(r+30)),int(float(0)+cos(angleR)*(r+30)));//displayText(angleD,angleR,int(float(xcenter)+sin(angleR)*(r+30)),int(float(xcenter)+cos(angleR)*(r+30)));
            displayText(-angleD,angleR,int(float(0)+sin(-angleR)*(r+30)),int(float(0)+cos(-angleR)*(r+30)));//displayText(angleD,angleR,int(float(xcenter)+sin(angleR)*(r+30)),int(float(xcenter)+cos(angleR)*(r+30)));
            
          }
          drawTicks(angleR,angleD,0,0);//drawTicks(angleR,angleD,xcenter,ycenter);
          drawTicks(-angleR,angleD,0,0);//drawTicks(angleR,angleD,xcenter,ycenter);
        }
      //}
      
      parent.popMatrix();
     
    }

    void displayText(int aD,float aR, int x, int y){
      
      parent.textSize(14);
      //text((aD) + "°",x-15,y);
      parent.text((aD) + "°",-x-15,y);
      
      if(dispRadians){
        aR = float(round(aR*100))/100;
        parent.text("R:"+aR,x-10,y+10);
      }
    }
  
    void drawTicks(float aR,int aD, int xcent, int ycent){
      int x1;
      int y1;
      if(aD % 90 == 0){
        x1 = int(float(xcent)+sin(aR)*(radius-10));
        y1 = int(float(xcent)+cos(aR)*(radius-10));
      }else if(aD % 45 == 0){
        x1 = int(float(xcent)+sin(aR)*(radius-30));
        y1 = int(float(xcent)+cos(aR)*(radius-30));
      }else{
        x1 = int(float(xcent)+sin(aR)*(radius-10));
        y1 = int(float(xcent)+cos(aR)*(radius-10));
      }
      int x2 = int(float(xcent)+sin(aR)*(radius+10));
      int y2 = int(float(xcent)+cos(aR)*(radius+10));
      
      //pushMatrix(); 
      //translate(xcenter,ycenter); 
      parent.strokeWeight(2);
      parent.stroke(200,200,200,255);
      parent.line(x1,y1,x2,y2);
      //line(0,0,x1-x2,y1-y2);
      //popMatrix();
    }
  
  
  
  public void writeAnglesYaw(int xcent, int ycent,int rad,float yaw){
      
      for(int i=0;i<=360;i++){      
        drawLines360(i,rad,10,xcent,ycent,yaw);
      }
      
    }
  
  
  void drawLines360(int angleD, int r, int tI, int xcent,int ycent,float yaw){ //tI = tickInterval;
     
      parent.strokeWeight(4);
      parent.fill(255, 255, 255, 255);  //Cambia la letra de color
      parent.stroke(255,255,255,255);   
      parent.pushMatrix(); 
      parent.translate(xcent,ycent);
      parent.rotate(radians(yaw));
      
      angleR = (-angleD+180) * (PI/180);    //angleD+90
      //xpos = int(float(0)  + sin(angleR)*radius);//xpos = int(float(xcenter)  + sin(angleR)*radius);
      //ypos = int(float(0)  + cos(angleR)*radius);//ypos = int(float(ycenter)  + cos(angleR)*radius);
      
              
        if(angleD % tI == 0){
          if(angleD % 45 == 0){//Angulos Rectos
            if(angleD==180){
              displayText360(angleD,angleR,int(float(0)+sin(angleR)*(r+30)),int(float(0)+cos(angleR)*(r+30)));//displayText(angleD,angleR,int(float(xcenter)+sin(angleR)*(r+30)),int(float(xcenter)+cos(angleR)*(r+30)));
            }else{
              if(angleD==360){
              }else{
                displayText360(angleD,angleR,int(float(0)+sin(angleR)*(r+30)),int(float(0)+cos(angleR)*(r+30)));//displayText(angleD,angleR,int(float(xcenter)+sin(angleR)*(r+30)),int(float(xcenter)+cos(angleR)*(r+30)));
              //displayText(-angleD,angleR,int(float(0)+sin(-angleR)*(r+30)),int(float(0)+cos(-angleR)*(r+30)));//displayText(angleD,angleR,int(float(xcenter)+sin(angleR)*(r+30)),int(float(xcenter)+cos(angleR)*(r+30)));
              }
            }
            
          }else if(angleD % 10 == 0){//Los demas
            displayText360(angleD,angleR,int(float(0)+sin(angleR)*(r+30)),int(float(0)+cos(angleR)*(r+30)));//displayText(angleD,angleR,int(float(xcenter)+sin(angleR)*(r+30)),int(float(xcenter)+cos(angleR)*(r+30)));
            
          }
        }
      
      parent.popMatrix();
     
    }

    void displayText360(int aD,float aR, int x, int y){
      
      parent.pushMatrix(); 
      parent.translate(x,y);
      parent.rotate(PI-aR);
      
      parent.textSize(14);
      parent.text((aD) + "°",0-15,0);
      
      parent.popMatrix();
      
    }
  
  
}
