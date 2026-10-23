import 'package:bufo/src/network/message.dart';
import 'package:bufo/src/network/network_manager.dart';
import 'package:bufo/src/screens/connect_to_server_screen.dart';
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
      NetworkManager.sendMessage(context: context , msg: Message.screenSize(tapAreaWidth, tapAreaHeight));
      _tapAreaSent = true;
    }
    
    _tapPosX = tapDpownDetails.localPosition.dx;
    _tapPosY = tapDpownDetails.localPosition.dy;
    NetworkManager.sendMessage(context: context, msg: Message.tap(_tapPosX, _tapPosY));
  }

  void _toolbarSwitch() {
    setState(() {
      _toolbarEnabled = _toolbarEnabled ? false : true;
    });
  }

  void _keyboardSwicth() {
    setState(() {
      _keyboardEnabled = _keyboardEnabled ? false : true;
      _typeWriterEnabled =false;
    });
  }
  void _typeWriterSwitch(){
    setState(() {
      _typeWriterEnabled = _typeWriterEnabled ? false : true;
      _keyboardEnabled = false;
    });
  }

  Future<void> _changeScreen(Widget screen, int waitingTime) async {
    await Future.delayed(Duration(seconds: waitingTime));
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (BuildContext context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _screen()
      ),
    );
  }
  
  Widget _screen(){
    String? networkConnectionEndedMsg = NetworkManager.getConnectionEndedMsg(context);
    if(networkConnectionEndedMsg != null){
      _changeScreen(ConnectToServerScreen(), 10);
      return Container(
        color: Colors.red,
        child: Center(
          child: Text(networkConnectionEndedMsg)
        ),
      );

    }
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        StreamBuilder<Uint8List>(
          stream: NetworkManager.getScreenshotStream(context),
          builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              return Image.memory(
                snapshot.data!,
                fit: BoxFit.fill,
                gaplessPlayback: true,
                errorBuilder: (_, Object error, _) {
                  return Text('Failed to load JPEG error: ${error.toString()}');
                },
              );
            }
            return Center(child: Text('KÄÄÄÄK!!'));
          },
        ),
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
            Expanded(child: Center(child: _typer())),
          ],
        ),
       
      ],
    );
             
  }

  Column _toolbar() {
    List<Widget> toolbarButtons = [];
    toolbarButtons.add(
      DumbSwitchButton(
        callback: _toolbarSwitch,
        buttonsChild: Icon(Icons.open_in_new),
        isOn: _toolbarEnabled,
      ),
    );
    if (_toolbarEnabled) {
      toolbarButtons.add(
        DumbSwitchButton(
          callback: _keyboardSwicth,
          buttonsChild: Icon(Icons.keyboard),
          isOn: _keyboardEnabled
        ),
      );
      toolbarButtons.add(
        DumbSwitchButton(
          callback: _typeWriterSwitch,
          buttonsChild: Icon(Icons.text_fields),
          isOn: _typeWriterEnabled,
        ),
    );

      toolbarButtons.add(
        NormalButton(
          callback: () => NetworkManager.closeConnection(context),
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








































