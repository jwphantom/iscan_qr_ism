import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> playSound(bool success) async {
    try {
      if (success) {
        await _audioPlayer.play(AssetSource('sounds/success.wav'));
      } else {
        await _audioPlayer.play(AssetSource('sounds/error.wav'));
      }
    } catch (e) {
      print("Erreur lors de la lecture du son: $e");
    }
  }

  static void dispose() {
    _audioPlayer.dispose();
  }
}
