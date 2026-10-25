import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:isolate';
import 'tcp_client.dart';
import 'udp_client.dart';
import 'message.dart';

class NetworkManager{
  static const int _udpServerPortInfoEvent = 0;


  static final StreamController<Uint8List> _screenshotStreamController =
      StreamController<Uint8List>();

  static final TcpClient _tcpClient = TcpClient();
  static final UdpClient _udpClient = UdpClient();

  static Isolate? _udpSocketProcessorThread;

  static String? _connectionClosedMsg;
 
  static void Function(String)? _notifyDisconnectionCallback;

 

  static Stream<Uint8List> getScreenshotStream() => _screenshotStreamController.stream;


  static void setCallbackForConnectionClosure(void Function(String) callback){
    _notifyDisconnectionCallback = callback;
    if(_connectionClosedMsg != null){
      callback(_connectionClosedMsg!);
    }

  }

  static Future<String?> connectToServer({
    required InternetAddress serverIp, 
    required int serverPort
  }) async{
    
    return await _tcpClient.connectToServer(
      serverIP: serverIp,
      serverPort: serverPort,
      handleMsg: handleTcpMsg,
      handleConnectionClosedByServer: handleConnectionClosure
    );
  }
  static void closeConnection(){
    _tcpClient.closeConnection();
  }

  static void sendMessage(Message msg){
    _tcpClient.sendMessage(msg);
  }

  

  static void handleTcpMsg(Uint8List msg){
    ByteData msgByteData = ByteData.view(msg.buffer);
    int header = msgByteData.getUint8(0);
    if (header == _udpServerPortInfoEvent) {
     
      int port = msgByteData.getUint16(1);
      _launchUdpClient(port);
    }
  }

  static void handleConnectionClosure(){
    _udpClient.close();
    _screenshotStreamController.close();
    _screenshotStreamController.close();
    String msg = 'Connection closed by Server';
    _connectionClosedMsg = msg;
    _notifyDisconnectionCallback?.call(_connectionClosedMsg!);
  }

  static Future<void> _launchUdpClient(int serverPort) async {
    String? errorMsg = await _udpClient.launch(
      serverIp: _tcpClient.serverIp!, 
      serverPort: serverPort,
      addScreenshotToStream: _addToScreenshotStream,
    );
    if(errorMsg != null){
      handleConnectionClosure();
    }
    _launchUpdSocketProcessorThread();

  }

  static void _addToScreenshotStream(Uint8List screenshot){
    _screenshotStreamController.sink.add(screenshot);
  }

  static void _launchUpdSocketProcessorThread() async {
    if(_udpSocketProcessorThread != null){return;}
    _udpClient.hasControlOverSocketDataProcessing = false;
    ReceivePort receivePort = ReceivePort();
    _udpSocketProcessorThread = await Isolate.spawn(_udpClient.processSocketData, receivePort.sendPort);
    receivePort.listen(
      (dynamic screenshot){
        _addToScreenshotStream(screenshot);
      }
    );
  }
}