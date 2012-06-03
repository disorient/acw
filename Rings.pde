class Rings extends Routine {
  int y = 0;
  float xofs = 0;
  
  void setup(PApplet parent) {
    super.setup(parent);
    background(0);
  }
  
  void draw() {
    //background(0);

    for (int x=0; x<width; x++) {
      stroke(abs(int(sin((sin(xofs)*width+x)*1.0/width*3.14)*255)));
     
      point(x,y);
    }
    
    xofs += PI/(width*3);    
    
    if (frameCount % 4 == 0) {
      y++;
      
      if (y>height)
        y=0;
    }
  }
}

