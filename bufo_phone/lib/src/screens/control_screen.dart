import 'package:bufo/src/communication/message.dart';
import 'package:bufo/src/communication/tcp_client.dart';
import 'package:bufo/src/communication/udp_screenshot_reception.dart';
import 'package:bufo/src/providers/provider.dart';
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
  
  String? _errorMsg;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    _launchUdpScreenshotReception();

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

  Future<void> _launchUdpScreenshotReception() async {
    TcpClient tcpClient = Provider.of(context).serverClient;
    UdpScreenshotReception udpScreenshotReception = Provider.of(context).udpScreenshotReception;
    String? errorMsg = await udpScreenshotReception.launch();
    if(errorMsg != null){
      setState(() {
        _errorMsg = 'Failed to launch Udp server error: $errorMsg';
      });
      return;
    }
    if(context.mounted){
      tcpClient.sendCommand(Message.udpPort(udpScreenshotReception.port));
    }
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
      Provider.of(context).serverClient.sendCommand(Message.screenSize(tapAreaWidth, tapAreaHeight));
      _tapAreaSent = true;
    }
    
    _tapPosX = tapDpownDetails.localPosition.dx;
    _tapPosY = tapDpownDetails.localPosition.dy;
    Provider.of(context).serverClient.sendCommand(Message.tap(_tapPosX, _tapPosY));
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
        child: _errorMsg != null
            ? Center(child: Text(_errorMsg!),)
            : Stack(
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
                  StreamBuilder<Uint8List>(
                    stream: Provider.of(context).udpScreenshotReception.readyScreenshotStream, 
                    builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot){
                      if(snapshot.connectionState == ConnectionState.waiting){
                        return Center(child: CircularProgressIndicator());
                      }
                      if(snapshot.hasData){
                        return Image.memory(
                          snapshot.data!,
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                          errorBuilder: (_,Object error,_){
                            return  Text('Failed to load JPEG error: ${error.toString()}');
                          } 
                        );
                      }
                      return Center(child: Text('KÄÄÄÄK!!'),);
                    }
                  )
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
          callback: Provider.of(context)
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








































