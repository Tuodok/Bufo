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
    await playAudio();
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

/*enum SwitchSetting { noSwitch, on, off }

enum TapEvent { down, up, cancel }

class CustomButton extends StatefulWidget {
  final Function() callback;
  final StatelessWidget buttonsChild;
  final double padding;
  final Color primaryColor;
  final Color secondaryColor;
  final Color borderColor;
  final SwitchSetting switchSetting;
  final double borderWidth;
  final bool roundedEdges;
  final String? sfxPath;

  const CustomButton({
    super.key,
    required this.callback,
    required this.buttonsChild,
    this.padding = 5.0,
    this.primaryColor = const Color.fromARGB(255, 36, 181, 197),
    this.secondaryColor = Colors.amber,
    this.borderColor = Colors.black,
    this.switchSetting = SwitchSetting.noSwitch,
    this.borderWidth = 3.0,
    this.roundedEdges = true,
    this.sfxPath,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  Color _activeColor = Colors.black;
  AudioPlayer? _audioPlayer;

  @override
  void initState() {
    if (widget.switchSetting == SwitchSetting.noSwitch ||
        widget.switchSetting == SwitchSetting.off) {
      _activeColor = widget.primaryColor;
    } else {
      _activeColor = widget.secondaryColor;
    }

    _setupAudioPlayer();
    super.initState();
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  void _setupAudioPlayer() async {
    if (widget.sfxPath == null) {
      return;
    }

    _audioPlayer = AudioPlayer();
    _audioPlayer!.setReleaseMode(ReleaseMode.stop);

    try {
      await _audioPlayer!.setSource(AssetSource(widget.sfxPath!));
    } catch (e, stackTrace) {
      debugPrint('Failed to set source: $e');
      debugPrintStack(stackTrace: stackTrace);
      _audioPlayer = null;
    }
  }

  void _handleTapping(TapEvent eventType) {
    switch (eventType) {
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
    if (widget.sw/itchSetting == SwitchSetting.noSwitch) {
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
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _activeColor,
        border: BoxBorder.all(
          color: widget.borderColor,
          width: widget.borderWidth,
        ),
        borderRadius: widget.roundedEdges
            ? BorderRadius.circular(15.0)
            : BorderRadius.zero,
      ),

      child: InkWell(
        onTapDown: (TapDownDetails details) => _handleTapping(TapEvent.down),
        splashColor: widget.secondaryColor,
        onTapUp: (TapUpDetails details) => _handleTapping(TapEvent.up),
        onTapCancel: () => _handleTapping(TapEvent.cancel),

        child: Padding(
          padding: EdgeInsets.all(widget.padding),
          child: FittedBox(fit: BoxFit.none, child: widget.buttonsChild),
        ),
      ),
    );
  }
}*/
