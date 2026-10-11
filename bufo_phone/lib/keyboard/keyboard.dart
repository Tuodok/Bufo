import 'package:bufo/communication/message.dart';
import 'package:bufo/widgets/custom_button.dart';
import 'package:flutter/material.dart';

import 'package:bufo/communication/tcp_client.dart';
import 'bufo_keycodes.dart';



class Keyboard extends StatefulWidget {
 
  final TcpClient serverClient;
  final double width;
  final double height;

  const new({
    super.key, 
    required this.serverClient,
    this.width = 500,
    this.height = 180
  });

  @override
  State<Keyboard> createState() => _KeyboardState();
}

class _KeyboardState extends State<Keyboard>{

  
  void handleKeyPress(String keyValue){
    debugPrint('KeyPress');
    widget.serverClient.sendCommand(JsonMessage.keyPress(keyValue));
  }

  @override
  Widget build(BuildContext context) {
    return  Container(
      width: widget.width,
      height: widget.height,
      padding: EdgeInsets.all(5.0),
      color: const Color.fromARGB(98, 147, 7, 28),
      child: createKeys(),
    );
  }

  Column createKeys() {
  List<Expanded> rows = [];
    for (List<String> rowOfKeyValues in bufoKeyCodes) {
      List<Expanded> rowOfButtons = [];
      for(String keyValue in rowOfKeyValues){
        //Modifier keys all hold down when pressed
        if(bufoModifierKeyCodes.contains(keyValue)){
           rowOfButtons.add(_createKeyboardButton(keyValue, true));
           debugPrint('Modifier: $keyValue');
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
  Expanded _createKeyboardButton(String keyValue, bool holdDownWhenPressed){
    return Expanded(
      child: CustomButton(
        callback: () => handleKeyPress(keyValue), 
        buttonsChild: Text(keyValue.length > 5 ? keyValue.substring(0,5): keyValue),
        padding: 0.0,
        switchSetting: holdDownWhenPressed ? SwitchSetting.off : SwitchSetting.noSwitch,
        roundedEdges: false,
        sfxPath: 'sound_effects/mixkit-metal-button-push-1830.wav',
      )
    );
  }
}
 
  