import 'dart:math';

import 'package:bufo/src/network/message.dart';
import 'package:flutter/material.dart';

enum JoystickType{
  movement,
  rotation,
}

class Joystick extends StatefulWidget {
  final Offset position;
  final JoystickType joystickType;
  final void Function(Message) callback;
  final Color backgroundColor;
  final Color knobColor;
  const new({
    super.key, 
    required this.position,
    required this.joystickType,
    required this.callback,
    this.backgroundColor = const Color.fromARGB(52, 18, 205, 55),
    this.knobColor = const Color.fromARGB(190, 39, 164, 41)
    });

  @override
  State<Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> {

  final double _bgSize = 100;
  late Offset _bgPos;
  late Offset _knobOrigin;
  final double _knobSize = 30;
  late Offset _knobPos;

  late double _maxDistance;

  late final double _knobTreshholdDistance;
  

  @override
  void initState() {
    //_position = _originalPos;
    //_maxDistance = backgroundHeight / 2 - knobSize /2;
    _bgPos = widget.position;
    _knobOrigin = Offset(
      _bgPos.dx + (_bgSize / 2 - _knobSize / 2),
      _bgPos.dy + (_bgSize / 2 - _knobSize / 2),
    );
    _knobPos = _knobOrigin;
    _maxDistance = _bgSize / 2 - _knobSize / 2;
    _knobTreshholdDistance = _maxDistance *0.8;
    
    super.initState();
  }

    void _updateKnobPosition(DragUpdateDetails details) {
    Offset newPos = _knobPos + Offset(details.delta.dx, -details.delta.dy);
    double distance = sqrt(
      pow((newPos.dx - _knobOrigin.dx), 2) +
          pow((newPos.dy - _knobOrigin.dy), 2),
    );

    if (distance < _maxDistance) {
      if((newPos.dx -_knobOrigin.dx).abs()  > _knobTreshholdDistance && 
        (_knobPos.dx - _knobOrigin.dx).abs() < _knobTreshholdDistance){

        }
      else if((newPos.dx -_knobOrigin.dx).abs()  < _knobTreshholdDistance && 
        (_knobPos.dx - _knobOrigin.dx).abs() > _knobTreshholdDistance){
          
      }
      if ((newPos.dy - _knobOrigin.dy).abs() > _knobTreshholdDistance &&
          (_knobPos.dy - _knobOrigin.dy).abs() < _knobTreshholdDistance) {

      }
       else if ((newPos.dy - _knobOrigin.dy).abs() < _knobTreshholdDistance &&
          (_knobPos.dy - _knobOrigin.dy).abs() > _knobTreshholdDistance) {

          }
      setState(() {
        _knobPos = newPos;
      });
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: _bgPos.dx,
          bottom: _bgPos.dy,
          child: Container(
          
            width: _bgSize, 
            height: _bgSize, 
            color: widget.backgroundColor
          ),
        ),

        Positioned(
          left: _knobPos.dx,
          bottom: _knobPos.dy,
          child: Container(
            width: _knobSize,
            height: _knobSize,
            color: widget.knobColor,
            child: GestureDetector(
              onPanUpdate: (DragUpdateDetails details) {
                _updateKnobPosition(details);
              },
              onPanEnd: (_){
                setState(() {
                  _knobPos = _knobOrigin;
                });
              },
            ),
          ),
        ),
      ],
    );
  }















  /*final double _backgroundSize = 100;
  late final Offset _backgroundPos;
  late final Offset _knobOrigin;
  final double _knobSize = 30;
  late Offset _knobPos;
  late double _maxDistance;
  double movementMultplyer = 2;

  @override
  void initState() {
    _backgroundPos = widget.position;
    _knobOrigin = Offset(
      _backgroundPos.dx + (_backgroundSize / 2 - _knobSize / 2), 
      _backgroundPos.dy + (_backgroundSize /2 - _knobSize / 2)
    );
    _knobPos = _knobOrigin;
    _maxDistance = _backgroundSize / 2 - _knobSize /2;
    super.initState();
  }

  void _updateKnobPosition(DragUpdateDetails details) {
    Offset newPos = _knobPos + Offset(
      details.delta.dx,
      -details.delta.dy
    );
     double distance = sqrt(
      pow((newPos.dx - _knobOrigin.dx), 2) +
          pow((newPos.dy - _knobOrigin.dy), 2),
    );
    if( distance < _maxDistance){
      setState(() {
        _knobPos = newPos;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: _backgroundPos.dx,
          right: _backgroundPos.dy,
          child: Container(
            width: _backgroundSize,
            height: _backgroundSize,
            color: widget.backgroundColor,
          ),
        ),
        Positioned(
          left: _knobPos.dx,
          right: _knobPos.dy,
          child: Container(
            width: _knobSize,
            height: _knobSize,
            color: widget.knobColor,
            child: GestureDetector(
              onPanUpdate: (DragUpdateDetails details){
                _updateKnobPosition(details);
              },
              onPanEnd: (DragEndDetails details){
                setState(() {
                  _knobPos = _knobOrigin;
                });
              },
            ),
          )
        )
      ],
    );
  }*/

  
}