import 'package:bufo/src/communication/tcp_client.dart';
import 'package:flutter/material.dart';

class ServerClientProvider extends InheritedWidget{

  final TcpClient serverClient;

  const ServerClientProvider({super.key, required super.child, required this.serverClient});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }

  static ServerClientProvider of(BuildContext context){
    return context.dependOnInheritedWidgetOfExactType<ServerClientProvider>() as ServerClientProvider;
  }
  

}