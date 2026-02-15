import 'package:flutter/material.dart';
import '../../data/models/chess_piece.dart';

/// Game modes available
enum GameMode { vsAI, localTwoPlayer, online, puzzle }

/// Manages game setup configuration before starting a game
class GameSetupProvider extends ChangeNotifier {
  PieceColor _selectedPlayerColor = PieceColor.white;
  GameMode _gameMode = GameMode.vsAI;
  int _aiDifficultyLevel = 5; // 1-15
  bool _isColorLocked = false;

  // Getters
  PieceColor get selectedPlayerColor => _selectedPlayerColor;
  PieceColor get aiColor => _selectedPlayerColor == PieceColor.white
      ? PieceColor.black
      : PieceColor.white;
  GameMode get gameMode => _gameMode;
  int get aiDifficultyLevel => _aiDifficultyLevel;
  bool get isColorLocked => _isColorLocked;

  /// Sets the player's color choice
  void setPlayerColor(PieceColor color) {
    if (_isColorLocked) return; // Cannot change color after game starts
    _selectedPlayerColor = color;
    notifyListeners();
  }

  /// Toggles player color (white <-> black)
  void togglePlayerColor() {
    if (_isColorLocked) return;
    _selectedPlayerColor = _selectedPlayerColor == PieceColor.white
        ? PieceColor.black
        : PieceColor.white;
    notifyListeners();
  }

  /// Sets the game mode
  void setGameMode(GameMode mode) {
    _gameMode = mode;
    notifyListeners();
  }

  /// Sets AI difficulty level (1-15)
  void setAIDifficulty(int level) {
    if (level < 1 || level > 15) return;
    _aiDifficultyLevel = level;
    notifyListeners();
  }

  /// Locks the color selection (called when game starts)
  void lockColor() {
    _isColorLocked = true;
    notifyListeners();
  }

  /// Unlocks color selection (called when returning to setup)
  void unlockColor() {
    _isColorLocked = false;
    notifyListeners();
  }

  /// Resets all settings to defaults
  void reset() {
    _selectedPlayerColor = PieceColor.white;
    _gameMode = GameMode.vsAI;
    _aiDifficultyLevel = 5;
    _isColorLocked = false;
    notifyListeners();
  }

  /// Whether the current game mode requires AI
  bool get requiresAI => _gameMode == GameMode.vsAI;

  /// Whether the current game mode is local multiplayer
  bool get isLocalMultiplayer => _gameMode == GameMode.localTwoPlayer;

  /// Whether the current game mode is online
  bool get isOnline => _gameMode == GameMode.online;

  /// Whether the current game mode is puzzle
  bool get isPuzzleMode => _gameMode == GameMode.puzzle;

  /// Gets a user-friendly description of AI difficulty
  String get aiDifficultyDescription {
    if (_aiDifficultyLevel <= 3) {
      return 'Beginner';
    } else if (_aiDifficultyLevel <= 6) {
      return 'Easy';
    } else if (_aiDifficultyLevel <= 9) {
      return 'Medium';
    } else if (_aiDifficultyLevel <= 12) {
      return 'Hard';
    } else {
      return 'Expert';
    }
  }
}
