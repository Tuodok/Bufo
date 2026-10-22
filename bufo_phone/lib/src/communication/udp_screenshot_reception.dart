
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:nativewrappers/_internal/vm/bin/vmservice_io.dart';
import 'dart:typed_data';

import 'package:bufo/src/communication/screenshot_assembler.dart';
import 'package:flutter/material.dart';




class UdpScreenshotReception {

  //frame id = unsigned 32, datagram index, count = unsigned 16
  static const int headerSize = 8; 
  static const int maxImgSize = 8 * 1024 * 1024;
  static const int maxImgChunks = 7109;

  late final RawDatagramSocket _socket;
  late final InternetAddress _ip;
  final InternetAddress _serverIp;
  final int _serverPort;

  final ScreenshotAssembler _screenshotAssembler = ScreenshotAssembler();
  
  bool _running = false;
  bool _socketClosed = false;

  int get port => _socket.port;
  Stream<Uint8List> get readyScreenshotStream => _screenshotAssembler.screenshotStream;

  UdpScreenshotReception({required this._serverIp, required this._serverPort});

  Future<String?> launch() async {
    if(_running){return 'Already running';}

    _running = true;
    try{
      
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      bool responseReceived = false;
      
      
      _socket.listen(
        (RawSocketEvent event){
          if(event == RawSocketEvent.read){
            responseReceived = true;
            _receiveScreenshotChunks();
          }
          else if(event == RawSocketEvent.closed){
            _socketClosed = true;
          }
        },
        onError: (Object error){

        }

      );


      bool success = await _connectToUdpServer(responseReceived);
      if(!success){return 'failed to connect to udp server';}

      return null;

    }catch(e){
      _running = false;
      return e.toString();
    }
   
    
  }

  Future<bool> _connectToUdpServer(bool responseReceived) async {
     int connectionMessagesSent = 0;
    while(!responseReceived || !_socketClosed){
      if(connectionMessagesSent > 10){
        return false;
      }
      _socket.send(utf8.encode('Hello'), _serverIp, _serverPort);
      await Future.delayed(Duration(seconds: 1));
    }
    if(_socketClosed){return false;}
    return true;
  }

  void close(){
    _socket.close();
  }



  Future<InternetAddress?> _getIp() async {
    List<NetworkInterface> interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );
    for (final NetworkInterface interface in interfaces) {
      for(InternetAddress address in interface.addresses){
        RegExp regExp = RegExp(r'((\d{1,3}\.){3})');
        RegExpMatch? network = regExp.firstMatch(_serverIp.address);
        if(network != null && address.address.startsWith(network[0]!)){
          return address;
        }
      }
    }
    return null;
  }

  void _receiveScreenshotChunks() {
    Datagram? datagram;
    while((datagram = _socket.receive()) != null){

      if(datagram!.data.length < headerSize 
        || datagram.address != _serverIp){ continue; }

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