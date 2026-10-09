import 'package:flutter/material.dart';

class KeyboardButton extends StatefulWidget {

  final Function() callback;
  final String text;
  final Color color;
  final Color textColor;
  final bool holdDownWhenPressed;
  final Color holdDownColor;

  const new({
    super.key, 
    required this.callback, 
    required this.text,
    this.color = Colors.black,
    this.textColor = Colors.white,
    this.holdDownWhenPressed = false,
    this.holdDownColor = Colors.amber,
  });

  @override
  State<KeyboardButton> createState() => _KeyboardButtonState();
}

class _KeyboardButtonState extends State<KeyboardButton> {
  
  Color _activeColor = Colors.black;

  @override
  void initState() {
    _activeColor = widget.color;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        if(widget.holdDownWhenPressed){
          setState(() {
            _activeColor = _activeColor == widget.color
                ? widget.holdDownColor
                : widget.color;
          });
          
        }
        widget.callback();
      },

      style: TextButton.styleFrom(backgroundColor: _activeColor),
      child: FittedBox(
        fit: BoxFit.none,
        child: Text(widget.text, style: TextStyle(color: widget.textColor)),
      ),
    );
    
  }
}