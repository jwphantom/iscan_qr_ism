import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static AudioPlayer? _audioPlayer;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (!_isInitialized) {
      _audioPlayer = AudioPlayer();
      _isInitialized = true;

      // Pré-charger les sons pour une meilleure performance
      await Future.wait([
        _audioPlayer!.setSource(AssetSource('sounds/success.wav')),
        _audioPlayer!.setSource(AssetSource('sounds/error.wav')),
      ]);
    }
  }

  static Future<void> playSound(bool success) async {
    try {
      if (!_isInitialized || _audioPlayer == null) {
        await initialize();
      }

      if (success) {
        await _audioPlayer!.play(AssetSource('sounds/success.wav'));
      } else {
        await _audioPlayer!.play(AssetSource('sounds/error.wav'));
      }
    } catch (e) {
      print("Erreur lors de la lecture du son: $e");
      // Tenter de réinitialiser en cas d'erreur
      _isInitialized = false;
      _audioPlayer?.dispose();
      _audioPlayer = null;
    }
  }

  static void dispose() {
    _audioPlayer?.dispose();
    _audioPlayer = null;
    _isInitialized = false;
  }
}
