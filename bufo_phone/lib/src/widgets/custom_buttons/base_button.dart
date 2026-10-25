import 'package:bufo/src/widgets/custom_buttons/button_builder.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

abstract class BaseButton extends StatefulWidget {

  final StatelessWidget buttonsChild;
  final double padding;
  final Color primaryColor;
  final Color secondaryColor;
  final Color borderColor;
  final double borderWidth;
  final bool roundedEdges;
  final String? sfxPath;

  const BaseButton({
    super.key, 
    required this.buttonsChild,
    this.padding = 5.0,
    this.primaryColor = const Color.fromARGB(255, 36, 181, 197),
    this.secondaryColor = Colors.amber,
    this.borderColor = Colors.black,
    this.borderWidth = 3.0,
    this.roundedEdges = true,
    this.sfxPath
  });

  
}
abstract class BaseButtonState<T extends BaseButton> extends State<T> with ButtonBuilder{

  late Color activeColor;
  AudioPlayer? _audioPlayer;

  @override
  void initState() {
    activeColor = widget.primaryColor;
    if(widget.sfxPath != null){
      _audioPlayer = AudioPlayer();
    }
    super.initState();
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  @protected
  void handleTapDown();
  @protected
  void handleTapUp();
  @protected
  void handleTapCancel();

  @protected
 

  @protected
  Future<void> playAudio() async {
    _audioPlayer?.play(AssetSource(widget.sfxPath!));
  }

  @override
  Widget build(BuildContext context){
    return buildButton(
      color: activeColor, 
      borderColor: widget.borderColor, 
      borderWidth: widget.borderWidth, 
      roundEdges: widget.roundedEdges, 
      tapDown: handleTapDown, 
      tapUp: handleTapUp, 
      tapCancel: handleTapCancel, 
      padding: widget.padding, 
      buttonsChild: widget.buttonsChild
    );
  }
}

  

