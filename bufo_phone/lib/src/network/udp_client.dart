import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bufo/src/network/screenshot_assembler.dart';

class UdpClient {


  final String? _sourceIp;
  final int? _sourcePort;
  RawDatagramSocket? _socket;


  late final ScreenshotAssembler _screenshotAssembler;

  final StreamController<Uint8List> _streamController =
      StreamController<Uint8List>();


  int isolateCount = 0;

  Stream<Uint8List> get screenshotStream => _streamController.stream;
  int? get port => _socket?.port;

  UdpClient({
    this._sourceIp,
    this._sourcePort,
  }){
    _screenshotAssembler = ScreenshotAssembler((Uint8List data) => _streamController.add(data));
  }

  Future<String?> launch() async{
    try{
      _socket = await RawDatagramSocket.bind(_sourceIp ?? InternetAddress.anyIPv4, _sourcePort ?? 0);
      _socket!.listen(
        (RawSocketEvent event) async {
          if(!_streamController.hasListener){return;}
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

