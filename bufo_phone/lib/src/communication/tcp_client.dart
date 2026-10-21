import 'dart:io';
import 'dart:typed_data';
import 'message.dart';

class TcpClient {

  final String _serverIP;
  final int _serverPort;
  late final Socket _socket;
  bool _allowNewConnection = true;

  String get ip => _socket.address.address;
  String get serverIp => _serverIP;

  TcpClient(this._serverIP, this._serverPort);
 
  Future<(bool, String)> connectToServer() async {
     if(!_allowNewConnection){return (false,'Already connected');}
     _allowNewConnection = false;
     try {
      _socket = await Socket.connect(_serverIP, _serverPort);
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