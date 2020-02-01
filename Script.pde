class Script {
  int id;
  boolean isPlaying;
  Sequence[] sequences = new Sequence[120];
  Sequence playing = null;
  int lastProgressSent = -1;
  int pausedTime = 0;
  String token;
  String state = "idle";
  
  int minimalTimePlanned = 80 * 1000 * 1000;
  
  Script(Integer _id){
    id = _id;
  }
  
  
  void startSession(String _token){
    token = _token;
    state = "started";
  }
  
  void start (){
    if (playing == null) {
      Sequence n = getSequencePlaying(); 
      fetchNextSequence(id, n);
    } else {
      play(playing);
    }
  }
  
  
  Sequence getSequencePlaying(){
    Sequence playings = null;
    for(int i = 0; i < sequences.length; i++){
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
    sequences[index] = s;
    
    Sequence splaying = getSequencePlaying();
    if (splaying == null) {
      play(s);
    }
  }
  
  void play(Sequence s){
    if(s!=null){
      state = "playing";
      isPlaying = true;
      playing = s;
      s.play();
    }
  }
  
  String checkForSequence(){
    String resume = "";
    if(playing != null){
      if(isPlaying) {
        int currentProgress = playing.progress();
        if (currentProgress > lastProgressSent) {
          int nextProgress = getNextViableProgress();
          if (currentProgress >= nextProgress) {
            progressSequence(id, playing.id, playing.index, nextProgress);
            lastProgressSent = nextProgress;
          }
        }
        resume = playing.playingString;
        resume += "\n"+ playing.elapsedMiliseconds();
        int nextIndex = playing.index + 1;
        if(playing.isPassedHalf() ){
          resume += "\n passed half";
        }
        if(playing.duration() - playing.elapsedMiliseconds() < minimalTimePlanned/speed() && sequences[nextIndex] == null && lastRequestedIndex != nextIndex) {
           fetchNextSequence(id, playing);
        }
        if(playing.hasEnded()){
          lastProgressSent = -1;
          playing.end();
          //int nextIndex = playing.index +1;
          playing = null;
          play(sequences[nextIndex]);
        }
      } else {
        resume = "paused " + playing.playingString;
      }
    }
    return resume;
  }
  
  void pause(){
    if (playing!= null) {
      playing.pause();
      isPlaying = false;
      state = "paused";
    }
  }
  
  int getNextViableProgress () {
    int[] progressSteps = { 1, 25, 50, 75, 100 };
    int indexOfLasProgress = -1;
    for(int i =0; i< progressSteps.length; i++) {
      if (lastProgressSent == progressSteps[i]){
        indexOfLasProgress = i;
        break;
      }
    }
    
    return progressSteps[indexOfLasProgress +1];
  }
  
  void stop(){
    if(playing != null) {
      playing.end();
      println(playing.isPlaying);
      playing = null;
      state = "paused";
    }
  }
  
  void end(){
    this.stop();
    sequences = new Sequence[120];
    state = "finished";
  }
  
  void reset(){
    this.end();
    state = "idle";
    token = "";
  }
}
