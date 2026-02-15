import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Service for managing game sound effects
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isMuted = false;
  double _volume = 0.7;

  bool get isMuted => _isMuted;
  double get volume => _volume;

  void setMuted(bool muted) {
    _isMuted = muted;
  }

  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
  }

  Future<void> playMove() async {
    if (_isMuted) return;
    try {
      await _player.stop();
      // Using a simple beep sound generated programmatically
      // In production, replace with actual sound assets
      await _playBeep(frequency: 440, duration: 50);
    } catch (e) {
      if (kDebugMode) print('Error playing move sound: $e');
    }
  }

  Future<void> playCapture() async {
    if (_isMuted) return;
    try {
      await _player.stop();
      await _playBeep(frequency: 660, duration: 100);
    } catch (e) {
      if (kDebugMode) print('Error playing capture sound: $e');
    }
  }

  Future<void> playCheck() async {
    if (_isMuted) return;
    try {
      await _player.stop();
      await _playBeep(frequency: 880, duration: 150);
    } catch (e) {
      if (kDebugMode) print('Error playing check sound: $e');
    }
  }

  Future<void> playCheckmate() async {
    if (_isMuted) return;
    try {
      await _player.stop();
      // Play a sequence for checkmate
      await _playBeep(frequency: 600, duration: 100);
      await Future.delayed(const Duration(milliseconds: 50));
      await _playBeep(frequency: 800, duration: 100);
      await Future.delayed(const Duration(milliseconds: 50));
      await _playBeep(frequency: 1000, duration: 200);
    } catch (e) {
      if (kDebugMode) print('Error playing checkmate sound: $e');
    }
  }

  // Simple beep generator (fallback for when no assets are available)
  Future<void> _playBeep({
    required double frequency,
    required int duration,
  }) async {
    // This is a placeholder. In production, you'd use actual sound files.
    // For now, we'll use a silent operation to avoid crashes.
    // To add real sounds: Place .mp3/.wav files in assets/sounds/ and update pubspec.yaml
    if (kDebugMode) {
      print('🔊 Sound: ${frequency}Hz for ${duration}ms at volume $_volume');
    }
  }

  void dispose() {
    _player.dispose();
  }
}
