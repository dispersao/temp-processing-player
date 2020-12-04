import processing.video.*;

class Clip {
  Movie movie = null;
  String file;
  String sequencesFolder =  "sequences/";
  int volume = 1;
  Sequence sequence;
  
  Clip(Sequence seq) {
    this.sequence = seq;
    this.file = sequencesFolder + formatFileName(this.sequence.sceneNumber) + ".mov";
    this.movie = new Movie(applet, this.file);
  }
  
  void play() {
    this.movie.play();
  }
  
  void pause() {
    this.movie.pause();
  }
  
  void stop() {
    this.movie.stop();
  }
  
  void toggleMute() {
    if(this.volume > 0) {
      this.volume = 0;
    } else {
      this.volume = 1;
    }
    this.movie.volume(this.volume);
  }
  
  
  String formatFileName(String sceneString) {
    String formattedFileName = "";
    String numbersOnly =  "";
    String lettersOnly =  "";
    for (int i=0; i<sceneString.length(); i++){
      if (sceneString.charAt(i)>='0' && sceneString.charAt(i)<='9') {
        numbersOnly = numbersOnly + sceneString.charAt(i);
      } else {
        lettersOnly = lettersOnly + sceneString.charAt(i);
      }
    }
    formattedFileName = nf(Integer.valueOf(numbersOnly), 3);
    formattedFileName = formattedFileName + lettersOnly;
    
    return formattedFileName; 
  }
}
