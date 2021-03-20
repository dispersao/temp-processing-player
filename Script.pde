class Script {
  int id;
  boolean isPlaying;
  Sequence[] sequences = new Sequence[120];
  Sequence playing = null;
  int lastProgressSent = -1;
  int pausedTime = 0;
  String token;
  String state = "idle";
  
  Clip clip;
  
  int minimalTimePlanned = 10 * 1000;
  
  Script(Integer _id){
    id = _id;
  }
  
  int maxGapUnplanned() {
    return minimalTimePlanned / speed();
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
      if( this.clip == null || this.clip.sequence != s){
        this.clip = new Clip(s);
      }
      state = "playing";
      isPlaying = true;
      playing = s;
      s.play();
      this.clip.play();
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
        this.shouldFetchSequence();
        
        if(playing.hasEnded()){
          lastProgressSent = -1;
          playing.end();
          playing = null;
          play(sequences[nextIndex]);
        }
        
        if (sequences[nextIndex] != null){
          resume += "\n\n next scene " + sequences[nextIndex].sceneNumber;
        }
      } else {
        resume = "paused " + playing.playingString;
      }
    }
    return resume;
  }
  
  void shouldFetchSequence(){
    int remainingTime = this.playing.remainingMiliseconds();
    
    Sequence lastFetchedSequence = playing;
    for(int i = playing.index + 1; i < sequences.length; i++){
      if(sequences[i] != null){
        lastFetchedSequence = sequences[i];
        remainingTime += lastFetchedSequence.duration();
      }
    }
    
    if(remainingTime < maxGapUnplanned() && !waitingFor(lastFetchedSequence.index + 1)){
      println("remainingTime: "+remainingTime+ " maxGapUnplanned: " +maxGapUnplanned()+ " lastRequestedIndex: "+ lastRequestedIndex);
      fetchNextSequence(id, lastFetchedSequence);
    }
  }
  
  void pause(){
    if (playing!= null) {
      playing.pause();
      isPlaying = false;
      state = "paused";
      this.clip.pause();
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
    if(this.clip != null){
      this.clip.stop();
    }
    this.clip = null;
  }
  
  void reset(){
    this.end();
    state = "idle";
    token = "";
     if(this.clip != null){
      this.clip.stop();
    }
    this.clip = null;
  }
  
    Movie getMovie(){
      if(this.clip != null && this.clip.movie != null){
        return this.clip.movie;
    } else {
      println("no movie for you!");
      return null;
    }
  }
}
