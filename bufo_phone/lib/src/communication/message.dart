
import 'dart:ffi';
import 'dart:typed_data';
import '../../bufo/bufo_event_types.dart';

class Message {

  Uint8List message;

  Message.screenSize(double width, double height)
    :message = Uint8List(1 + 8 + 8){
    ByteData data =  ByteData.view(message.buffer);
    data.setUint8(0, screenSizeEvent);
    data.setFloat64(1, width);
    data.setFloat64(1 + 8, height);

  }
  
  
  Message.keyPress(String key)
    :message = Uint8List(1 + key.length){
      ByteData data = ByteData.view(message.buffer);
      data.setUint8(0, keyPressEvent);
      for(int i = 0 ; i< key.length; i++){
        data.setUint8(byteOffset, value)
      }
    }
  Message.tap(double posX, double posY){
    _jsonMessage = '{"tap": [$posX, $posY]}';
  }
  Message.write(String text){
    _jsonMessage = '{"write": "$text"}';
  }
  
  @override
  String toString() {
    return _jsonMessage;
  }
  

}