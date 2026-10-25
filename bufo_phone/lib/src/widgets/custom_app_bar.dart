import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {

  final Color _appBarColor;
  final String _titleText;
  final Color _titleColor;
  final bool _titleInCenter;
  final IconButton? _leadingIconButton;
  final List<IconButton>? _barActions;

  const new({
    super.key,
    this._appBarColor = Colors.blueGrey,
    this._titleText = 'Bufo',
    this._titleColor = Colors.black,
    this._titleInCenter = true,
    this._leadingIconButton,
    this._barActions,
  });
  
   @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
       backgroundColor: _appBarColor,
      title: Text(
        _titleText,
        style: TextStyle(
          color: _titleColor
        ),
      ),
      centerTitle: _titleInCenter,
      leading: _leadingIconButton,
      actions: _barActions,
    );
  }

 
}