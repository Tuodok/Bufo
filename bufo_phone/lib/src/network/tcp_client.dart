import 'dart:io';
import 'dart:typed_data';

import 'package:bufo/src/network/message.dart';
class TcpClient {

  void Function(String msg)? onConnectionDoneCallback;


  Socket? _socket;

  final String _serverIp;
  final int _serverPort;

  String? _disconnectionMsg;

  bool _internalSocketClosure = false;
  
  String? get disconnectionMsg => _disconnectionMsg;


  TcpClient({
    required this._serverIp,
    required this._serverPort,
  });

  Future<String?> connectToServer() async {
    if(_socket != null){
      return 'Already connected';
    }

    try{
      _socket = await Socket.connect(_serverIp, _serverPort, );
      _socket!.listen(
        (Uint8List data){
          
        },
        onDone: (){
          if(_internalSocketClosure){return;}
          _closeConnection('Connection closed by server');
        },
        onError: (e){
          _closeConnection('Connection closed with error: ${e.toString()}');
        }
      );
      return null;
    
    }catch(e){
      return e.toString();
    }
    

  }
  void sendMessage(Message msg){
    _socket?.add(msg.msg);
  }

  void closeConnection(){
    _internalSocketClosure = true;
    onConnectionDoneCallback?.call('Connection Closed');
    _socket?.close();
    _socket = null;
  }

  void _closeConnection(String infoMsg){
    onConnectionDoneCallback?.call(infoMsg);
    _socket?.close();
    _socket = null;
  }
}