import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

class UdpClient {
  final String? _sourceIp;
  final int? _sourcePort;
  String _serverIp;
  int _serverPort;

  final void Function(Uint8List) _recvDataCallback;
  bool useIsolateForProcessingIncomingData = false;
  Isolate? _socketDataProcessorThread;
  final ReceivePort? _receivePort;
  RawDatagramSocket? _socket;
  StreamSubscription<RawSocketEvent>? _socketListener;

  UdpClient({
    this._sourceIp,
    this._sourcePort,
    required this._serverIp,
    required this._serverPort,
    required this._recvDataCallback,
    this._receivePort,
  });

  Future<String?> launch() async{
    _socket = await RawDatagramSocket.bind(_ip ?? InternetAddress.anyIPv4, _port ?? 0);
    _socketListener = _createSocketListener();
  }
  
  StreamSubscription<RawSocketEvent> _createSocketListener(){
    return  _socket!.listen(
      (RawSocketEvent event) async {
        if(event == RawSocketEvent.read){
          if(useIsolateForProcessingIncomingData){
            _socketListener!.cancel();
            _socketDataProcessorThread = await Isolate.spawn(_readSocketData, _receivePort!.sendPort);
            _socketListener = null;
          }
          _readSocketData();
        }
      }
    );
  }
  
  void _readSocketData([SendPort? sendPort]){
    Datagram? datagram;
    while((datagram = _socket!.receive())!= null){
      _recvDataCallback(datagram!.data);
    }
    _socketListener = _createSocketListener();
  }

}