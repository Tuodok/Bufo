import 'package:bufo/src/communication/tcp_client.dart';
import 'package:bufo/src/communication/udp_screenshot_reception.dart';
import 'package:flutter/material.dart';

class Provider extends InheritedWidget{

  final TcpClient serverClient;
  final UdpScreenshotReception udpScreenshotReception;


  const Provider({super.key, required super.child, required this.serverClient, required this.udpScreenshotReception});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }

  static Provider of(BuildContext context){
    return context.dependOnInheritedWidgetOfExactType<Provider>() as Provider;
  }
  

}