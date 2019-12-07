class Script {
  int id;
  boolean isPlaying;
  Sequence[] sequences = new Sequence[120];
  Sequence playing = null;
  int lastProgressSent = -1;
  boolean paused = false;
  int pausedTime = 0;
  
  Script(Integer _id){
    println(_id);
    id = _id;
  }
  
  void start (){
    Sequence n = getSequencePlaying();
    fetchNextSequence(id, n);
  }
  
  Sequence getSequencePlaying(){
    Sequence playings = null;
    for(int i =0; i < sequences.length; i++){
      Sequence s = sequences[i];
      if(s!= null && s.isPlaying){
        playings = s;
        break;
      }
    }
    return playings;
  }
  
  void addScene(int sceneId, String sceneNumber, int duration, int index) {
    Sequence s = new Sequence(sceneNumber, sceneId, duration);
    s.index = index;
    println(sequences.length);

    sequences[index] = s;
    
    Sequence splaying = getSequencePlaying();
    if (splaying == null) {
      play(s);
    }
  }
  
  void play(Sequence s){
    //playPauseSequence(id, s.id, true);
    if(s!=null){
      playing = s;
      s.play();
    }
  }
  
  String checkForSequence(){
    String resume = "";
    if(playing != null) {
      int currentProgress = playing.progress();
      if (currentProgress != lastProgressSent) {
        progressSequence(id, playing.id, playing.index, currentProgress);
        lastProgressSent = currentProgress;
      }
      resume = playing.playingString;
      if(playing.isPassedHalf() && sequences[playing.index + 1] == null){
        println("passed half");
        resume += "\n passed half";
        fetchNextSequence(id, playing);
      } 
      if(playing.hasEnded()){
        lastProgressSent = -1;
        playing.end();
        play(sequences[playing.index +1]);
      }
    }
    return resume;
  }
  
  void pause(){
    if (playing!= null) {
      playing.pause();
      this.paused = true;
      this.pausedTime = timeInSeconds();
    }
  }
  
  void stop(){
    if(playing != null) {
      playing.end();
    }
  }
}
