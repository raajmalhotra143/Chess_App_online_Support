import 'package:flutter/material.dart';
import 'package:myapp/data/models/chess_piece.dart';
import 'package:myapp/data/models/position.dart';
import 'package:myapp/data/models/chess_move.dart';
import 'package:myapp/domain/chess_engine/chess_board.dart';
import 'package:myapp/domain/chess_engine/move_validator.dart';
import 'package:myapp/domain/chess_engine/game_rules.dart';

/// Manages the chess game state using Provider
class GameStateProvider extends ChangeNotifier {
  late ChessBoard _board;
  GameStatus _gameStatus;
  Position? _selectedPosition;
  List<ChessMove> _legalMovesForSelectedPiece;
  final PieceColor _playerColor; // Color assigned to the player
  final bool _isAIGame; // Whether playing against AI
  final bool _isLocalMultiplayer; // Whether local 2-player mode

  GameStateProvider({
    PieceColor playerColor = PieceColor.white,
    bool isAIGame = false,
    bool isLocalMultiplayer = false,
  }) : _board = ChessBoard.standardSetup(),
       _gameStatus = GameStatus.ongoing,
       _legalMovesForSelectedPiece = [],
       _playerColor = playerColor,
       _isAIGame = isAIGame,
       _isLocalMultiplayer = isLocalMultiplayer;

  // Getters
  ChessBoard get board => _board;
  GameStatus get gameStatus => _gameStatus;
  Position? get selectedPosition => _selectedPosition;
  List<ChessMove> get legalMovesForSelectedPiece => _legalMovesForSelectedPiece;
  PieceColor get currentTurn => _board.currentTurn;
  PieceColor get playerColor => _playerColor;
  PieceColor get aiColor =>
      _playerColor == PieceColor.white ? PieceColor.black : PieceColor.white;
  bool get isAIGame => _isAIGame;
  bool get isLocalMultiplayer => _isLocalMultiplayer;
  List<ChessMove> get moveHistory => _board.moveHistory;
  ChessMove? get lastMove =>
      _board.moveHistory.isNotEmpty ? _board.moveHistory.last : null;
  List<ChessPiece> get capturedPieces => _board.capturedPieces;

  /// Selects a piece at the given position
  void selectPiece(Position position) {
    final piece = _board.getPieceAt(position);

    // Can only select pieces of the current turn
    if (piece == null || piece.color != _board.currentTurn) {
      _selectedPosition = null;
      _legalMovesForSelectedPiece = [];
      notifyListeners();
      return;
    }

    _selectedPosition = position;
    _legalMovesForSelectedPiece = MoveValidator.generateLegalMoves(
      _board,
      position,
    );
    notifyListeners();
  }

  /// Attempts to move a piece to the given position
  bool movePiece(Position to) {
    if (_selectedPosition == null) return false;

    // Find the move in legal moves
    final move = _legalMovesForSelectedPiece.firstWhere(
      (m) => m.to == to,
      orElse: () => ChessMove(from: _selectedPosition!, to: to),
    );

    // Check if the move is legal
    if (!_legalMovesForSelectedPiece.contains(move)) {
      return false;
    }

    // Make the move
    _board.makeMove(move);

    // Update game status
    _gameStatus = GameRules.getGameStatus(_board);

    // Clear selection
    _selectedPosition = null;
    _legalMovesForSelectedPiece = [];

    notifyListeners();
    return true;
  }

  /// Handles click/tap on a square
  void onSquareTapped(Position position) {
    if (_gameStatus != GameStatus.ongoing && _gameStatus != GameStatus.check) {
      return; // Game is over
    }

    // If a piece is already selected, try to move it
    if (_selectedPosition != null) {
      final moved = movePiece(position);
      if (!moved) {
        // If move failed, try selecting the clicked square instead
        selectPiece(position);
      }
    } else {
      // No piece selected, select the clicked piece
      selectPiece(position);
    }
  }

  /// Checks if a position is a valid move target for the selected piece
  bool isValidMoveTarget(Position position) {
    return _legalMovesForSelectedPiece.any((move) => move.to == position);
  }

  /// Starts a new game
  void newGame() {
    _board = ChessBoard.standardSetup();
    _gameStatus = GameStatus.ongoing;
    _selectedPosition = null;
    _legalMovesForSelectedPiece = [];
    notifyListeners();
  }

  /// Undoes the last move (if possible)
  void undoMove() {
    // This would require storing previous board states
    // For now, this is a placeholder
    // TODO: Implement undo functionality with board state history
    notifyListeners();
  }

  /// Offers a draw (AI or multiplayer would accept/reject)
  void offerDraw() {
    // Placeholder for draw offer functionality
    // In a complete implementation, this would:
    // 1. Send draw offer to opponent (AI or other player)
    // 2. Wait for acceptance/rejection
    // 3. Update game status if accepted
  }

  /// Resigns the game
  void resign() {
    _gameStatus = GameStatus.checkmate;
    notifyListeners();
  }

  /// Gets the winner (if game is over)
  PieceColor? getWinner() {
    return GameRules.getWinner(_board, _gameStatus);
  }

  /// Checks if the game is over
  bool get isGameOver {
    return _gameStatus == GameStatus.checkmate ||
        _gameStatus == GameStatus.stalemate ||
        _gameStatus == GameStatus.draw;
  }
}
