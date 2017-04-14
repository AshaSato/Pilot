//stimuli recorder

import g4p_controls.*;
import shapes3d.*;
import shapes3d.animation.*;
import shapes3d.utils.*;

import oscP5.*;
import netP5.*;

 /*
To run: 
1. Open the KinectOSCsender FIRST. 
2. Open this Program, to send the filename to the KinectOSCsender
3. Connect the Kinect LAST
*/



////////////////////////
//-----GLOBALS--------//
////////////////////////







//FORMATTY STUFF//
PFont textFont;

//OSC STUFF//
OscP5 oscKinect;
NetAddress kinectLocation;

//SKELETON OBJECTS//
// (see skeletonAnimation and SkeletonMonitor classes) // 
SkeletonAnimation skellyAnim;
SkeletonMonitor skellyMon;

//LAYOUT STUFF//
int skeletonView = 0; //used for switching between viewports in main draw loop, 0 = animation, 1 = monitor
PGraphics viewPort;

//STIMULI STUFF//
String [] stimList = {"to push", "to carry", "to pull", "to play the accordion", 
                      "to play the guitar", "to eat", "to brush teeth", "to clean",
                      "to swim", "to drive", "to lift weights", "to brush hair", 
                      "to knock on a door", "to saw", "to mix", "to row", "to drum",
                      "to paint", "to bounce a ball", "to use a rolling pin",
                      "to shake", "to climb", "to give", "to hit", "to open the door", 
                      "to put on a seatbelt", "to throw", "to tear something", 
                      "to open the curtain", "to put on a hat",  "to put on a jacket", 
                      "to zip up a jacket"};
                      
int responsesGiven = 0;
boolean gestureSent = false;
String currentStim;
                    
//BUTTONS                     
GButton c0, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15,
c16,c17,c18,c19,c20,c21,c22,c23,c24,c25,c26,c27,c28,c29,c30,c31;

GButton[] bList = {c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,
c16,c17,c18,c19,c20,c21,c22,c23,c24,c25,c26,c27,c28,c29,c30,c31};


//RECORDING STUFF//
int counter = 0;
int wait = 8000;



void setup () {
  size(2000,1000, P3D);
  background(255);
  textFont = loadFont("Calibri.vlw");
  textSize(30);
  
  //listening for incoming OSC messages at port 12345, sending to kinectLocation at port 5000
  oscKinect = new OscP5(this, 12345);   
  kinectLocation = new NetAddress("127.0.0.1", 5000);
  
  //initialize viewport
  viewPort = createGraphics(1000,1000,P3D);
  //create new Skeleton object
  skellyMon = new SkeletonMonitor(this, new PVector(width*.5,height*.35,0),700,0);
  
  //DRAW BUTTON ARRAY 
  //row 1
  for (int i = 0; i<8; i++) {
    bList[i] = new GButton(this, 25+i*250,50, 200,70,stimList[i]);
    bList[i].setVisible(true);
    bList[i].setFont(new java.awt.Font("Sans Serif", java.awt.Font.BOLD, 24));
  }
 
  //row 2
  int x = 0;
    for (int i = 8; i<16; i++) {
    bList[i] = new GButton(this,25+x*250,180, 200,70,stimList[i]);
    bList[i].setVisible(true);
    bList[i].setFont(new java.awt.Font("Sans Serif", java.awt.Font.BOLD, 24));
    x+=1;
  }
  
    //row 3
  int y = 0;
    for (int i = 16; i<24; i++) {
    bList[i] = new GButton(this,25+y*250,310, 200,70,stimList[i]);
    bList[i].setVisible(true);
    bList[i].setFont(new java.awt.Font("Sans Serif", java.awt.Font.BOLD, 24));
    y+=1;
  }
  
    //row 4
  int z = 0;
    for (int i = 24; i<32; i++) {
    bList[i] = new GButton(this,25+z*250,440, 200,70,stimList[i]);
    bList[i].setVisible(true);
    bList[i].setFont(new java.awt.Font("Sans Serif", java.awt.Font.BOLD, 24));
    z+=1;
  }
  
}

void draw() {
  background(255);
  lights();
  directionalLight(255,255,255,0,-1,0);
  
  switch(skeletonView){
    case 0:
    //buttons
    break;
    
    case 1:
    //recording
    skellyDo();
    skellyMon.drawViewport(viewPort);
    image(viewPort,0,0);
    break;
  
  } 

}



public void handleButtonEvents(GButton button, GEvent event) {
  record(button);
  currentStim = button.getText();
}


void sendRawOSC() {
    OscMessage gestureMessage = new OscMessage("/gesture");
  gestureMessage.add(currentStim);
  //send the message
  oscKinect.send(gestureMessage,kinectLocation);
  gestureMessage = null; //reset
  gestureSent = true;

}

void skellyDo() {
  //countdown to recording
   fill(255,0,0);
   textSize(80);
   if(millis()-counter < 1000) {
   text("3", 500,160);
   } else if (millis()-counter <2000) {
   text("2", 500,160);
   } else if (millis()-counter <3000) {
   text("1", 500,160);
   } else { //recording
   
  //use boolean switch to send gesture message
  //to c code once for each gesture
  //if (gestureSent == false){
  //  sendRawOSC();
  //}
  
    //record
   skellyMon.recordSkeleton(skellyMon.p,currentStim);
   pushMatrix();
   translate(0,0,-150);
   
   rectMode(CENTER);
   fill(255,0,0,50);
   rect(width*.5,height*.5,900,900);
   popMatrix();
   textSize(50);
   text("RECORDING",500,900);
   if (millis() - counter > wait) {
     gestureSent = false;
     skeletonView = 0;
     responsesGiven +=1;
        //display updated array 
     for(GButton b: bList) {
    b.setVisible(true);
  }
     
   }
   
  

}
}

void record(GButton button){
  //hide buttons
   button.setLocalColorScheme(G4P.PURPLE_SCHEME);
    
   for (GButton b: bList) {
     b.setVisible(false);
     button.setEnabled(false);
   }
   //switch to skeleton View: 
   skeletonView = 1;
   counter = millis(); 
   
   //create data file
   skellyMon.createSkeletonFile("Out_unfiltered/"+responsesGiven+".txt");    
   //responsesGiven +=1;
   println("Responses given: "+responsesGiven);
   //start countdown 
   

   //write frames to file
   
}




void oscEvent(OscMessage msg) {
  //sends incoming kinect data to filter function. 
  //i guess it won't need filtering
  for (int i = 0; i < skellyMon.jointNames.length; i++) {
    
    //if message address matches a jointName
    if (msg.checkAddrPattern("/skeleton/"+skellyMon.jointNames[i])) { 

        //parse osc message
         float x = (msg.get(0).floatValue())*skellyMon.sF; 
         float y = (msg.get(1).floatValue())*skellyMon.sF;
         float z = (msg.get(2).floatValue())*skellyMon.sF;
         
         String trackingState = msg.get(3).stringValue();
         
         //send values to be filtered
         //convert to negative values because kinect coordinate system is right-handed
         //but processing's coordinate system is left-handed
         
         //not filtered anymore
         skellyMon.updateJoint(skellyMon.jointNames[i],x,-y,-z,trackingState);
    }
  }
}