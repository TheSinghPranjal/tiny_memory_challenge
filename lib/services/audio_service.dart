import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

enum GameSound {
  blink,
  correct,
  wrong,
  stageClear,
  levelClear,
  countdown,
  gameOver,
  buttonTap,
}

class AudioService {
  AudioService();

  final AudioPlayer _sfx = AudioPlayer();
  final AudioPlayer _music = AudioPlayer();

  bool soundEnabled = true;
  bool musicEnabled = true;
  bool vibrationEnabled = true;

  bool _initialized = false;
  bool _musicPlaying = false;

  Future<void> init() async {
    if (_initialized) return;
    await _sfx.setReleaseMode(ReleaseMode.stop);
    await _music.setReleaseMode(ReleaseMode.loop);
    await _music.setVolume(0.25);
    _initialized = true;
  }

  Future<void> dispose() async {
    await _sfx.dispose();
    await _music.dispose();
  }

  void applyToggles({
    required bool sound,
    required bool music,
    required bool vibration,
  }) {
    soundEnabled = sound;
    musicEnabled = music;
    vibrationEnabled = vibration;
    if (!musicEnabled) {
      stopMusic();
    }
  }

  Future<void> play(GameSound sound) async {
    if (!soundEnabled) return;
    final asset = switch (sound) {
      GameSound.blink => 'sounds/blink.wav',
      GameSound.correct => 'sounds/correct.wav',
      GameSound.wrong => 'sounds/wrong.wav',
      GameSound.stageClear => 'sounds/stage_clear.wav',
      GameSound.levelClear => 'sounds/level_clear.wav',
      GameSound.countdown => 'sounds/countdown.wav',
      GameSound.gameOver => 'sounds/game_over.wav',
      GameSound.buttonTap => 'sounds/button_tap.wav',
    };
    try {
      await _sfx.stop();
      await _sfx.play(AssetSource(asset));
    } catch (_) {
      // Ignore missing/failed audio so gameplay never crashes.
    }
  }

  Future<void> startMusic() async {
    if (!musicEnabled) return;
    if (_musicPlaying) return;
    try {
      await _music.play(AssetSource('sounds/music_loop.mp3'));
      _musicPlaying = true;
    } catch (_) {
      _musicPlaying = false;
    }
  }

  Future<void> stopMusic() async {
    _musicPlaying = false;
    try {
      await _music.stop();
    } catch (_) {}
  }

  Future<void> hapticLight() async {
    if (!vibrationEnabled) return;
    await HapticFeedback.lightImpact();
  }

  Future<void> hapticHeavy() async {
    if (!vibrationEnabled) return;
    await HapticFeedback.heavyImpact();
  }

  Future<void> hapticSuccess() async {
    if (!vibrationEnabled) return;
    await HapticFeedback.mediumImpact();
  }

  Future<void> playButtonTap() => play(GameSound.buttonTap);
}
