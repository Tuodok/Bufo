import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:isolate';
import 'tcp_client.dart';
import 'udp_client.dart';
import 'message.dart';

enum ScreenCastMode{
  loop,
  onUserEvent,
  paused
}

class NetworkManager{
  static const int _udpServerPortInfoEvent = 0;


  static final StreamController<Uint8List> _screenshotStreamController = StreamController<Uint8List>();

  static final TcpClient _tcpClient = TcpClient();
  static final UdpScreenshotRecetpion _udpReception = UdpScreenshotRecetpion();

  static ScreenCastMode _screenCastMode = ScreenCastMode.loop;

  static Isolate? _udpSocketProcessorThread;

  static String? _connectionClosedMsg;
 
  static void Function(String)? _notifyDisconnectionCallback;

 

  static Stream<Uint8List> get screenshotStream => _screenshotStreamController.stream;


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
    
    String? errorMsg = await _tcpClient.connectToServer(
      serverIP: serverIp,
      serverPort: serverPort,
      handleMsg: _handleTcpMsg,
      disconnectionCallback: closeConnection
    );
    if(errorMsg == null){
      String? errMsg = await _launchUdpReception();
      if(errMsg != null){
        sendMessage(Message.udp(_udpReception.port));
        return null;
      }
      closeConnection();
      _connectionClosedMsg = errMsg;
      return errMsg;
    }
    closeConnection();
    _connectionClosedMsg = errorMsg;
    return errorMsg;
  }
  

  static void sendMessage(Message msg){
    _tcpClient.sendMessage(msg);
  }

 


  static void closeConnection(){
    if(_udpSocketProcessorThread != null){
      _udpSocketProcessorThread!.kill(priority: Isolate.immediate);
    }
    _udpReception.close();
    _screenshotStreamController.close();
    _screenshotStreamController.close();
    String msg = 'Connection closed by Server';
    _connectionClosedMsg = msg;
    _notifyDisconnectionCallback?.call(_connectionClosedMsg!);
    _udpSocketProcessorThread = null;
  }

  static void _handleTcpMsg(Uint8List msg) {
   
   
  }
  static void _handleActivationOfUdpSocket() {
    if (_screenCastMode == ScreenCastMode.loop) {
      _udpReception.hasControlOverSocketDataProcessing = false;
      _launchUpdSocketProcessorThread();
    }
  }

  static Future<String?> _launchUdpReception() async {
    if(_screenCastMode == ScreenCastMode.loop){
      _udpReception.hasControlOverSocketDataProcessing = false;
    }
    return await _udpReception.launch(
      firstDatagramCallback: _handleActivationOfUdpSocket,
      addScreenshotToStream: (Uint8List screenshot){
        _screenshotStreamController.sink.add(screenshot);
      },
    );
  }

  static void _launchUpdSocketProcessorThread() async {
    if(_udpSocketProcessorThread != null){return;}
    print('creating thread');
    ReceivePort receivePort = ReceivePort();
    _udpSocketProcessorThread = await Isolate.spawn(_udpReception.processSocketData, receivePort.sendPort);
    receivePort.listen(
      (dynamic screenshot){
        _screenshotStreamController.sink.add(screenshot);
      }
    );
  }
}