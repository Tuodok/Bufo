import 'package:flutter/material.dart';

mixin BuilderMixin {
  
  SizedBox addVerticalSpace(double amount) {
    return SizedBox(height: amount);
  }

  SizedBox addHorizontalSpace(double amount){
    return SizedBox(width: amount);
  }

  TextButton createTextButton({
    required void Function() onPress,
    String text = 'Submit',
    Color color = Colors.black,
    Color textColor = Colors.white,
  }) {
    return TextButton(
      onPressed: onPress,

      style: TextButton.styleFrom(backgroundColor: color),
      child: FittedBox(
        fit: BoxFit.none,
        child: Text(text, style: TextStyle(color: textColor)),
      ),
    );
  }

  IconButton createIconButton({
    required void Function() onPress,
    required IconData icon,
  }) {
    return IconButton(onPressed: onPress, icon: Icon(icon));
  }

}