import 'package:bufo/src/widgets/custom_buttons/base_button.dart';
import 'package:flutter/material.dart';


class NormalButton extends BaseButton {

  final void Function() callback;

  const NormalButton({
    super.key,
    required this.callback,
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
  State<NormalButton> createState() => _NormalButtonState();
}

class _NormalButtonState extends BaseButtonState<NormalButton> {
 

  @override
  void handleTapDown() {
    setState(() {
      activeColor = widget.secondaryColor;
    });
  }

  @override
  void handleTapUp() async {
   // await playAudio();
    setState(() {
      activeColor = widget.primaryColor;
    });
    //Necessary if widget.callback() calls setState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.callback();
    });
  }
  @override
  void handleTapCancel() {
    setState(() {
      activeColor = widget.primaryColor;
    });
  }
}

