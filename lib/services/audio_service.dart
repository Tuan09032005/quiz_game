import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _bgmPlayer = AudioPlayer();
  static final AudioPlayer _sfxPlayer = AudioPlayer();
  static bool _soundEffectsEnabled = true;

  static Future<void> init() async {
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    _sfxPlayer.setReleaseMode(ReleaseMode.stop);
    await _sfxPlayer.setSource(AssetSource('sounds/tap.mp3'));
    await _sfxPlayer.setVolume(1.0);
  }

  static Future<void> playBgm() async {
    await _bgmPlayer.play(AssetSource('sounds/backgroundmusic.mp3'));
  }

  static Future<void> stopBgm() async {
    await _bgmPlayer.stop();
  }

  static Future<void> pauseBgm() async {
    await _bgmPlayer.pause();
  }

  static Future<void> resumeBgm() async {
    await _bgmPlayer.resume();
  }

  static Future<void> playButtonSound() async {
    if (_soundEffectsEnabled) {
      await _sfxPlayer.play(_sfxPlayer.source!);
    }
  }

  static void setSoundEffectsEnabled(bool enabled) {
    _soundEffectsEnabled = enabled;
  }
}
