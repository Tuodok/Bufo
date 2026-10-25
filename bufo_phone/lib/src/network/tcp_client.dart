import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';

import 'message.dart';

class TcpClient {

  //Server Message Header Types:
  InternetAddress? _serverIP;

  Socket? _socket;
  bool _allowNewConnection = true;
  bool _internalSocketClosure = false;


  //_socket.address gives server address??????????????????????
  InternetAddress? get ip => _socket?.address;
  InternetAddress? get serverIp => _serverIP;

  


  Future<String?> connectToServer({
    required InternetAddress serverIP, 
    required int serverPort,
    required void Function(Uint8List) handleMsg,
    required void Function() handleConnectionClosedByServer
  }) async {

     if(!_allowNewConnection){return 'Already connected';}
     _allowNewConnection = false;

     try {
      debugPrint('test end');
      _socket = await Socket.connect(serverIP, serverPort);
      _serverIP = serverIP;
      serverPort;
      _socket!.listen(
        (Uint8List data){
          handleMsg(data);
        },
        onDone: () {
          if(!_internalSocketClosure){
            _reset();
            handleConnectionClosedByServer();
          }
         
        },
        onError: (err){
          
        }
      );
      
      return null;


     }catch(e){
        _allowNewConnection = true;
        return e.toString();
     }
  }

  void sendMessage(Message message){
    _socket?.add(message.msg);
  }

  void closeConnection(){
    _internalSocketClosure = true;
    _socket?.close();
    _reset();
  }

  void _reset(){
    _socket = null;
    _allowNewConnection = true;
    _serverIP = null;
  }

}