import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';

import 'message.dart';

class TcpClient {

  final InternetAddress _serverIP;
  final int _serverPort;
  late final Socket _socket;
  bool _allowNewConnection = true;

  //_socket.address gives server address??????????????????????
  InternetAddress get ip => _socket.address;
  InternetAddress get serverIp => _serverIP;

  TcpClient(this._serverIP, this._serverPort);

  Future<(bool, String)> connectToServer() async {
     if(!_allowNewConnection){return (false,'Already connected');}
     _allowNewConnection = false;
     try {
      debugPrint('test end');
      _socket = await Socket.connect(_serverIP, _serverPort, sourceAddress: '10.64.78.247');
      
      _socket.listen(
        (Uint8List data){
        },
        onDone: () {
          _socket.destroy();
        },
        onError: (err){
        }
      );
      
      return (true,'');


     }catch(e){
        _allowNewConnection = true;
        return (false, e.toString());
     }
  }

  void sendCommand(Message message){
    _socket.add(message.msg);
  }

  void closeConnection(){
    _socket.close();
    _socket.destroy();
  }
}