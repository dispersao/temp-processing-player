class Sequence { 
  int id;
  String sceneNumber;
  int duration;
  boolean isPlaying;
  int index;
  int startedAt;
  int willEndAt;
  String playingString;
  
  Sequence(String scn, int _id, int dur) {
    id = _id;
    sceneNumber = scn;
    duration = dur;
    isPlaying = false;
  }
  
  void play(){
    isPlaying = true;
    startedAt = timeInSeconds();
    willEndAt = startedAt + duration;
    playingString = sceneNumber+ "("+duration+" sec) \n started:"+startedAt+"\n will end:"+willEndAt;
    println(playingString);
  }
    
  boolean isPassedHalf(){
    int passedTime = timeInSeconds() - parseInt(startedAt);
    return (passedTime > duration /2);
  }
  
  boolean hasEnded(){
    return timeInSeconds() >= willEndAt;
  }
  
  void end(){
    isPlaying = false;
    playingString = "ended " + sceneNumber+ "("+duration+" sec)";

  }
}
