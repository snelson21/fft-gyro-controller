class ChildApplet extends PApplet {

  Arcball arcball2;
  float yaw_ch,pitch_ch,roll_ch;
  float yaw_comp,pitch_comp,roll_comp;

  public ChildApplet() {
    super();
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }

  public void settings() {
    size(500, 500, P3D);
    smooth();
  }
  public void setup() { 
    surface.setTitle("3D Model");
    arcball2 = new Arcball(this, 300);
    
    yaw_comp= 0;
    pitch_comp= 0;
    roll_comp=0;
  }

  public void draw() {
    background(0);
    
    
    arcball2.pitch = pitch_ch-pitch_comp;
    arcball2.roll = roll_ch-roll_comp;
    arcball2.yaw = yaw_ch-yaw_comp;
    
    arcball2.run();
    
    if (mousePressed) {
      fill(240, 0, 0);
      ellipse(mouseX, mouseY, 20, 20);
      fill(255);
      //text("Mouse pressed on child.", 10, 30);
    } else {
      fill(255);
      ellipse(width/2, height/2, 20, 20);
    }

    box(150, 150, 150);
    //rings();
    
    if (mousePressedOnParent) {
      fill(255);
      //text("Mouse pressed on parent", 20, 20);
    }
  }

  public void mousePressed() {
    arcball2.mousePressed();
  }

  public void mouseDragged() {
    arcball2.mouseDragged();
  }
  
  
}
