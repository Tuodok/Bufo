
import 'dart:io';

import 'package:bufo/src/network/network_manager.dart';
import 'package:bufo/src/widgets/custom_app_bar.dart';

import 'package:bufo/src/widgets/custom_buttons/normal_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'control_screen.dart';


enum ConnectionStatus { connecting, failed, waitingForUserInput }

class ConnectToServerScreen extends StatefulWidget {

  const new({super.key});

  @override
  State<ConnectToServerScreen> createState() => _ConnectToServerScreenState();
}

class _ConnectToServerScreenState extends State<ConnectToServerScreen>{

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _ipAddress;
  String? _portNumber;
  ConnectionStatus _connectionStatus = ConnectionStatus.waitingForUserInput;
  String _errorMessage = '';
 

  @override
  void initState() {
     SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
  }
  
  void handleSubmit() async {
    if(_formKey.currentState == null||!_formKey.currentState!.validate()){
      return;
    }
    _formKey.currentState?.save();

    setState(() {
      _connectionStatus = ConnectionStatus.connecting;
    });

    
    String? errorMsg = await NetworkManager.connectToServer(
      serverIp: InternetAddress(_ipAddress!), 
      serverPort: int.parse(_portNumber!),
    );
   
    if(errorMsg != null){
      _networkError(errorMsg);
      return;
    } 
    
    if(!context.mounted){return;}
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => ControlScreen()
      ),
    );
  }

  void _networkError(String msg) async{
     setState(() {
      _connectionStatus = ConnectionStatus.failed;
      _errorMessage = msg;
    });
    await Future.delayed(Duration(seconds: 30));
    setState(() {
      _connectionStatus = ConnectionStatus.waitingForUserInput;
    });
  }

  String? _validateIpAddress(String? formFieldContent){
    if(formFieldContent == null){
      return 'Enter IP Address';
    }
    RegExp regExp = RegExp(r'((\d{1,3}\.){3}\d{1,3})');
    RegExpMatch? match = regExp.firstMatch(formFieldContent);

    if(match == null || match[0] != formFieldContent){
      return 'Not Valid IP Address';
    }else{
      if(!_validateIpOctets(formFieldContent)){
        return 'Not Valid IP Address';
      }
    }
    return null;
  }

  bool _validateIpOctets(String ipAddress){
    List<String> ipOctets = ipAddress.split('.');
    for (String ipOctet in ipOctets) {
      if (int.parse(ipOctet) < 0 || int.parse(ipOctet) > 255) {
        return false;
      }
    }
    return true;
  }
  
  String? _validatePortNumber(String? formFieldContent) {
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
      appBar: CustomAppBar(),
      
      body: body()
    );
  }

  Container body(){
    switch(_connectionStatus){
      case ConnectionStatus.waitingForUserInput:
        return _inputForm();
      case ConnectionStatus.connecting:
        return _connenctingToServerDisplay();
      case ConnectionStatus.failed:
        return _connectionErrorDisplay();
    }
  }

  Container _inputForm(){
    return Container(
      margin: EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            _createTextFormField(
              validate: (content) => _validateIpAddress(content),
              handleSave: (String? formFieldContent) =>
                  _ipAddress = formFieldContent,
              labelText: 'IP Address',
              hintText: '10.123.122.5',
            ),
            _createTextFormField(
              validate: (content) => _validatePortNumber(content),
              handleSave: (String? formFieldContent) =>
                  _portNumber = formFieldContent,
              labelText: 'Port Number',
            ),
            SizedBox(height: 30.0),
            NormalButton(
              callback: handleSubmit,
              buttonsChild: Text('Connect To Server!'),
              sfxPath: 'sound_effects/mixkit-metal-button-push-1830.wav',
            ),
          ],
        ),
      ),
    );
  }
  
  Container _connenctingToServerDisplay(){
    return Container(
      color: Colors.lightBlue,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20.0),
            Text('Connecting to Server...'),
          ],
        ),
      ),
    );
  }

  Container _connectionErrorDisplay(){
     return Container(
      color: Colors.red,
      child: Center(child: Text(_errorMessage)),
    );
  }

  TextFormField _createTextFormField({
    required String? Function(String?) validate,
    required void Function(String?) handleSave,
    String labelText = '', 
    String hintText = ''
  }){

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