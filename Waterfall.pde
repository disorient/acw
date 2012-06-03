class Waterfall {
  float x;
  float y;
  float len;
  float v;
  
  public Waterfall() {
    this.reset(); 
  }
  
  public void reset() {
    x = int(random(0, WIDTH));
    y = -1;
    len = random(1, height/2);
    v = random(0.1, 1);
  }
  
  public void draw() {
    y = y + v; 
        
//    rect(x, y, 0.1, len);
    for (int j=0; j<len; j++) {
      stroke(int(sin(j*1.0/len*3.14)*255));
      point(x,y+j);
    }
    
    if (y > HEIGHT) this.reset();
    
  }
}


