import 'package:flutter/material.dart';
import 'control_screen.dart';
import '../mixins/builder_mixin.dart';
import '../communication/tcp_client.dart';

enum ConnectionStatus { connecting, failed, waiting }

class ConnectToServerScreen extends StatefulWidget {

  const new({super.key});

  @override
  State<ConnectToServerScreen> createState() => _ConnectToServerScreenState();
}

class _ConnectToServerScreenState extends State<ConnectToServerScreen> with BuilderMixin  {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _ipAddress;
  String? _portNumber;
  ConnectionStatus _connectionStatus = ConnectionStatus.waiting;
  String _errorMessage = '';
 
  
  void handleSubmit() async {
    if(_formKey.currentState == null||!_formKey.currentState!.validate()){
      return;
    }
    _formKey.currentState?.save();

    setState(() {
      _connectionStatus = ConnectionStatus.connecting;
    });

    TcpClient client = TcpClient(_ipAddress!, int.parse(_portNumber!));
    var (bool succes, String msg) = await client.connectToServer();
    if(!succes){
      failedToConnectToServer(msg);
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => ControlScreen(serverClient: client),
      ),
    );
  }

  void failedToConnectToServer(String msg) async{
     setState(() {
      _connectionStatus = ConnectionStatus.failed;
      _errorMessage = msg;
    });
    await Future.delayed(Duration(seconds: 10));
    setState(() {
      _connectionStatus = ConnectionStatus.waiting;
    });
  }
  String? validateIpAddress(String? formFieldContent){
    if(formFieldContent == null){
      return 'Enter IP Address';
    }
    RegExp regExp = RegExp(r'((\d{1,3}\.){3}\d{1,3})');
    RegExpMatch? match = regExp.firstMatch(formFieldContent);

    if(match == null || match[0] != formFieldContent){
      return 'Not Valid IP Address';
    }else{
      List<String> ipOctets = formFieldContent.split('.');
      for(String ipOctet in ipOctets){
        if(int.parse(ipOctet) < 0 || int.parse(ipOctet) > 255){
          return 'Not Valid IP Address';
        }
      }
    }
    return null;
  }
  
  String? validatePortNumber(String? formFieldContent) {
    if(formFieldContent == null){
      return 'Enter Port Number';
    }
    RegExp regExp = RegExp(r'(\d{1,5})');
    RegExpMatch? match = regExp.firstMatch(formFieldContent);
    if(match == null || match[0] != formFieldContent || 
      int.parse(formFieldContent)> 65535 || int.parse(formFieldContent) < 0){
        return 'Not Valid Port Number!';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.lightGreen,
      appBar: AppBar(
       // backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          'Bufo',
          style: TextStyle(
           //   color: Colors.green
          ),
        ),
      ),
      body: body()
    );
  }

  Container body(){
    switch(_connectionStatus){
      case ConnectionStatus.connecting:
        return Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                addVerticalSpace(20.0),
                Text('Connecting to Server...'),
              ],
            ),
          ),
        );
      case ConnectionStatus.failed:
        return Container(
          color: Colors.red,
          child: Center(
            child: Text('Connectiing to Server Failed: $_errorMessage'),
          ),
        );
    
      case ConnectionStatus.waiting:
        return Container(
        margin: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              createTextFormField(
                validate: (content) => validateIpAddress(content),
                handleSave: (String? formFieldContent) => _ipAddress = formFieldContent,
                labelText: 'IP Address', 
                hintText: '10.123.122.5'
              ),
              createTextFormField(
                validate: (content) => validatePortNumber(content),
                handleSave: (String? formFieldContent) => _portNumber = formFieldContent,
                labelText: 'Port Number'
              ),
              addVerticalSpace(30.0),
              createTextButton(onPress: handleSubmit, text: 'Connect To Server'),
            ],
          ),
        ),
      );
          
        
    }
  }

  TextFormField createTextFormField({required String? Function(String?) validate ,required void Function(String?) handleSave
    ,String labelText = '', String hintText = ''}){

    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
      ),
      validator: (content) => validate(content),
        
      
      onSaved: (newValue)=> handleSave(newValue),
      style: TextStyle(
        color: Colors.blue
      ),
      
      keyboardType: TextInputType.number,
    );
  }
}