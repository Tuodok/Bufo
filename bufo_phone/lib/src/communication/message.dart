
import 'dart:typed_data';

const int screenSizeEvent = 0;
const int keyPressEvent = 1;
const int tapEvent = 2;
const int writeEvent = 3;
const int udpEvent = 4;

class Message {

  final Uint8List _msg;
  Uint8List get msg {return _msg;}

  Message.screenSize(double width, double height)
    :_msg = Uint8List(1 + 8 + 8){
      _doubleMessage(screenSizeEvent, width, height);
  }
  
  Message.keyPress(String key)
    :_msg = Uint8List(1 + key.length){
      _stringMessage(keyPressEvent, key);
  }
  Message.tap(double posX, double posY)
    :_msg = Uint8List(1 + 8 + 8){
      _doubleMessage(tapEvent, posX, posY);
  }
  
  Message.write(String text)
    :_msg = Uint8List(1 + text.length){
      _stringMessage(writeEvent, text);
  }
  Message.udpPort(int port)
    :_msg = Uint8List(1 + 2){
      ByteData data = ByteData.view(_msg.buffer);
      data.setUint8(0, udpEvent);
      data.setUint16(1, port);
    }
  
  void _doubleMessage(int eventType,double first, double second){
    ByteData data = ByteData.view(_msg.buffer);
    data.setUint8(0, eventType);
    data.setFloat64(1, first);
    data.setFloat64(1 + 8, second);
  }

  void _stringMessage(int eventType, String str){
    ByteData data = ByteData.view(_msg.buffer);
    data.setUint8(0, eventType);
    for (int i = 1; i < str.length; i++) {
      data.setUint8(i, str.codeUnitAt(i));
    }
  }
  

}