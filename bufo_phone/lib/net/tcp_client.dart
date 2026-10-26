import 'dart:io';
import 'dart:typed_data';

import 'package:bufo/src/network/message.dart';
class TcpClient {

  String? _sourceIp;
  int? _port;
  Socket? _socket;

  final String _serverIp;
  final int _serverPort;

  final void Function(Uint8List) _onDataCallback;
  final void Function() _onConnectionDoneCallback;
  final void Function(String) _onErrorCallback;
  bool _internalSocketClosure = false;


  TcpClient({
    this._sourceIp,
    this._port,
    required this._serverIp,
    required this._serverPort,
    required this._onDataCallback,
    required this._onConnectionDoneCallback,
    required this._onErrorCallback
  });

  Future<String?> connectToServer() async {
    if(_socket != null){
      return 'Already connected';
    }
    _internalSocketClosure = false;

    try{
      _socket = await Socket.connect(_serverIp, _serverPort, );
      _socket!.listen(
        _onDataCallback,
        onDone: (){
          if(!_internalSocketClosure){
            closeConnection();
          }
        },
        onError: _onErrorCallback
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
    _socket?.close();
    _onConnectionDoneCallback();
    _socket = null;
  }
}