
class JsonMessage {

  String _jsonMessage = '';

  JsonMessage.screenSize(double width, double height){
    _jsonMessage = '{"screenSize": [$width, $height]}';
  }

  JsonMessage.keyPress(String eventValue){
    _jsonMessage = '{"keyPress": "$eventValue"}';
  }
  JsonMessage.tap(double posX, double posY){
    _jsonMessage = '{"tap": [$posX, $posY]}';
  }
  JsonMessage.write(String text){
    _jsonMessage = '{"write": "$text"}';
  }
  
  @override
  String toString() {
    return _jsonMessage;
  }
  

}