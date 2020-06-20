/**
 * oscP5broadcastClient by andreas schlegel
 * an osc broadcast client.
 * an example for broadcast server is located in the oscP5broadcaster exmaple.
 * oscP5 website at http://www.sojamo.de/oscP5
 */

import oscP5.*;
import netP5.*;

/**
 * A specific fork of websocket for p5 must be used
 * It can be found here https://github.com/avantcontra/processing_websockets/blob/master/webSockets.zip
 * Or on dispersao's repo
 * It must be unzipped into /home/user/sketchbook/libraries/ (in linux systems)
 */

import websockets.*;
WebsocketServer ws;

int lastRequestedIndex;

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

  //WebSocket
  ws = new WebsocketServer(this, 8081, "");

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
  lastRequestedIndex = nextScene;
  myMessage.add(script);

  myMessage.add(nextScene); /* add an int array to the osc message */

  println(myMessage);
  /* send the message */
  ws.sendMessage(myMessage.getBytes());
}

void sceneState(int seqid, int seqIndex, String state, int prog){
  println("sceneState");

  OscMessage myMessage = new OscMessage("/updateScene");
  myMessage.add(script.id);
  myMessage.add(seqid); /* add an int array to the osc message */
  myMessage.add(seqIndex);
  myMessage.add(state); /* add an int array to the osc message */
  myMessage.add(prog);

  println(myMessage);
  /* send the message */
  ws.sendMessage(myMessage.getBytes());
}

void progressSequence(int script, int seqId, int seqIndex, int progress) {
  OscMessage myMessage = new OscMessage("/sceneProgress");
  myMessage.add(script);
  myMessage.add(seqId);
  myMessage.add(seqIndex);
  myMessage.add(progress);

  ws.sendMessage(myMessage.getBytes());
}

int timeInSeconds(){
  return round(time / 1000);
}

int timeInMiliseconds(){
  return time;
}

int speed(){
  return speedCoeficient;
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* parse theOscMessage and extract the values from the osc message arguments. */
  float firstValue;
  print("### received an osc message /test with typetag ifs.");
  println("### received an osc message with addrpattern "+theOscMessage.addrPattern()+" and typetag "+theOscMessage.typetag());
  theOscMessage.print();

  int scriptId;

  switch(theOscMessage.addrPattern()){

     case "/connect":
     firstValue = theOscMessage.get(0).floatValue();

      scriptId = parseInt(firstValue);
      if (script == null || script.id != scriptId) {
        if(script != null) {
          script.end();
        }
         script = new Script(scriptId);
      }

      connected = true;
      //OscBundle myBundle = new OscBundle();

      OscMessage myMessage = new OscMessage("/connected");
       //myBundle.add(myMessage);
       //myBundle.setTimetag(OscBundle.now());
       //oscP5.send(myBundle, myBroadcastLocation);
      ws.sendMessage(myMessage.getBytes());
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
      firstValue = theOscMessage.get(0).floatValue();
      scriptId = parseInt(firstValue);
      speedCoeficient = parseInt(theOscMessage.get(1).floatValue());
      println(scriptId+ " "+script.id);
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


//Binary data received from WebSocket Client
void webSocketServerEvent(byte[] buf, int offset, int length){
   print ("buffer ws: "+buf);
  //send to OSC (UDP) to parse the data
  OscP5.flush(buf, myBroadcastLocation);


}

//String data received from WebSocket Client
void webSocketServerEvent(String msg){
  println(msg);
  //JSONObject json = parseJSONObject(msg);
  //if (json == null) {
  //   println("JSONObject could not be parsed");
  // } else {
  //   String species = json.getString("address");
  //   println(species);
  // }

}
