import 'package:flutter/material.dart';

mixin BuilderMixin {
  
  SizedBox addVerticalSpace(double amount) {
    return SizedBox(height: amount);
  }

  SizedBox addHorizontalSpace(double amount){
    return SizedBox(width: amount);
  }

  AppBar createAppBar({
    Color appBarColor = Colors.blueGrey,
    String titleText = 'Bufo',
    Color titleColor = Colors.black,
    bool titleInCenter = true,
    IconButton? leadingIconButton,
    List<IconButton>? barActions,
  }){
    return AppBar(
      backgroundColor: appBarColor,
      title: Text(
        titleText,
        style: TextStyle(
          color: titleColor
        ),
      ),
      centerTitle: titleInCenter,
      leading: leadingIconButton,
      actions: barActions,
    );
  }

  TextButton createTextButton({
    required void Function() onPress,
    String text = 'Submit',
    Color buttonColor = Colors.blue,
    Color textColor = Colors.white,
  }) {
    return TextButton(
      onPressed: onPress,
      style: TextButton.styleFrom(backgroundColor: buttonColor),
      child: Text(
        text, 
        style: TextStyle(color: textColor)
      ),
    );
  }

  IconButton createIconButton({
    required void Function() onPress,
    required IconData icon,
    Color buttonColor = Colors.blue,
    Color iconColor = Colors.black,
  }) {
    return IconButton(
      onPressed: onPress, 
      color: buttonColor,
      icon: Icon(
        icon,
        color: iconColor,
      ),
    );
  }

}