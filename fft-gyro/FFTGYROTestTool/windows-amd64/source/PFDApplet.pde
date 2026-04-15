class PFDApplet  extends PApplet {

  PFD pfd2;
  float pitch,roll,yaw;
  float pitchComp,rollComp,yawComp;

  public PFDApplet() {
    super();
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }

  public void settings() {
    size(900, 700,P3D);
    smooth();
  }
  public void setup() { 
    surface.setTitle("PFD");
    pfd2 = new PFD(this,450,290,190,1);
    
    pitchComp=0;
    rollComp=0;
    yawComp=0;
  }

  public void draw() {
    background(0);
    
    
    float pitchNormalized = normaliseAngle(pitch-pitchComp);
    float rollNormalized = normaliseAngle(roll-rollComp);
    float yawNormalized = normaliseAngle(yaw-yawComp);
    
    
    //UPDATE:30/SEP/2021
    //FIJO
    pfd2.display(true,rollNormalized,pitchNormalized,yawNormalized);
  
    //DINÁMICO
    pfd2.update(rollNormalized,pitchNormalized,yawNormalized);
  }

  
}
