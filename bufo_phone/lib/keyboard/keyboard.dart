import 'package:bufo/communication/message.dart';
import 'package:bufo/keyboard/keyboard_button.dart';
import 'package:flutter/material.dart';

import 'package:bufo/communication/tcp_client.dart';
import 'bufo_keycodes.dart';



class Keyboard extends StatefulWidget {
 
  final TcpClient serverClient;


  const new({super.key, required this.serverClient});

  @override
  State<Keyboard> createState() => _KeyboardState();
}

class _KeyboardState extends State<Keyboard>{

  
  void handleKeyPress(String keyValue){
    widget.serverClient.sendCommand(JsonMessage.keyPress(keyValue));
  }

  @override
  Widget build(BuildContext context) {
    return  Container(
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
           rowOfButtons.add(createKeyboardButton(keyValue, true));
        }
        else{
          rowOfButtons.add(createKeyboardButton(keyValue, false));
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
  Expanded createKeyboardButton(String keyValue, bool holdDownWhenPressed){
    return Expanded(
      child: KeyboardButton(
        callback: () => handleKeyPress(keyValue), 
        text: keyValue.toUpperCase(),
        holdDownWhenPressed: holdDownWhenPressed,
      )
    );
  }
}
 
  