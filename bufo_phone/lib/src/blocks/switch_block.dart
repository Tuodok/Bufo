import 'dart:async';

class SwitchBlock {

  bool _isOn = false;

  final StreamController<SwitchBlock> _switchController = StreamController<SwitchBlock>.broadcast();

  Stream<bool> get stream => _switchController.stream.transform(_handleToggle);
  bool get isOn => _isOn; 


  void toggle(){
    _switchController.sink.add(this);
  }

  final _handleToggle = StreamTransformer<SwitchBlock, bool>.fromHandlers(
    handleData: (SwitchBlock switchBlock, sink){
      bool isOn = switchBlock.isOn?false:true;
      switchBlock._isOn = isOn;
      sink.add(isOn);
    }
  );

  void dispose(){
    _switchController.close();
  }
}