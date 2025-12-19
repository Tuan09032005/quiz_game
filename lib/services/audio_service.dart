import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _bgmPlayer = AudioPlayer();
  static final AudioPlayer _sfxPlayer = AudioPlayer();

  static Future<void> init() async {
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _sfxPlayer.setSource(AssetSource('sounds/button.mp3'));
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
    await _sfxPlayer.resume();
  }
}
