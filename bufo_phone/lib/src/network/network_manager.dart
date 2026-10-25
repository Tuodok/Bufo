import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:bufo/src/network/message.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:bufo/src/network/tcp_client.dart';
import 'package:bufo/src/network/udp_client.dart';



class NetworkManagerStateProvider extends StatefulWidget {
  final Widget child;
  const new({super.key, required this.child});

  @override
  State<NetworkManagerStateProvider> createState() => _NetworkManagerStateProviderState();
}

class _NetworkManagerStateProviderState extends State<NetworkManagerStateProvider> {

  String? _connectionClosedMsg;

  void _setConnectionClosedMsg(String msg){
    setState(() {
        _connectionClosedMsg = msg;
    });
  }

 

  @override
  Widget build(BuildContext context) {
    return NetworkManager(
      connectionClosedMsg: _connectionClosedMsg,
      setConnectionClosedMsg: _setConnectionClosedMsg,
      child: widget.child
    );
  }
}


class NetworkManager extends InheritedWidget{
  
  static const int _udpServerPortInfoEvent = 0;

  final StreamController<Uint8List> _screenshotStreamController = StreamController<Uint8List>();

  final TcpClient _tcpClient = TcpClient();
  final UdpClient _udpClient = UdpClient();

  Isolate? _udpSocketProcessorThread;

  final String? _connectionClosedMsg;
  final void Function(String) _setConnectionClosedMsg;
 

  NetworkManager({
    super.key, 
    this._connectionClosedMsg,
    required this._setConnectionClosedMsg,
    required super.child, 
  });

  @override
  bool updateShouldNotify(NetworkManager oldWidget){
    return oldWidget._connectionClosedMsg != _connectionClosedMsg;
  }
  

  static Stream<Uint8List> getScreenshotStream(BuildContext context)
     => _getContextsManager(context)._screenshotStreamController.stream;

  static String? getConnectionEndedMsg(BuildContext context){
    return _getContextsManager(context)._connectionClosedMsg;
  }

  static Future<String?> connectToServer({
    required BuildContext context, 
    required InternetAddress serverIp, 
    required int serverPort
  }) async{
    NetworkManager manager = _getContextsManager(context);
    return await manager._tcpClient.connectToServer(
      serverIP: serverIp,
      serverPort: serverPort,
      handleMsg: manager.handleTcpMsg,
      handleConnectionClosedByServer: manager.handleTcpConnectionClosure
    );
  }
  static void closeConnection(BuildContext context){
    
    _getContextsManager(context)._tcpClient.closeConnection();
  }

  static void sendMessage({required BuildContext context, required Message msg}){
    _getContextsManager(context)._tcpClient.sendMessage(msg);
  }

  static NetworkManager _getContextsManager(BuildContext context){
    return context.dependOnInheritedWidgetOfExactType<NetworkManager>() as NetworkManager;
  }

  void handleTcpMsg(Uint8List msg){
    ByteData msgByteData = ByteData.view(msg.buffer);
    int header = msgByteData.getUint8(0);
    if (header == _udpServerPortInfoEvent) {
     
      int port = msgByteData.getUint16(1);
      _launchUdpClient(port);
    }
  }

  void handleTcpConnectionClosure(){
    _udpClient.close();
    _screenshotStreamController.close();
    _screenshotStreamController.close();
    String msg = 'Connection closed by Server';
    _setConnectionClosedMsg(msg);
  }

  Future<void> _launchUdpClient(int serverPort) async {
    String? errorMsg = await _udpClient.launch(
      serverIp: _tcpClient.serverIp!, 
      serverPort: serverPort,
      addScreenshotToStream: _addToScreenshotStream,
    );
    if(errorMsg != null){
      _tcpClient.closeConnection();
      _udpClient.close();
      _screenshotStreamController.close();
      _setConnectionClosedMsg(errorMsg);

    }
    _launchUpdSocketProcessorThread();

  }

  void _addToScreenshotStream(Uint8List screenshot){
    _screenshotStreamController.sink.add(screenshot);
  }

  void _launchUpdSocketProcessorThread() async {
    if(_udpSocketProcessorThread != null){return;}
    _udpClient.hasControlOverSocketDataProcessing = true;
    ReceivePort receivePort = ReceivePort();
    _udpSocketProcessorThread = await Isolate.spawn(_udpClient.processSocketData, receivePort.sendPort);
    receivePort.listen(
      (dynamic screenshot){
        _addToScreenshotStream(screenshot);
      }
    );
  }

}