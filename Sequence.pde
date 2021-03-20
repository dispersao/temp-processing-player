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
      pausedTime += (timeInMiliseconds() - pausedAt);
      pausedAt = 0;
    } else {
      startedAt = timeInMiliseconds();
    }
    isPlaying = true;
    
    willEndAt = startedAt + duration() + pausedTime;
    playingString = sceneNumber+ " ("+duration+" sec) \n started: "+round(startedAt/1000)+"\n will end: "+round(willEndAt/1000);
    
    sceneState(id, index, "play", progress());
  }
  
  void pause(){
    isPlaying = false;
    pausedAt = timeInMiliseconds();
    playingString = sceneNumber+ " ("+duration+" sec) \n paused at: "+round(pausedAt/1000);
    sceneState(id, index, "pause", progress());
  }
    
  boolean isPassedHalf(){
    return this.progress() >= 50;
  }
  
  boolean hasEnded(){
    return this.progress() >= 100;
  }
  
  int progress() {
    int passedTime = timeInMiliseconds() - parseInt(startedAt) - pausedTime;
    return round((passedTime *100)/ duration());
  }
  
  int elapsedMiliseconds(){
    return timeInMiliseconds() - startedAt - pausedTime;
  }
  
  void end(){
    isPlaying = false;
    playingString = "ended " + sceneNumber+ "("+duration+" sec)";
    sceneState(id, index, "finished", progress());
    println("played "+sceneNumber+ " during "+elapsedMiliseconds());
  }
  
  int duration() {
    return round((duration/speed())*1000);
  }
  
  int remainingMiliseconds() {
    return this.duration() - this.elapsedMiliseconds();
  }
}
