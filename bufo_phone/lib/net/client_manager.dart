
import 'dart:io';
import 'dart:typed_data';

import 'package:bufo/net/tcp_client.dart';
import 'package:bufo/net/udp_client.dart';

class ClientManager{
  static const  Map<String, TcpClient> _tcpClients = {};
  static const Map<String, UdpClient> _udpClients = {};

  static TcpClient createTcpClient({
    required String name,
    String? sourceIp,
    int? sourcePort,
    required String serverIp,
    required int serverPort,
    required void Function(Uint8List) onDataCallback,
    required void Function() onConnectionDoneCallback,
    required void Function(String) onErrorCallback
  }){
    _tcpClients[name] = TcpClient(
      sourceIp: sourceIp,
      sourcePort: sourcePort,
      serverIp: serverIp, 
      serverPort: serverPort, 
      onDataCallback: onDataCallback, 
      onConnectionDoneCallback: 
      onConnectionDoneCallback, 
      onErrorCallback: onErrorCallback
      );
      return _tcpClients[name]!;
  }
  static 
}