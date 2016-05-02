import java.util.ArrayList;
import java.util.Collections;
import ketai.sensors.*;

KetaiSensor sensor;

float cursorX, cursorY;
float light = 0;

float lightThreshold = 60;
int targetWidth;
int targetHeight;

  private class Target
  {
    int target = 0;
    int action = 0;
  }

  int trialCount = 5; //this will be set higher for the bakeoff
  int trialIndex = 0;
  boolean trialsComplete = false;
  
  ArrayList<Target> targets = new ArrayList<Target>();
     
  int startTime = 0; // time starts when the first click is captured
  int finishTime = 0; //records the time of the final click
  boolean userDone = false;
  
  int stage = 0; //stage 0 = select one of 4, stage 1 = select one of 2
  
  int countDownTimerWait = 0;
  
  void setup() {
    fullScreen();
    frameRate(60);
    sensor = new KetaiSensor(this);
    sensor.start();
    orientation(PORTRAIT);
  
    rectMode(CENTER);
    textFont(createFont("Arial", 40)); //sets the font to Arial size 20
    textAlign(CENTER);
    
    targetWidth = width/2;
    targetHeight = height/2;
    for (int i=0;i<trialCount;i++)  //don't change this!
    {
      Target t = new Target();
      t.target = ((int)random(1000))%4;
      t.action = ((int)random(1000))%2;
      targets.add(t);
      println("created target with " + t.target + "," + t.action);
    }
    
    Collections.shuffle(targets); // randomize the order of the button;
  }
int row;
int col;
void draw() {

    background(80); //background is light grey
    noStroke(); //no stroke
    
    countDownTimerWait--;
    
    if (startTime == 0)
      startTime = millis();
    
    if (trialsComplete && !userDone)
    {
      userDone=true;
      finishTime = millis();
    }
    
    if (userDone)
    {
      text("User completed " + trialCount + " trials", width/2, 50);
      text("User took " + nfc((finishTime-startTime)/1000f/trialCount,1) + " sec per target", width/2, 150);
      trialIndex = 0;
      return;
    }

    for (int i=0;i<4;i++)
    {
      if(targets.get(trialIndex).target==i)
         fill(0,255,0);
         else
         fill(180,180,180);
      
      row = i/2;
      col = i%2;
      rectMode(CORNER);
      rect(col*targetWidth, row*targetHeight, targetWidth, targetHeight);
    }

    if (light>lightThreshold)
      fill(180,0,0);
    else
      fill(255,0,0);
    ellipse(cursorX,cursorY,50,50);
 
    fill(255);//white
    text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, 50);
    text("Target #" + (targets.get(trialIndex).target)+1, width/2, 100);
    
    if (targets.get(trialIndex).action==0)
      text("UP", width/2, 150);
    else
       text("DOWN", width/2, 150);
  }
  
void onAccelerometerEvent(float x, float y, float z)
{
  print(trialIndex);
  if (userDone) 
    return;
    
  if (light>lightThreshold) //only update cursor, if light is low
  {
    cursorX = width/2 - x*100; //cented to window and scaled
    cursorY = height/2  + y*100; //cented to window and scaled
    
    if (cursorX < 0) cursorX = 0;
    if (cursorY < 0) cursorY = 0;
    if (cursorX > width) cursorX = width;
    if (cursorY > height) cursorY = height;
  }
  
  Target t = targets.get(trialIndex);
  if (light<=lightThreshold && abs(z-9.8)>4 && countDownTimerWait<0) //possible hit event
  {
   
    if (hitTest()==t.target)//check if it is the right target
    {
      print(z-9.8);
      if (((z-9.8)>4 && t.action==0) || ((z-9.8)<-4 && t.action==1))
      {
        println("Right target, right z direction! " + hitTest());
        trialIndex++; //next trial!
        if (trialIndex == trialCount) {
          trialsComplete = true;
          trialIndex = 0;
        }
      }
      else
        println("right target, wrong z direction!");
        
      countDownTimerWait=30; //wait 0.5 sec before allowing next trial
    }
    else
      println("Missed target! " + hitTest()); //no recording errors this bakeoff.
  }
}

int hitTest() 
{
   for (int i=0;i<4;i++) {
      row = i/2;
      col = i%2;
      if (cursorX >= col*targetWidth && cursorX <= (col+1)*targetWidth
          && cursorY >= row*targetHeight && cursorY <= (row+1)*targetHeight) 
        return i;
   }
   return -1;
}

void restart() {
  trialIndex = 0;
  targets = new ArrayList<Target>();
  startTime = 0; // time starts when the first click is captured
  finishTime = 0; //records the time of the final click
  stage = 0; //stage 0 = select one of 4, stage 1 = select one of 2
  countDownTimerWait = 0;
  trialsComplete = false;
  
  for (int i=0;i<trialCount;i++)  //don't change this!
    {
      Target t = new Target();
      t.target = ((int)random(1000))%4;
      t.action = ((int)random(1000))%2;
      targets.add(t);
      println("created target with " + t.target + "," + t.action);
    }
    
    Collections.shuffle(targets);
    userDone = false;
  
}
void mousePressed(){ 
  if (userDone) {
    restart();
  }
}
void onLightEvent(float v) //this just updates the light value
{
  light = v;
}