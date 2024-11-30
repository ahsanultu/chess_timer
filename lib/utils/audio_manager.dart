import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isMuted = false;

  static Future<void> init() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
    await _audioPlayer.setVolume(1.0);
    await _loadSounds();
  }

  static Future<void> _loadSounds() async {
    // Preload sounds for better performance
    await _audioPlayer.setSource(AssetSource('sounds/move.mp3'));
    await _audioPlayer.setSource(AssetSource('sounds/start.mp3'));
    await _audioPlayer.setSource(AssetSource('sounds/pause.mp3'));
    await _audioPlayer.setSource(AssetSource('sounds/reset.mp3'));
    await _audioPlayer.setSource(AssetSource('sounds/timeout.mp3'));
    await _audioPlayer.setSource(AssetSource('sounds/low_time.mp3'));
  }

  static void toggleMute() {
    _isMuted = !_isMuted;
  }

  static bool get isMuted => _isMuted;

  static void playMove() {
    if (_isMuted) return;
    _audioPlayer.play(AssetSource('sounds/move.mp3'));
  }

  static void playStart() {
    if (_isMuted) return;
    _audioPlayer.play(AssetSource('sounds/start.mp3'));
  }

  static void playPause() {
    if (_isMuted) return;
    _audioPlayer.play(AssetSource('sounds/pause.mp3'));
  }

  static void playReset() {
    if (_isMuted) return;
    _audioPlayer.play(AssetSource('sounds/reset.mp3'));
  }

  static void playTimeout() {
    if (_isMuted) return;
    _audioPlayer.play(AssetSource('sounds/timeout.mp3'));
  }

  static void playLowTime() {
    if (_isMuted) return;
    _audioPlayer.play(AssetSource('sounds/low_time.mp3'));
  }

  static Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  static void dispose() {
    _audioPlayer.dispose();
  }
}
