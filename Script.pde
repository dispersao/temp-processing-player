class Script {
  int id;
  boolean isPlaying;
  Sequence[] sequences = new Sequence[120];
  Sequence playing = null;
  
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
    playPauseSequence(id, s.id, true);
    playing = s;
    s.play();
  }
  
  String checkForSequence(){
    String resume = "";
    if(playing != null) {
      resume = playing.playingString;
      if(playing.isPassedHalf() && sequences[playing.index + 1] == null){
        println("passed half");
        resume += "\n passed half";
        fetchNextSequence(id, playing);
      } 
      if(playing.hasEnded()){
        playing.end();
        play(sequences[playing.index +1]);
      }
    }
    return resume;
  }
  
  void stop(){
    if(playing != null) {
      playing.end();
    }
  }
}
