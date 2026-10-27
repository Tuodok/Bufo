
import 'dart:typed_data';




class Message {

  static const int _screenSizeEvent = 10;
  static const int _keyPressEvent = 11;
  static const int _tapEvent = 12;
  static const int _writeEvent = 13;
  static const int _udpPortInfoEvent = 14;
  static const int _zoomEvent = 15;
  static const int _cancelZoomEvent = 16;

  final Uint8List _msg;
  Uint8List get msg => _msg;

  Message.screenSize(double width, double height)
    :_msg = Uint8List(1 + 8 + 8){
      _doubleMessage(_screenSizeEvent, width, height);
  }
  
  Message.keyPress(String key)
    :_msg = Uint8List(1 + key.length){
      _stringMessage(_keyPressEvent, key);
  }
  Message.tap(double posX, double posY)
    :_msg = Uint8List(1 + 8 + 8){
      _doubleMessage(_tapEvent, posX, posY);
  }
  
  Message.write(String text)
    :_msg = Uint8List(1 + text.length){
      _stringMessage(_writeEvent, text);
  }

  Message.udp(int port)
    :_msg = Uint8List(1 + 2){
      ByteData data = ByteData.view(_msg.buffer);
      data.setUint8(0, _udpPortInfoEvent);
      data.setUint16(1, port);
    }

  Message.zoom()
    :_msg = Uint8List(1){
      _msg[0] = _zoomEvent;
    }
  Message.unzoom()
  :_msg= Uint8List(1){
    _msg[0] = _cancelZoomEvent;
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
    for (int i = 0; i < str.length; i++) {
      data.setUint8(1 + i, str.codeUnitAt(i));
    }
  }
  

}