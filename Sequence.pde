class Sequence { 
  int id;
  String sceneNumber;
  int duration;
  boolean isPlaying;
  int index;
  int startedAt;
  int willEndAt;
  String playingString;
  
  int pausedAt;
  int pausedTime = 0;
  
  
  Sequence(String scn, int _id, int dur) {
    id = _id;
    sceneNumber = scn;
    duration = dur;
    isPlaying = false;
  }
  
  void play(){
    if(pausedAt > 0){
      pausedTime += (timeInSeconds() - pausedAt);
      pausedAt = 0;
    } else {
      startedAt = timeInSeconds();
    }
    isPlaying = true;
    
    willEndAt = startedAt + duration + pausedTime;
    playingString = sceneNumber+ "("+duration+" sec) \n started:"+startedAt+"\n will end:"+willEndAt;
    println(playingString);
  }
  
  void pause(){
    isPlaying = false;
    pausedAt = timeInSeconds();
    playingString = sceneNumber+ "("+duration+" sec) \n paused at:"+pausedAt;
  }
    
  boolean isPassedHalf(){
    return this.progress() >= 50;
  }
  
  boolean hasEnded(){
    return this.progress() >= 100;
  }
  
  int progress() {
    int passedTime = timeInSeconds() - parseInt(startedAt) - pausedTime;
    println("passedTime " + passedTime+ "//"+parseInt(startedAt)+"//"+pausedTime);
    //println("progress:"+  round((passedTime *100)/ duration));
    return round((passedTime *100)/ duration);

  }
  
  void end(){
    isPlaying = false;
    playingString = "ended " + sceneNumber+ "("+duration+" sec)";

  }
}
