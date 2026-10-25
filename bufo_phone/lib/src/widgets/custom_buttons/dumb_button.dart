
import 'package:audioplayers/audioplayers.dart';
import 'package:bufo/src/widgets/custom_buttons/button_builder.dart';
import 'package:flutter/material.dart';

class DumbButton extends StatelessWidget with ButtonBuilder {

  final void Function() _callback;
  final StatelessWidget _buttonsChild;
  final Color _color;
  final double _padding;
  final Color _borderColor;
  final double _borderWidth;
  final bool _roundedEdges;
  final String? _sfxPath;
  late final AudioPlayer _audioPlayer = AudioPlayer();



  DumbButton({
    super.key, 
    required this._callback,
    required this._buttonsChild,
    required this._color,
    this._padding = 5.0,
    this._borderColor = Colors.black,
    this._borderWidth = 3.0,
    this._roundedEdges = true,
    this._sfxPath
  });
    
   
   
  

  void handleTapDown(){
    if(_sfxPath!= null){
      _audioPlayer.play(AssetSource(_sfxPath));
    }
    _callback();
    
  }

  @override
  Widget build(BuildContext context) {
    return buildButton(
      color: _color, 
      borderColor: _borderColor, 
      borderWidth: _borderWidth, 
      roundEdges: _roundedEdges, 
      tapDown: handleTapDown,  
      padding: _padding, 
      buttonsChild: _buttonsChild
    );
  }
}