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
    setupAudioPlayer();
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
  void setupAudioPlayer() async {
    if (widget.sfxPath == null) {
      return;
    }
    _audioPlayer!.setReleaseMode(ReleaseMode.stop);

    try {
      await _audioPlayer!.setSource(AssetSource(widget.sfxPath!));
    } catch (e, stackTrace) {
      debugPrint('Failed to set source: $e');
      debugPrintStack(stackTrace: stackTrace);
      _audioPlayer = null;
    }
  }

  @protected
  Future<void> playAudio() async {
    try {
      await _audioPlayer?.resume();
    } catch (e, stackTrace) {
      debugPrint('Audio error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
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

  

 // @override
  //State<CustomButton> createState() => _CustomButtonState();
/*
abstract class _CustomButtonState extends State<CustomButton> {
  
  

  void
  
  void _setupAudioPlayer() async {
    if (widget.sfxPath == null){return;} 

    _audioPlayer = AudioPlayer();
    _audioPlayer!.setReleaseMode(ReleaseMode.stop);

    try{
      await _audioPlayer!.setSource(AssetSource(widget.sfxPath!));
    } catch (e, stackTrace) {
      debugPrint('Failed to set source: $e');
      debugPrintStack(stackTrace: stackTrace);
      _audioPlayer = null;
    }
    
  }

  void _handleTapping(TapEvent eventType) {
    switch(eventType){
      case TapEvent.down:
        _handleTapDown();
        break;
      case TapEvent.up:
        _handleTapUp();
        break;
      case TapEvent.cancel:
        _resetColor();
        break;

    }
  }

  void _handleTapDown() async {
    
    
    if (widget.switchSetting != SwitchSetting.noSwitch) {
      await _playAudio();
      setState(() {
        _activeColor = _activeColor == widget.primaryColor
          ? widget.secondaryColor
          : widget.primaryColor;
      });
      //Necessary if widget.callback() calls setState.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.callback();
      });
      return;
    } 
    setState(() {
      _activeColor = widget.secondaryColor;
    });

   
    
  }

  Future<void> _handleTapUp() async {
    if(widget.switchSetting == SwitchSetting.noSwitch){
       await _playAudio();
      _resetColor();
      //Necessary if widget.callback() calls setState.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.callback();
      });
    }
   
  }

  Future<void> _playAudio() async {
    try {
      await _audioPlayer?.resume();
    } catch (e, stackTrace) {
      debugPrint('Audio error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void _resetColor() {
    setState(() {
      _activeColor = widget.primaryColor;
    });
  }


  
  
  @override
  Widget build(BuildContext context){
    return Container(
      decoration: BoxDecoration(
        color: _activeColor,
        border: BoxBorder.all(
          color: widget.borderColor,
          width: widget.borderWidth
        ),
        borderRadius: widget.roundedEdges ? BorderRadius.circular(15.0) : BorderRadius.zero,
      ),

      child: InkWell(
        onTapDown: (TapDownDetails details) => _handleTapping(TapEvent.down),
        splashColor: widget.secondaryColor,
        onTapUp: (TapUpDetails details) => _handleTapping(TapEvent.up),
        onTapCancel: () => _handleTapping(TapEvent.cancel),

        child:  Padding(
          padding: EdgeInsets.all(widget.padding),
          child: FittedBox(
            fit: BoxFit.none,
            child: widget.buttonsChild
          ),
        ),
      ),
    );
  }  

}*/