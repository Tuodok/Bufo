

import 'package:flutter/material.dart';

mixin ButtonBuilder {
  Container buildButton({
    required Color color,
    required Color borderColor,
    required double borderWidth,
    required bool roundEdges,
    void Function()? tapDown,
    void Function()? tapUp,
    void Function()? tapCancel,
    required double padding,
    required Widget buttonsChild,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        border: BoxBorder.all(color: borderColor, width: borderWidth),
        borderRadius: roundEdges
            ? BorderRadius.circular(15.0)
            : BorderRadius.zero,
      ),

      child: InkWell(
        onTapDown: (TapDownDetails details) => tapDown?.call(),
        onTapUp: (TapUpDetails details) => tapUp?.call(),
        onTapCancel: tapCancel,

        child: Padding(
          padding: EdgeInsets.all(padding),
          child: FittedBox(fit: BoxFit.none, child: buttonsChild),
        ),
      ),
    );
  }
}
