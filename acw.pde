import processing.video.*;
import codeanticode.gsvideo.*;
import processing.opengl.*;
import java.lang.reflect.Method;
import hypermedia.net.*;
import java.io.*;

public class OnlyExtension implements FilenameFilter { 
  String ext; 
  public OnlyExtension(String ext) { 
    this.ext = "." + ext; 
  } 
  
  public boolean accept(File dir, String name) { 
    return name.endsWith(ext); 
  } 
}

int WIDTH = 16;
int HEIGHT = 16;
boolean VERTICAL = false;
int FONT_SIZE = HEIGHT;
int FRAMERATE = 30;
String hostname = "192.168.1.130";
int TYPICAL_MODE_TIME = 75;
boolean USE_GSMOVIE = false;

String[] enabledModes = new String[] {
      "drawGreetz",
 //     "drawBursts",
 //     "drawFlash",
  //    "drawLines",
  //    "drawFader",
  //    "drawCurtain",
  //    "drawVertLine",
  //    "drawSticks",
 //     "drawLinesTheOtherWay",
  //    "drawSpin",
  //    "drawAnimation",
  
//    "drawWaves",
   "drawMovie",
 //      "drawStarField"
 //        "drawTargetScanner"
};

String messages[] = new String[] {
  "DiSORienT", 
  "nYC*GRaTiTUDe",
  "HeaVen On eaRTh"
  //  "KOSTUME  KULT",
  //  "BLACK  LIGHT  BALL"
  //"COUNTRY  CLUB"
};  
String message = "DiSORienT";

String[] enabledAnimations = new String[] {
  //"anim-heart"
  "anim-ddr"
};
Animation[] animations;
int currentAnimation = 0;

int w = 0;
int x = WIDTH;
PFont font;
int ZOOM = 1;
int NUMBER_OF_STARS = 30;
Star[] stars;
RadialStar[] radialStars;
Target targetScanner;

int NUMBER_OF_BURSTS = 4;
Burst[] bursts;

long modeFrameStart;
int mode = 0;
boolean burst_fill = false;

int direction = 1;
int position = 0;
Method currentModeMethod = null;

Dacwes dacwes;

int NUMBER_OF_WAVES = 4;
Wave[] waves;

PGraphics fadeLayer;
int fadeOutFrames = 0;
int fadeInFrames = 0;

void setup() {
  // Had to enable OPENGL for some reason new fonts don't work in JAVA2D.
  size(WIDTH, HEIGHT);

  font = loadFont("Disorient-" + FONT_SIZE + ".vlw");
  textFont(font, FONT_SIZE);
  textMode(MODEL);
  frameRate(FRAMERATE);

  stars = new Star[NUMBER_OF_STARS];
  for (int i=0; i<NUMBER_OF_STARS; i++) {
    stars[i] = new Star(i*1.0/NUMBER_OF_STARS*ZOOM);
  }
  
  radialStars = new RadialStar[NUMBER_OF_STARS];
  for (int i=0; i<NUMBER_OF_STARS; i++) {
    radialStars[i] = new RadialStar(); 
  }

  bursts = new Burst[NUMBER_OF_BURSTS];
  for (int i = 0; i<NUMBER_OF_BURSTS; i++) {
    bursts[i] = new Burst();
  }
  
  targetScanner = new Target();

  dacwes = new Dacwes(this, WIDTH, HEIGHT);
  dacwes.setAddress(hostname);
  dacwes.setAddressingMode(Dacwes.ADDRESSING_VERTICAL_FLIPFLOP);  

  if (enabledAnimations.length > 0) {
    animations = new Animation[enabledAnimations.length];
    for (int i=0; i<enabledAnimations.length; i++) {
      animations[i] = new Animation(enabledAnimations[i], 4);
    }
  }

  if (NUMBER_OF_WAVES > 0) {
    waves = new Wave[NUMBER_OF_WAVES];
    for (int i=0; i<NUMBER_OF_WAVES; i++) {
      waves[i] = new Wave();
    }
  }

  setMode(0);  


  smooth();
}

void setFadeLayer(int g) {
  fadeLayer = createGraphics(WIDTH, HEIGHT, P2D);
  fadeLayer.beginDraw();
  fadeLayer.stroke(g);
  fadeLayer.fill(g);
  fadeLayer.rect(0, 0, WIDTH, HEIGHT);
  fadeLayer.endDraw();
}

void setMode(int newMode) {
  String methodName = enabledModes[newMode];

  mode = newMode;
  modeFrameStart = frameCount;
  println("New mode " + methodName);

  try {
    currentModeMethod = this.getClass().getDeclaredMethod(methodName, new Class[] {
    }
    );
  }
  catch (Exception e) { 
    e.printStackTrace();
  }

  // TODO Abstract this into init methods.
  if (methodName == "drawBursts") {
    burst_fill = true; // boolean(int(random(1)+0.5));
  }
  else if (methodName == "drawAnimation") {
    currentAnimation = int(random(animations.length));
    println("Animation set to " + enabledAnimations[currentAnimation]);
  }
}

void newMode() {
  int newMode = mode;
  String methodName;

  fadeOutFrames = FRAMERATE;
  setFadeLayer(240);
  if (enabledModes.length > 1) {
    while (newMode == mode) {
      newMode = int(random(enabledModes.length));
    }
  }

  setMode(newMode);
}

void draw() {
  if (fadeOutFrames > 0) {
    fadeOutFrames--;
    blend(fadeLayer, 0, 0, WIDTH, HEIGHT, 0, 0, WIDTH, HEIGHT, MULTIPLY);

    if (fadeOutFrames == 0) {
      fadeInFrames = FRAMERATE;
    }
  }
  else if (currentModeMethod != null) {
    try {
      currentModeMethod.invoke(this);
    }
    catch (Exception e) { 
      e.printStackTrace();
    }
  }
  else {
    println("Current method is null");
  }

  if (fadeInFrames > 0) {
    setFadeLayer(240 - fadeInFrames*8);
    blend(fadeLayer, 0, 0, WIDTH, HEIGHT, 0, 0, WIDTH, HEIGHT, MULTIPLY);
    fadeInFrames--;
  }

  dacwes.sendData();
}

void drawGreetz() {
  background(0);
  fill(255);

  if (w == 0) {
    w = -int((message.length()-1) * (FONT_SIZE*1.20) + WIDTH);
  }

  text(message, x, FONT_SIZE);

  if (frameCount % 2 == 0) {
    x = x - 1;
  }

  if (x<w) {
    x = WIDTH;  
    message = messages[int(random(messages.length))];
    w = 0;
    newMode();
  }
}

void drawBursts()
{
  //  background(0);

  for (int i=0; i<NUMBER_OF_BURSTS; i++) {
    bursts[i].draw(burst_fill);
  }

  if (frameCount - modeFrameStart > FRAMERATE*TYPICAL_MODE_TIME) {
    newMode();
  }
}


void drawStars() {
  background(0);

  for (int i=0; i<NUMBER_OF_STARS; i++) {
    stars[i].draw();
  }

  if (frameCount - modeFrameStart > FRAMERATE*TYPICAL_MODE_TIME) {
    newMode();
  }
}

void drawStarField() {
  background(0);
 
  for (int i=0; i<NUMBER_OF_STARS; i++) {
    radialStars[i].draw();
  }
 
 if (frameCount - modeFrameStart > FRAMERATE*TYPICAL_MODE_TIME) {
    newMode();
  }
}

void drawTargetScanner() {
  background(0);

  targetScanner.draw();
  
 if (frameCount - modeFrameStart > FRAMERATE*TYPICAL_MODE_TIME) {
    newMode();
  }
}

void drawFlash() {
  long frame = frameCount - modeFrameStart;

  if (frame % (FRAMERATE/5) < 1) {
    background(255);
  }
  else {
    background(0);
  }

  if (frame > FRAMERATE*TYPICAL_MODE_TIME) {
    newMode();
  }
}

void drawLines() {
  background(0);
  stroke(255);

  long frame = frameCount - modeFrameStart;
  int x = int(frame % 5);

  for (int i = -x; i<WIDTH; i+=5) {
    line(i, 0, i+8, 8);
  }

  if (frame > FRAMERATE*TYPICAL_MODE_TIME) {
    newMode();
  }
}

void drawLinesTheOtherWay() {
  background(0);
  stroke(255);

  long frame = frameCount - modeFrameStart;
  int x = int(frame % 5);

  for (int i = x-5; i<WIDTH; i+=5) {
    line(i+8, 0, i, 8);
  }

  if (frame > FRAMERATE*5) {
    newMode();
  }
}

void drawVertLine() {
  background(0);
  stroke(255);

  long frame = frameCount - modeFrameStart;

  if (int(random(10)) == 0)
    direction = -direction;

  position += direction;
  if (position < 0)
  {
    direction = 1;
    position = 0;
  }
  if (position >= WIDTH)
  {
    direction = -1;
    position = WIDTH-1;
  }

  line(position, 0, position, HEIGHT-1);

  if (frame > FRAMERATE*TYPICAL_MODE_TIME) {
    newMode();
  }
}

void drawFader() {
  int frame = int(frameCount - modeFrameStart);

  if (frame < 30) {
    background(int(frame % 30 / 30.0 * 255));
  }
  else if (frame >= 30 && frame < 60) {
    int f = 30-(frame-30);
    background(int(f % 30 / 30.0 * 255));
  }
  else if (frame >= 60 && frame < 120) {
    int f = frame-60;
    background(int(f % 30 / 30.0 * 255));
  }      
  else {
    newMode();
  }
}

void drawSticks() 
{  
  int frame = int(frameCount - modeFrameStart);
  int step = frame % WIDTH;

  if ((frame / WIDTH) % 2 == 0)
  {
    background(0);
    stroke(255);
  }
  else
  {
    background(255);
    stroke(0);
  }

  for (int y = 0; y < HEIGHT; y+=2) {
    line(0, y, step, y);
    line(WIDTH-step, y+1, WIDTH, y+1);
  }

  if (frame >= WIDTH*6)
    newMode();
}

void drawCurtain()
{
  background(0);
  stroke(255);

  int frame = int(frameCount - modeFrameStart);
  int step = frame % (WIDTH/2);

  line(step, 0, step, HEIGHT-1);
  line(WIDTH-step-1, 0, WIDTH-step-1, HEIGHT-1);

  if (frame > WIDTH*4) {
    newMode();
  }
}

void drawSpin() 
{  
  background(0);
  stroke(255);

  int frame = int(frameCount - modeFrameStart);
  int step = frame % (WIDTH+HEIGHT-2);

  if (step < WIDTH)
    line(step, 0, WIDTH-step-1, HEIGHT-1);
  else
    line(0, HEIGHT-(step-WIDTH+1)-1, WIDTH, step-WIDTH+1); 

  if (frame >= (WIDTH+HEIGHT-2)*40)
    newMode();
}

void drawAnimation() {
  boolean done = animations[currentAnimation].draw();

  if (done) { 
    newMode(); 
    background(0);
  }
}

void drawWaves() {
  background(0);
  for (int i=0; i<NUMBER_OF_WAVES; i++) {
    waves[i].draw();
  }

  long frame = frameCount - modeFrameStart;
  if (frame > frameRate*TYPICAL_MODE_TIME) {
    for (int i=0; i<NUMBER_OF_WAVES; i++) {
      waves[i].init();
    }

    newMode();
  }
}

MoviePlayer movie = null;

void drawMovie() {
  if (movie == null) {
    movie = new MoviePlayer(this);
  }

  movie.draw();

  long frame = frameCount - modeFrameStart;
  if (frame > FRAMERATE*TYPICAL_MODE_TIME) {
    newMode();
  }
}

/**
 *
 *
 * =================================================================================================================================
 * =================================================================================================================================
 * =================================================================================================================================
 *
 *
 **/

class RadialStar {
  float x;
  float y;
  float theta;
  float v;
 
 public RadialStar() {
   this.reset();
 }
 
 public void draw() {
   x = x + (v * cos(theta));
   y = y + (v * sin(theta));
   
   noStroke();
   fill(255);
   rect(x, y, 1, 1);
   
   if ((x > WIDTH || x < 0) || (y > HEIGHT || y < 0)) this.reset();
   
 }
 
 public void reset() {
    x = 7;
    y = 7;
    theta = random(0, 2 * PI);
    v = random(0.05, 1);
 }

}

class Target {
 float x;
 float y;
 float destx;
 float desty;
 float v;
 
 public Target() {
  this.reset(); 
 }
 
 public void reset() {
  destx = int(random(0, WIDTH));
  desty = int(random(0, HEIGHT));
  v = random(0.02, 0.07);
 }
 
 public void draw() {
  x = lerp(x, destx, v);
  y = lerp(y, desty, v);
  
  noStroke();
  fill(255);
  rect(int(x), 0, 1, HEIGHT);
  rect(0, int(y), WIDTH, 1);
  ellipse(int(x), int(y), 5, 5);
  
  fill(0);
  ellipse(int(x), int(y), 3, 3);
  
  if (abs(x - destx) < 1 || abs(y - desty) < 1) this.reset();

 }
}

class Star {
  float x;
  float y;
  int z;
  float s;

  public Star(float s) {
    this.s = s;
    this.reset();
  }

  public void draw() {
    x = x + s;
    if (x>WIDTH*ZOOM)
      this.reset();

    noStroke();
    fill(z);
    rect(x, y, ZOOM, ZOOM);
  }

  public void reset() {
    x = -random(WIDTH*ZOOM);
    y = random(HEIGHT*ZOOM);
    //s = random(ZOOM)+1;
    z = int(s/ZOOM*255);
  }
}

class Burst {
  float x;
  float y;
  float d;
  float maxd;
  float speed;
  int intensity;

  public Burst()
  {
    init();
  }

  public void init()
  {
    x = random(WIDTH);
    y = random(HEIGHT);
    maxd = random(10);
    speed = random(5)/10 + 0.1;
    d = 0;
    intensity = 255;
  }

  public void draw(boolean fl)
  {
    if (fl)
      fill(255);
    else
      noFill();
    strokeWeight(2);
    stroke(intensity);
    ellipse(x, y, d, d);
    d+= speed;
    if (d > maxd)
      intensity -= 15;

    if (intensity <= 0)
      init();
  }
}

class Animation {
  public PImage[] frames;
  public int frameNumber;
  int frameDivider;

  public Animation(String name, int frameDivider) {
    this.frameNumber = 0;
    this.frameDivider = frameDivider;
    this.load(name);
  }

  public void load(String name) {
    File dir = new File(savePath("data/" + name));
    FilenameFilter onlyPng = new OnlyExtension("png");
    String[] list = dir.list(onlyPng);
    
    frames = new PImage[list.length];
    for (int i=0; i<frames.length; i++) {
      println("Loading " + name + "/frame" + (i+1) + ".png");
      frames[i] = loadImage(name + "/frame" + (i+1) + ".png");
      frames[i].filter(INVERT);
    }
  }

  public boolean draw() {
    if (frameCount % frameDivider == 0) {
      frameNumber++;
      if (frameNumber >= frames.length) {

        frameNumber = 0;
        return true;
      }

      image(frames[frameNumber], 0, 0, WIDTH, HEIGHT);
    }

    return false;
  }
}

class Wave {
  private float a;
  private float f;
  private float r;
  private int y;
  private boolean t;
  private float s;

  PGraphics g;

  public Wave() {
    init();

    g = createGraphics(WIDTH, HEIGHT, P2D);
  }

  public void init() {
    r = random(TWO_PI);
    f = PI/32 + random(PI/32);
    a = HEIGHT/3 + random(HEIGHT/3);
    y = HEIGHT/8 + int(random(HEIGHT - HEIGHT/8));
    s = PI/128 + random(PI/64);

    if (random(10)<5) { 
      s = -s;
    }
  }

  public void draw() {
    float step;
    float h;

    r = r + s;
    if (r > TWO_PI) r = r - TWO_PI;

    step = r;

    g.beginDraw();
    g.background(0);
    g.stroke(100);

    for (int x=0; x<WIDTH; x++) {
      h = sin(step) * a;
      step = step + f;          
      g.line(x, y, x, y+h);
    }

    g.endDraw();

    blend(g, 0, 0, WIDTH, HEIGHT, 0, 0, WIDTH, HEIGHT, SCREEN);
  }
}    

class MoviePlayer {
  Movie movie;
  GSMovie gsmovie;
  int movieEndFrame;
  String[] movieList;
  PApplet parent;
  int movieDuration;

  public MoviePlayer(PApplet parent) {
    this.parent = parent;
    this.movie = null;
    this.gsmovie = null;
    this.movieEndFrame = 0;
    this.getMovieList();
  }

  public void draw() {
    if ((this.gsmovie == null && this.movie == null) || 
      (frameCount >= movieEndFrame)
    ) {
      loadRandomMovie();
      movieEndFrame = movieDuration; // int(frameRate * (10 + random(35)));
      println("Duration " + movieDuration);
      println("Playing " + movieEndFrame + " frames");
      movieEndFrame += frameCount;
    }

    PImage img;
    if (USE_GSMOVIE) {
      if (gsmovie.available()) { 
        gsmovie.read();
      }
      img = gsmovie;
    }
    else {
      if (movie.available()) { 
        movie.read();
      }
      img = movie; 
    }
    
    PImage imgBright = new PImage(img.width, img.height);
    for (int x = 0; x < img.width; x++) {
      for (int y = 0; y < img.height; y++ ) {
        // Calculate the 1D pixel location
        int loc = x + y*img.width;
        // Get the R,G,B values from image
        float r = red   (img.pixels[loc]);
        float g = green (img.pixels[loc]);
        float b = blue  (img.pixels[loc]);
        // Change brightness according to the mouse here
        float adjustBrightness = 5.0;
        r *= adjustBrightness;
        g *= adjustBrightness;
        b *= adjustBrightness;
        // Constrain RGB to between 0-255
        r = constrain(r,0,255);
        g = constrain(g,0,255);
        b = constrain(b,0,255);
        // Make a new color and set pixel in the window
        color c = color(r,g,b);
        imgBright.pixels[loc] = c;
      }
    }
    image(imgBright, 0, 0, WIDTH, HEIGHT);

  }

  public void getMovieList() {
    File dir = new File(savePath("data/movies" ));
    FilenameFilter onlyMov = new OnlyExtension("mov");
    movieList = dir.list(onlyMov);
  }

  public void loadRandomMovie() {
    int index = int(random(movieList.length));
    String filename = movieList[index];
    
    println("Loading "+filename);

    if (USE_GSMOVIE) {
      if (gsmovie != null)
        gsmovie.stop();
      gsmovie = new GSMovie(this.parent, "movies/"+filename);
      gsmovie.resize(WIDTH, HEIGHT);
      gsmovie.volume(0);
      gsmovie.loop();
      movieDuration = int(gsmovie.duration() * 30);
    }
    else {
      if (movie != null)
        movie.stop();      
      movie = new Movie(this.parent, "movies/"+filename);
      movie.resize(WIDTH, HEIGHT);
      movie.loop();
      movieDuration = int(movie.duration() * 30);
    }
  }
}

