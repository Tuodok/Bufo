
import 'package:audioplayers/audioplayers.dart';
import 'package:bufo/src/widgets/custom_buttons/button_builder.dart';
import 'package:flutter/material.dart';

class DumbSwitchButton extends StatelessWidget with ButtonBuilder {

  final void Function() _callback;
  final StatelessWidget _buttonsChild;
  final bool _isOn;
  final double _padding;
  final Color _primaryColor;
  final Color _secondaryColor;
  final Color _borderColor;
  final double _borderWidth;
  final bool _roundedEdges;
  final String? _sfxPath;
  late final AudioPlayer _audioPlayer = AudioPlayer();

  late final Color _activeColor;

  DumbSwitchButton({
    super.key, 
    required this._callback,
    required this._buttonsChild,
    required this._isOn,
    this._padding = 5.0,
    this._primaryColor = const Color.fromARGB(255, 36, 181, 197),
    this._secondaryColor = Colors.yellow,
    this._borderColor = Colors.black,
    this._borderWidth = 3.0,
    this._roundedEdges = true,
    this._sfxPath
  }): _activeColor = _isOn ? _secondaryColor : _primaryColor;
    
   
   
  

  void handleTapDown(){
    if(_sfxPath!= null){
      _audioPlayer.play(AssetSource(_sfxPath));
    }
    _callback();
    
  }

  @override
  Widget build(BuildContext context) {
    return buildButton(
      color: _activeColor, 
      borderColor: _borderColor, 
      borderWidth: _borderWidth, 
      roundEdges: _roundedEdges, 
      tapDown: handleTapDown, 
      tapUp: (){}, 
      tapCancel: (){}, 
      padding: _padding, 
      buttonsChild: _buttonsChild
    );
  }
}