import 'package:bufo/src/communication/message.dart';
import 'package:bufo/src/providers/server_client_provider.dart';
import 'package:bufo/src/widgets/custom_buttons/dumb_switch_button.dart';
import 'package:bufo/src/widgets/custom_buttons/normal_button.dart';
import 'package:bufo/src/widgets/typers/keyboard.dart';
import 'package:bufo/src/widgets/typers/type_writer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../mixins/builder_mixin.dart';


class ControlScreen extends StatefulWidget {
  const new({super.key,});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> with BuilderMixin {

  final GlobalKey _detectorKey = GlobalKey();
  bool _tapAreaSent = false;
  double _tapPosX = 0;
  double _tapPosY = 0;
  bool _toolbarEnabled = false;
  bool _keyboardEnabled = false;
  bool _typeWriterEnabled = false;

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
      DeviceOrientation.landscapeLeft,
    ]);
    super.deactivate();
  }

  void _handleTap(TapDownDetails tapDpownDetails) {
    if(!_tapAreaSent){
      final BuildContext? detectionContext  = _detectorKey.currentContext;
      if(detectionContext == null){
        return;
      }
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final double tapAreaWidth = renderBox.size.width;
      final double tapAreaHeight = renderBox.size.height;
      ServerClientProvider.of(context).serverClient.sendCommand(Message.screenSize(tapAreaWidth, tapAreaHeight));
      _tapAreaSent = true;
    }
    
    _tapPosX = tapDpownDetails.localPosition.dx;
    _tapPosY = tapDpownDetails.localPosition.dy;
    ServerClientProvider.of(context).serverClient.sendCommand(Message.tap(_tapPosX, _tapPosY));
  }

  void toolbarSwitch() {
    debugPrint('Toolbar');
    setState(() {
      _toolbarEnabled = _toolbarEnabled ? false : true;
    });
  }

  void keyboardSwicth() {
    setState(() {
      _keyboardEnabled = _keyboardEnabled ? false : true;
      _typeWriterEnabled =false;
    });
  }
  void typeWriterSwitch(){
    setState(() {
      _typeWriterEnabled = _typeWriterEnabled ? false : true;
      _keyboardEnabled = false;
    });
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            GestureDetector(
              key: _detectorKey,
              behavior: HitTestBehavior.opaque,
              onTapDown: (TapDownDetails details) => _handleTap(details),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _toolbar(),
                Expanded(
                  child: Center(
                    child: _typer()
                  )
                ),
              ],
            ),
          ] 
        ),
      ),
    );
  }

  Widget _toolbar() {
    List<Widget> toolbarButtons = [];
    toolbarButtons.add(
      DumbSwitchButton(
        callback: toolbarSwitch,
        buttonsChild: Icon(Icons.open_in_new),
        isOn: _toolbarEnabled,
      ),
    );
    if (_toolbarEnabled) {
      toolbarButtons.add(
        DumbSwitchButton(
          callback: keyboardSwicth,
          buttonsChild: Icon(Icons.keyboard),
          isOn: _keyboardEnabled
        ),
      );
      toolbarButtons.add(
        DumbSwitchButton(
          callback: typeWriterSwitch,
          buttonsChild: Icon(Icons.text_fields),
          isOn: _typeWriterEnabled,
        ),
    );

      toolbarButtons.add(
        NormalButton(
          callback: ServerClientProvider.of(context)
              .serverClient.closeConnection,
          buttonsChild: Icon(Icons.power_off),
          secondaryColor: Colors.red,
        ),
      );
    }

    return Column(mainAxisSize: MainAxisSize.min, children: toolbarButtons);
  }

  Widget? _typer() {
    if (_keyboardEnabled) {
      return Keyboard();
    }
    else if(_typeWriterEnabled){
      return TypeWriter();
    }
    return null;
    
  }
}










































/*import 'package:bufo/src/blocks/switch_block.dart';
import 'package:bufo/src/communication/message.dart';
import 'package:bufo/src/providers/server_client_provider.dart';
import 'package:bufo/src/widgets/custom_buttons/base_button.dart';
import 'package:bufo/src/widgets/custom_buttons/normal_button.dart';
import 'package:bufo/src/widgets/custom_buttons/switch_button.dart';
import 'package:bufo/src/widgets/typers/type_writer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../mixins/builder_mixin.dart';
import '../widgets/typers/keyboard.dart';
import 'package:bufo/src/communication/tcp_client.dart';


class ControlScreen extends StatefulWidget {

  const new({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();


}

class _ControlScreenState extends State<ControlScreen> with BuilderMixin{


  final SwitchBlock _toolbarSwitchBlock = SwitchBlock();
  final SwitchBlock _keyboardSwitchBlock = SwitchBlock();
  final SwitchBlock _typeWriterSwitchBlock = SwitchBlock();
 

  double tapPosX = 0;
  double tapPosY = 0;


  
  @override
  void initState() {


    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

  

    super.initState();
  }

 /* @override
  void didChangeDependencies() {

    super.didChangeDependencies();
  }*/

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
    //ServerClientProvider.of(context).serverClient.sendCommand(JsonMessage.tap(tapPosX, tapPosY));
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
                  child: _displayActiveTyper()
                ) 
              ),
            ],
          ),
        ),
      ),
    );
  }


  StreamBuilder _toolbar() {

    return StreamBuilder<bool>(
        stream: _toolbarSwitchBlock.stream,
        builder: (context, snapshot) {
          if(!snapshot.hasData || !snapshot.data!){
            return  SwitchButton.block(
              switchBlock: _toolbarSwitchBlock,
              buttonsChild: Icon(Icons.open_in_new),
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <BaseButton>[
              SwitchButton.block(
                switchBlock: _toolbarSwitchBlock,
                buttonsChild: Icon(Icons.open_in_new),
              ),
              SwitchButton.block(
                switchBlock: _keyboardSwitchBlock,
                buttonsChild: Icon(Icons.keyboard),
              ),
              SwitchButton.block(
                switchBlock: _typeWriterSwitchBlock,
                buttonsChild: Icon(Icons.short_text),
              ),

            ],
          );

        },
    );
  }

  StreamBuilder<bool> _displayActiveTyper(){
     return StreamBuilder<bool>(
      stream: _keyboardSwitchBlock.stream,
      builder: (context, keyboardSwitchSnap){
        return StreamBuilder<bool>(
          stream: _typeWriterSwitchBlock.stream, 
          builder: (context, typeWriterSwitchSnap){
            if(keyboardSwitchSnap.hasData && keyboardSwitchSnap.data!){
              if(_typeWriterSwitchBlock.isOn){
                _typeWriterSwitchBlock.toggle();
              }
              return Keyboard();
            }
            else if(typeWriterSwitchSnap.hasData && typeWriterSwitchSnap.data!){
              if(_keyboardSwitchBlock.isOn){
                _keyboardSwitchBlock.toggle();
              }
              return TypeWriter();
            }
            return Container();
          }
        );
      }
    );
  }
  


  
}
*/
