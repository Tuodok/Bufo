import 'package:bufo/communication/message.dart';
import 'package:bufo/widgets/custom_button.dart';
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

  
  void _handleTap(TapDownDetails tapDpownDetails) {
      
    //tapPosX = tapDpownDetails.localPosition.dx;
    //tapPosY = tapDpownDetails.localPosition.dy;
    //widget.serverClient.sendCommand(JsonMessage.tap(tapPosX, tapPosY));
  }
  
  void toolbarSwitch(){
    debugPrint('Toolbar');
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
          onTapDown: (TapDownDetails details) => _handleTap(details),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _toolbar(), 
              Expanded(
                child:Center(
                  child: _messenger()
                ) 
              ),
            ],
          ),
        ),
        
      ),
                                                                                                                                                                                                   
    );
  }


  Widget _toolbar() {
    List<CustomButton> toolbarButtons = [];
    toolbarButtons.add(
      CustomButton(
          callback: toolbarSwitch,
          buttonsChild: Icon(Icons.open_in_new),
          switchSetting: _toolbarEnabled ? SwitchSetting.on : SwitchSetting.off,
      ),
    );
    if(_toolbarEnabled){
      toolbarButtons.add(
        CustomButton(
          callback: keyboardSwicth,
          buttonsChild: Icon(Icons.keyboard),
          switchSetting: _keyboardEnabled ? SwitchSetting.on : SwitchSetting.off,
        ),
      );
      toolbarButtons.add(
        CustomButton(
          callback: widget.serverClient.closeConnection,
          buttonsChild: Icon(Icons.power_off),
          secondaryColor: Colors.red,
        )
      );
    }


    return Column(
      mainAxisSize: MainAxisSize.min,
      children: toolbarButtons,
    );
  }

  
  
  Widget _messenger(){
    if(!_keyboardEnabled){Container();}

    return Keyboard(serverClient: widget.serverClient); 
  }

  
}

