import 'package:audioplayers/audioplayers.dart';

mixin AudioplayerMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();

    /*void setupAudioPlayer(String path) async {
   
    _audioPlayer.setReleaseMode(ReleaseMode.stop);

    try {
      await _audioPlayer.setSource(AssetSource(path));
    } catch (e, stackTrace) {
      debugPrint('Failed to set source: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }*/

  Future<void> playAudio(String path) async {
    await _audioPlayer.play(AssetSource(path));
  }
}