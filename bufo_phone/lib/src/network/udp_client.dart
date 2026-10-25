
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:isolate';

import 'package:bufo/src/network/screenshot_assembler.dart';




class UdpClient {

  //frame id = unsigned 32, datagram index, count = unsigned 16
  static const int _headerSize = 8; 
  static const int _maxImgChunks = 4000;

  RawDatagramSocket? _socket;
  //InternetAddress? _ip;
  InternetAddress? _serverIp;
  int? _serverPort;


  ScreenshotAssembler? _screenshotAssembler;
  
  bool hasControlOverSocketDataProcessing = false;

  bool _running = false;
  bool _msgReceived = false;


 
  Future<String?> launch({
    required InternetAddress serverIp, 
    required int serverPort, 
    required void Function(Uint8List screenshot) addScreenshotToStream
  }) async {

    if(_running){return 'Already running';}
    _running = true;
    _serverIp = serverIp;
    _serverPort = serverPort;
    _screenshotAssembler = ScreenshotAssembler(addScreenshotToStream);
    try{
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      _socket!.listen(
        (RawSocketEvent event) async {
          if(event == RawSocketEvent.read){
            _msgReceived = true;
            
            if(hasControlOverSocketDataProcessing){
              processSocketData();
            }
            
          }
          
        },
        onError: (Object error){

        }

      );

      bool success = await _connectToUdpServer();
      if(!success)
      {
        return 'failed to connect to udp server';
      }

      return null;

    }catch(e){
      _running = false;
      return e.toString();
    }
   
    
  }

  Future<bool> _connectToUdpServer() async {
    int connectionMessagesSent = 0;
    while(!_msgReceived){
      if(connectionMessagesSent >= 10){
        break;
      }
      _socket!.send(utf8.encode('Hello'), _serverIp!, _serverPort!);
      connectionMessagesSent++;
      await Future.delayed(Duration(seconds: 1));
    }
    if(!_msgReceived){
      await Future.delayed(Duration(seconds: 5));
      return _msgReceived ? true : false;
    }
    
    return true;
  }

  void close(){
    _socket?.close();
    _reset();
  }

  void _reset(){
    _socket = null;
   // _ip = null;
    _serverIp = null;
    _serverPort = 0;
    _running = false;
    _msgReceived = false;
  }

  void processSocketData([SendPort? sendPort]) {
    Datagram? datagram;
    while((datagram = _socket!.receive()) != null){
      

      if(datagram!.data.length < _headerSize 
        || datagram.address != _serverIp){continue; }

      final ByteData header = ByteData.sublistView(datagram.data.sublist(0, _headerSize));
      final int screenshotId = header.getInt32(0);
      final int chunkIndex = header.getInt16(4);
      final int chunksInScreenshot = header.getInt16(6);
     
      
      Uint8List jpegChunk = datagram.data.sublist(_headerSize);

      if(chunksInScreenshot <= 0 || chunksInScreenshot > _maxImgChunks|| 
        chunkIndex > chunksInScreenshot){
          continue;
      }
      _screenshotAssembler!.processChunk(ScreenshotChunk(
          screenshotId: screenshotId, 
          jpegChunk: jpegChunk, 
          index: chunkIndex, 
          chunksInScreenshot: chunksInScreenshot
      ));



    }
  }

}
void s(){
  
}



 /*  Future<InternetAddress?> _getIp() async {
    List<NetworkInterface> interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );
    for (final NetworkInterface interface in interfaces) {
      for (InternetAddress address in interface.addresses) {
        RegExp regExp = RegExp(r'((\d{1,3}\.){3})');
        RegExpMatch? network = regExp.firstMatch(_serverIp!.address);
        if (network != null && address.address.startsWith(network[0]!)) {
          return address;
        }
      }
    }
    return null;
  }*/