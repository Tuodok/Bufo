import 'package:bufo/src/network/message.dart';
import 'package:bufo/src/network/network_manager.dart';

import 'package:bufo/src/widgets/custom_buttons/normal_button.dart';
import 'package:flutter/material.dart';

class TypeWriter extends StatefulWidget {

  final Color bgColor;
  final double width;
  final double height;

  const new({
    super.key, 
    this.bgColor = const Color.fromARGB(255, 0, 255, 221),
    this.width = 400.0,
    this.height = 300.0,
  });

  @override
  State<TypeWriter> createState() => _TypeWriterState();
}

class _TypeWriterState extends State<TypeWriter> {

  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void sendText(){
    NetworkManager.sendMessage(Message.write(_textController.text));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.bgColor,
        border: Border.all(
          color: Colors.blue,
          width: 2.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: TextField(
              controller: _textController,
              maxLines: 10,
            ),
          ),
          Expanded(
            child: NormalButton(
              callback: sendText,
              buttonsChild: Text('Send')
            
            ),
          ),
        ],
      ),
    );
  }
}
 
       