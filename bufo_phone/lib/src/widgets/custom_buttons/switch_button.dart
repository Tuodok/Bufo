import 'package:flutter/material.dart';

import 'package:bufo/src/widgets/custom_buttons/base_button.dart';


class SwitchButton extends BaseButton{
  
  final void Function() callback;
  final bool isOnAtStart;

  const SwitchButton({
    super.key,
    required this.callback,
    this.isOnAtStart =false,
    required super.buttonsChild,
    super.padding,
    super.primaryColor,
    super.secondaryColor,
    super.borderColor,
    super.borderWidth,
    super.roundedEdges,
    super.sfxPath,
  });
  
  

  @override
  State<SwitchButton> createState() => _SwitchButtonState(); 

}

class _SwitchButtonState extends BaseButtonState<SwitchButton>{


  @override
  void initState() {

    super.initState();
    widget.isOnAtStart;
    activeColor = widget.isOnAtStart?widget.secondaryColor:widget.primaryColor;
    
    
    
  }

  @override
  void handleTapDown() async {
    await playAudio();


  
    setState(() {
      activeColor = activeColor == widget.primaryColor
          ? widget.secondaryColor
          : widget.primaryColor;
    });

    //Necessary if widget.callback() calls setState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.callback();
    });
    
  }
  
  @override
  void handleTapUp() {
  }
  @override
  void handleTapCancel() {
  }

  


}