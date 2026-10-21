
import 'dart:io';
import 'dart:typed_data';

import 'package:bufo/src/communication/screenshot_assembler.dart';




class UdpScreenshotReception {

  //frame id = unsigned 32, datagram index, count = unsigned 16
  static const int headerSize = 8; 
  static const int maxImgSize = 8 * 1024 * 1024;
  static const int maxImgChunks = 7109;

  late final RawDatagramSocket _socket;
  final String _ip;
  final String _validSenderIp;

  final ScreenshotAssembler _screenshotAssembler = ScreenshotAssembler();
  
  bool _running = false;

  int get port => _socket.port;
  Stream<Uint8List> get readyScreenshotStream => _screenshotAssembler.screenshotStream;

  UdpScreenshotReception(this._ip, this._validSenderIp);

  Future<String?> launch() async {
    if(_running){return 'Already running';}
    _running = true;
    try{
      _socket = await RawDatagramSocket.bind(_ip, 0);

      _socket.listen(
        (RawSocketEvent event){
          if(event == RawSocketEvent.read){
            _receiveScreenshotChunks();
          }
          else if(event == RawSocketEvent.closed){
            
          }
        },
        onError: (Object error){

        }

       );
      return null;

    }catch(e){
      _running = false;
      return e.toString();
    }
   
    
  }

  void _receiveScreenshotChunks() {
    Datagram? datagram;
    while((datagram = _socket.receive()) != null){

      if(datagram!.data.length < headerSize 
        || datagram.address.address != _validSenderIp){ continue; }

      final ByteData header = ByteData.sublistView(datagram.data.sublist(0, headerSize));
      final int screenshotId = header.getInt32(0);
      final int chunksInScreenshot = header.getInt16(4);
      final int chunkIndex = header.getInt16(6);
      
      Uint8List jpegChunk = datagram.data.sublist(headerSize);

      if(chunksInScreenshot <= 0 || chunksInScreenshot > maxImgChunks|| 
        chunkIndex > chunksInScreenshot){
          continue;
      }
      _screenshotAssembler.processChunk(ScreenshotChunk(
          screenshotId: screenshotId, 
          jpegChunk: jpegChunk, 
          index: chunkIndex, 
          chunksInScreenshot: chunksInScreenshot
      ));



    }
  }
}