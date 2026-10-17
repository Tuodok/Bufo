import 'package:bufo/src/communication/message.dart';
import 'package:bufo/src/providers/server_client_provider.dart';
import 'package:bufo/src/widgets/custom_buttons/normal_button.dart';
import 'package:bufo/src/widgets/custom_buttons/switch_button.dart';
import 'package:flutter/material.dart';

import 'package:bufo/src/communication/tcp_client.dart';
import '../../../bufo/bufo_keycodes.dart';



class Keyboard extends StatefulWidget {
 
  final double width;
  final double height;

  const new({
    super.key, 
    this.width = 500,
    this.height = 180
  });

  @override
  State<Keyboard> createState() => _KeyboardState();
}

class _KeyboardState extends State<Keyboard>{

  
  void handleKeyPress(String keyValue){
    debugPrint('KeyPress');
    ServerClientProvider.of(context).serverClient
        .sendCommand(JsonMessage.keyPress(keyValue));
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
    if(!holdDownWhenPressed){
       return Expanded(
        child: NormalButton(
          callback: () => handleKeyPress(keyValue),
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
        callback: () => handleKeyPress(keyValue),
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
 
  