import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing app settings and preferences
class SettingsProvider extends ChangeNotifier {
  bool _soundEnabled = true;
  double _volume = 0.7;
  BoardTheme _boardTheme = BoardTheme.classic;
  bool _showLegalMoves = true;
  double _animationSpeed = 1.0; // 0.5 = slow, 1.0 = normal, 1.5 = fast

  bool get soundEnabled => _soundEnabled;
  double get volume => _volume;
  BoardTheme get boardTheme => _boardTheme;
  bool get showLegalMoves => _showLegalMoves;
  double get animationSpeed => _animationSpeed;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    _volume = prefs.getDouble('volume') ?? 0.7;
    _boardTheme = BoardTheme.values[prefs.getInt('boardTheme') ?? 0];
    _showLegalMoves = prefs.getBool('showLegalMoves') ?? true;
    _animationSpeed = prefs.getDouble('animationSpeed') ?? 1.0;
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', enabled);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('volume', _volume);
    notifyListeners();
  }

  Future<void> setBoardTheme(BoardTheme theme) async {
    _boardTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('boardTheme', theme.index);
    notifyListeners();
  }

  Future<void> setShowLegalMoves(bool show) async {
    _showLegalMoves = show;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showLegalMoves', show);
    notifyListeners();
  }

  Future<void> setAnimationSpeed(double speed) async {
    _animationSpeed = speed.clamp(0.5, 2.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('animationSpeed', _animationSpeed);
    notifyListeners();
  }

  /// Get light square color for current theme
  Color getLightSquareColor() {
    switch (_boardTheme) {
      case BoardTheme.classic:
        return const Color(0xFFF0D9B5);
      case BoardTheme.modern:
        return const Color(0xFFEBECD0);
      case BoardTheme.blue:
        return const Color(0xFFDEE3E6);
      case BoardTheme.green:
        return const Color(0xFFAAD751);
      case BoardTheme.purple:
        return const Color(0xFFCBB4D4);
    }
  }

  /// Get dark square color for current theme
  Color getDarkSquareColor() {
    switch (_boardTheme) {
      case BoardTheme.classic:
        return const Color(0xFFB58863);
      case BoardTheme.modern:
        return const Color(0xFF769656);
      case BoardTheme.blue:
        return const Color(0xFF8CA2AD);
      case BoardTheme.green:
        return const Color(0xFF769656);
      case BoardTheme.purple:
        return const Color(0xFF8B7FA8);
    }
  }
}

enum BoardTheme { classic, modern, blue, green, purple }

extension BoardThemeExtension on BoardTheme {
  String get displayName {
    switch (this) {
      case BoardTheme.classic:
        return 'Classic';
      case BoardTheme.modern:
        return 'Modern';
      case BoardTheme.blue:
        return 'Blue';
      case BoardTheme.green:
        return 'Green';
      case BoardTheme.purple:
        return 'Purple';
    }
  }
}
