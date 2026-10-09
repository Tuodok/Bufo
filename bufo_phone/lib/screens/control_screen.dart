import 'package:bufo/communication/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../mixins/builder_mixin.dart';
import '../keyboard/keyboard.dart';
import 'package:bufo/communication/tcp_client.dart';


class ControlScreen extends StatefulWidget {
  final TcpClient serverClient;
  const new({super.key, required this.serverClient});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> with BuilderMixin{

  double tapPosX = 0;
  double tapPosY = 0;
  bool _toolbarEnabled = false;
  bool _keyboardEnabled = false;
  
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
  ]);
    super.initState();
  }

  @override
  void deactivate() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ]);
    super.deactivate();
  }

  
  void handleTap(TapDownDetails tapDpownDetails) {
      
    tapPosX = tapDpownDetails.localPosition.dx;
    tapPosY = tapDpownDetails.localPosition.dy;
    widget.serverClient.sendCommand(JsonMessage.tap(tapPosX, tapPosY));
  }
  
  void toolbarSwitch(){
    setState(() {
      _toolbarEnabled = _toolbarEnabled?false:true;
    });
  }
  void keyboardSwicth(){
    setState(() {
      _keyboardEnabled = _keyboardEnabled?false:true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (TapDownDetails details) => handleTap(details),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              toolbar(), 
              keyboard()
            ],
          ),
        ),
        
      ),
                                                                                                                                                                                                   
    );
  }


  Widget toolbar() {
    if(!_toolbarEnabled){
      return createIconButton(onPress: toolbarSwitch, icon: Icons.open_in_new);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        createIconButton(onPress: toolbarSwitch, icon: Icons.open_in_new),
        createIconButton(onPress: keyboardSwicth, icon: Icons.keyboard),
        //close connection to server
        createIconButton(onPress: widget.serverClient.closeConnection, icon: Icons.power_off),

      ],
    );
  }
  
  
  Expanded keyboard(){
    if(!_keyboardEnabled){return Expanded(child: Container());}

    return Expanded(
      child: Container(
        margin: EdgeInsets.fromLTRB(150, 230, 150, 50),
        child: Keyboard(serverClient: widget.serverClient),
      ),
    ); 
  }

  
}

 /*child: Container(
          margin: EdgeInsets.all(150.0),
          child: Keyboard(),
        ),*/