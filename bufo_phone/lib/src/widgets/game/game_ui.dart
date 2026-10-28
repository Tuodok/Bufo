import 'package:bufo/src/network/message.dart';
import 'package:bufo/src/widgets/game/joystick.dart';
import 'package:flutter/material.dart';

class GameUI extends StatefulWidget {
  final void Function(Message) callback;
  const new({super.key, required this.callback});

  @override
  State<GameUI> createState() => _GameUIState();
}

class _GameUIState extends State<GameUI> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Joystick(
          position: Offset(100, 50),
          callback:  widget.callback,
          joystickType: JoystickType.movement,
        ),
        //Joystick(position: Offset(500, 30), callback: widget.callback,)
      ],
    );
  }
}