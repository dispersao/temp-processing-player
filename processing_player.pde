/**
 * oscP5broadcastClient by andreas schlegel
 * an osc broadcast client.
 * an example for broadcast server is located in the oscP5broadcaster exmaple.
 * oscP5 website at http://www.sojamo.de/oscP5
 */

import oscP5.*;
import netP5.*;

int time;
boolean connected = false;

int speedCoeficient = 1;

Script script = null;

OscP5 oscP5;

/* a NetAddress contains the ip address and port number of a remote location in the network. */
NetAddress myBroadcastLocation;

void setup() {
  size(400,400);
  frameRate(10);
  
  /* create a new instance of oscP5. 
   * 12000 is the port number you are listening for incoming osc messages.
   */
  oscP5 = new OscP5(this,7500);
  
  /* create a new NetAddress. a NetAddress is used when sending osc messages
   * with the oscP5.send method.
   */
  
  /* the address of the osc broadcast server */
  myBroadcastLocation = new NetAddress("127.0.0.1",7400);
}


void draw() {
  background(0);
  time = millis();
  String scene = "";
  String token ="";
  String finished ="";
  
  if(script != null){
     scene = script.checkForSequence();
     if (script.token!= "" && script.state == "started") {
       token = script.token;
     }
     if(script.state == "finished") {
       finished = "that's all for today folks!";
     }
  }
  
  
  
  if(connected){
    textSize(20);
    fill(155, 255, 180);
    text("connected", 10, 30);
  }
  
  textSize(32);
  fill(0, 102, 153);

  text(timeInSeconds(), 10, 60); 
  
  if(scene!= "") {
    textSize(20);
    fill(255, 255, 255);
  
    text(scene, 10, 100); 
  }
  
  if (token != "") {
    
    textSize(20);
    fill(155, 155, 155);
  
    text(token, 10, 150);
  } else if (finished!= "") {
    textSize(20);
    fill(155, 155, 155);
    text(finished, 10, 150);

  }
  
}

void fetchNextSequence(int script, Sequence s) {
  println(script, s);
  OscMessage myMessage = new OscMessage("/getScene");
  
  int nextScene = 0;
  if (s!= null){
    nextScene = s.index + 1;
  }
  myMessage.add(script);
  
  myMessage.add(nextScene); /* add an int array to the osc message */
  
  println(myMessage);
  /* send the message */
  oscP5.send(myMessage, myBroadcastLocation); 
}

void playPauseSequence(int script, int seqid, boolean play){
  String addre = "/pauseScene";
  if (play){
    addre = "/playScene";
  }
  OscMessage myMessage = new OscMessage(addre);
  
  myMessage.add(script);
  
  myMessage.add(seqid); /* add an int array to the osc message */
  
  println(myMessage);
  /* send the message */
  oscP5.send(myMessage, myBroadcastLocation);
}

void progressSequence(int script, int seqId, int seqIndex, int progress) {
  OscMessage myMessage = new OscMessage("/sceneProgress");
  myMessage.add(script);
  myMessage.add(seqId);
  myMessage.add(seqIndex);
  myMessage.add(progress);
  
  oscP5.send(myMessage, myBroadcastLocation);
}

int timeInSeconds(){
  return floor(time / 1000);
}

int speed(){
  return speedCoeficient;
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* parse theOscMessage and extract the values from the osc message arguments. */
  float firstValue = theOscMessage.get(0).floatValue();
  print("### received an osc message /test with typetag ifs.");
  println("### received an osc message with addrpattern "+theOscMessage.addrPattern()+" and typetag "+theOscMessage.typetag());
  theOscMessage.print();
  
  int scriptId;
  
  switch(theOscMessage.addrPattern()){
    
     case "/connect":
      scriptId = parseInt(firstValue);
      if (script == null || script.id != scriptId) {
        if(script != null) {
          script.end();
        }
         script = new Script(scriptId);
      }
 
      connected = true;
      OscMessage myMessage = new OscMessage("/connected");
      oscP5.send(myMessage, myBroadcastLocation); 
    break;
    
    case "/session":
    if (script != null){
      String scriptToken = theOscMessage.get(1).stringValue();
      script.startSession(scriptToken   );
    }
    break;
    
    case "/resetsession":
      if (script != null){
        script.reset();
      }
    break;
    
    case "/play":
      scriptId = parseInt(firstValue);
      speedCoeficient = parseInt(theOscMessage.get(1).floatValue());
      if (scriptId == script.id){
        script.start();
      }
    break;
    
    case "/pause":
      script.pause();
    break;
    
    case "/finish":
      if(script!=null) {
        script.end();
      }
    break;
    
    case "/scene":
      float sceneId = theOscMessage.get(1).floatValue();
      println("sceneId:"+sceneId);
      String sceneNumber = theOscMessage.get(2).stringValue();
      println("sceneNumber:"+sceneNumber);
      float index = theOscMessage.get(3).floatValue();
      println("index:"+index);
      float duration = theOscMessage.get(4).floatValue();
      println("duration:"+duration);

      script.addScene(parseInt(sceneId), sceneNumber, parseInt(duration), parseInt(index));
    break;
    
   
  }
}
