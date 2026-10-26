import 'package:bufo/src/network/message.dart';
import 'package:bufo/src/network/network_manager.dart';


import 'package:bufo/src/widgets/custom_buttons/normal_button.dart';
import 'package:bufo/src/widgets/custom_buttons/switch_button.dart';
import 'package:flutter/material.dart';



class Keyboard extends StatefulWidget {


 
  final double _width;
  final double _height;

  const new({
    super.key, 
    this._width = 500,
    this._height = 180
  });

  @override
  State<Keyboard> createState() => _KeyboardState();
}

class _KeyboardState extends State<Keyboard>{

  static const List<List<String>> _pyautoguiKeyCodes = [
    ['esc', 'f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8', 'f9', 'f10', 'f12'],
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '+', '´'],
    ['tab', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '^'],
    ['capslock', 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', '\''],
    ['shift', '<', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '-'],
    ['ctrl', 'win', 'alt', 'space', 'altright', 'backspace', 'enter'],
  ];
  static const List<String> _toggleKeys = [
    'shift',
    'ctrl',
    'alt',
    'altright',
    'capslock',
  ];

  
  void _handleKeyPress(String keyValue){
    NetworkManager.sendMessage(Message.keyPress(keyValue));
  }

  @override
  Widget build(BuildContext context) {
    return  Container(
      width: widget._width,
      height: widget._height,
      padding: EdgeInsets.all(5.0),
      color: const Color.fromARGB(98, 147, 7, 28),
      child: _createKeys(),
    );
  }

  Column _createKeys() {
  List<Expanded> rows = [];
    for (List<String> rowOfKeyValues in _pyautoguiKeyCodes) {
      List<Expanded> rowOfButtons = [];
      for(String keyValue in rowOfKeyValues){
      
        if(_toggleKeys.contains(keyValue)){
           rowOfButtons.add(_createKeyboardButton(keyValue, true));
        }
        else{
          rowOfButtons.add(_createKeyboardButton(keyValue, false));
        }
       
      }
      rows.add(
        Expanded(
          child: Row(
            children: rowOfButtons,
          ),
        ),
      );
    }
    return Column(
      children: rows,
    );
  }
  Expanded _createKeyboardButton(String keyValue, bool toggleKey){
    if(!toggleKey){
       return Expanded(
         child: NormalButton(
           callback: () => _handleKeyPress(keyValue),
           buttonsChild: Text(
             keyValue.length > 5 ? keyValue.substring(0, 5) : keyValue,
           ),
           padding: 0.0,
           roundedEdges: false,
           sfxPath: 'sound_effects/mixkit-metal-button-push-1830.wav',
         ),
       );
    }
     return Expanded(
       child: SwitchButton(
         callback: () => _handleKeyPress(keyValue),
         buttonsChild: Text(
           keyValue.length > 5 ? keyValue.substring(0, 5) : keyValue,
         ),
         padding: 0.0,
         roundedEdges: false,
         sfxPath: 'sound_effects/mixkit-metal-button-push-1830.wav',
       ),
     );
   
  }
}
 
  