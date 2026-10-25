import 'package:bufo/src/network/message.dart';
import 'package:bufo/src/network/network_manager.dart';
import 'package:bufo/src/screens/connect_to_server_screen.dart';
import 'package:bufo/src/widgets/custom_buttons/dumb_button.dart';
import 'package:bufo/src/widgets/custom_buttons/normal_button.dart';
import 'package:bufo/src/widgets/typers/keyboard.dart';
import 'package:bufo/src/widgets/typers/type_writer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';



class ControlScreen extends StatefulWidget {
  const new({super.key,});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {


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
      final RenderBox renderBox = detectionContext.findRenderObject() as RenderBox;
      final double tapAreaWidth = renderBox.size.width;
      final double tapAreaHeight = renderBox.size.height;
      NetworkManager.sendMessage(context: context , msg: Message.screenSize(tapAreaWidth, tapAreaHeight));
      _tapAreaSent = true;
    }
    
    _tapPosX = tapDpownDetails.localPosition.dx;
    _tapPosY = tapDpownDetails.localPosition.dy;
    NetworkManager.sendMessage(context: context, msg: Message.tap(_tapPosX, _tapPosY));
  }

  void toolbarSwitch() {
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

  Future<void> _goBackToStartingScreen(int waitingTime) async {
    await Future.delayed(Duration(seconds: waitingTime));
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (BuildContext context) => ConnectToServerScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _body()
      ),
    );
  }
  
  Widget _body(){
    String? networkConnectionEndedMsg = NetworkManager.getConnectionEndedMsg(context);
    if(networkConnectionEndedMsg != null){
      _goBackToStartingScreen(10);
      return _connectionEndedDisplay(networkConnectionEndedMsg);
    }
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        _computerScreenDisplay(),
        _tapDetector(),
        _ui()
       
      ],
    );
             
  }

  StreamBuilder<Uint8List> _computerScreenDisplay(){
    return StreamBuilder<Uint8List>(
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
      }
    );
  }

  GestureDetector _tapDetector(){
    return GestureDetector(
      key: _detectorKey,
      behavior: HitTestBehavior.opaque,
      onTapDown: (TapDownDetails details) => _handleTap(details),
    );
  }

  Row _ui(){
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _toolbar(),
        Expanded(child: Center(child: _typer())),
      ],
    );
  }
  
  Container _connectionEndedDisplay(String informationMsg){
    return Container(
      color: Colors.red,
      child: Center(
        child: Text(informationMsg)
      ),
    );
  }

  Column _toolbar() {
    if(_toolbarEnabled){
      return Column(
        children: <Widget>[
          DumbButton(
            callback: toolbarSwitch,
            buttonsChild: Icon(Icons.open_in_new),
            color: _toolbarEnabled ? Colors.yellow : Colors.blue,
          ),
          DumbButton(
            callback: keyboardSwicth,
            buttonsChild: Icon(Icons.keyboard),
            color: _keyboardEnabled ? Colors.yellow : Colors.blue,
          ),
          DumbButton(
            callback: typeWriterSwitch,
            buttonsChild: Icon(Icons.text_increase),
            color: _typeWriterEnabled ? Colors.yellow : Colors.blue,
          ),
          SizedBox(height: 10),
          NormalButton(
            callback: () => NetworkManager.closeConnection(context),
            buttonsChild: Icon(Icons.power_off),
            secondaryColor: Colors.red,
          ),
        ],
      );
      
    }
    return Column(
      children: <Widget>[
        DumbButton(
          callback: toolbarSwitch,
          buttonsChild: Icon(Icons.open_in_new),
          color: _toolbarEnabled ? Colors.yellow : Colors.blue,
        ),
      ],
    );

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








































