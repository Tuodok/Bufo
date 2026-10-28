import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bufo/src/network/message.dart';
import 'package:bufo/src/network/screenshot_assembler.dart';

class UdpClient {


  final String? _sourceIp;
  final int? _sourcePort;
  RawDatagramSocket? _socket;

  InternetAddress? _serverIp;
  int? _serverPort;


  late final ScreenshotAssembler _screenshotAssembler;


  Stream<Uint8List> get screenshotStream => _screenshotAssembler.screenshotStream.stream;
  int? get port => _socket?.port;

  UdpClient({
    this._sourceIp,
    this._sourcePort,
  }){
    _screenshotAssembler = ScreenshotAssembler();
  }

  Future<String?> launch() async{
    try{
      _socket = await RawDatagramSocket.bind(_sourceIp ?? InternetAddress.anyIPv4, _sourcePort ?? 0);
      _socket!.listen(
        (RawSocketEvent event) async {
          if(_serverIp ==null){ 
            Datagram? datagram = _socket!.receive();
            _serverIp = datagram!.address;
            _serverPort = datagram.port;
          }
          if(!_screenshotAssembler.screenshotStream.hasListener){return;}
          if(event == RawSocketEvent.read){
            _processSocketData();
          }
        }
      );
      return null;
    }catch(e){
      return e.toString();
    }
      
    
  }

  void send(Message msg){
    _socket?.send(msg.msg, _serverIp!, _serverPort!);
  }
  
  void close() {
    _socket?.close();
    _socket = null;
  }

  
  void _processSocketData(){
      Datagram? datagram;
      while((datagram = _socket!.receive())!= null){
        _screenshotAssembler.processScreenshotChunkData(datagram!.data);
      }
  }


}

