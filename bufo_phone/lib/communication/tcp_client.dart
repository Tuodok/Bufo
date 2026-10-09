import 'dart:io';
import 'dart:typed_data';
import 'message.dart';

class TcpClient {

  final String _serverIP;
  final int _targetPort;
  Socket? _socket;
  bool _allowNewConnection = true;

  TcpClient(this._serverIP, this._targetPort);
 
  Future<(bool, String)> connectToServer() async {
     if(!_allowNewConnection){return (false,'Already connected');}
     _allowNewConnection = false;
     try {
      _socket = await Socket.connect(_serverIP, _targetPort);
      _socket?.listen(
        (Uint8List data){
          print(String.fromCharCodes(data).trim());
        },
        onDone: () {
          print('Connection closed by server');
          _socket?.destroy();
        },
        onError: (err){
          print('Error: $err');
        }
      );
      
      return (true,'');


     }catch(e){
        _allowNewConnection = true;
        return (false,'Failed to connect to server: $e');
     }
  }

  void sendCommand(JsonMessage message){
    _socket?.write(message);
  }

  void closeConnection(){
    _socket?.close();
    _socket?.destroy();
    _socket = null;
    _allowNewConnection = true;
  }
}