import 'package:flutter/material.dart';
import '../../data/models/chess_piece.dart';
import '../../data/models/position.dart';
import '../../data/models/chess_move.dart';
import '../../domain/chess_engine/chess_board.dart';
import '../../domain/chess_engine/move_validator.dart';
import '../../domain/chess_engine/game_rules.dart';
import '../../domain/chess_engine/ai_engine.dart';

/// Manages the chess game state using Provider
class GameStateProvider extends ChangeNotifier {
  late ChessBoard _board;
  GameStatus _gameStatus;
  Position? _selectedPosition;
  List<ChessMove> _legalMovesForSelectedPiece;
  final PieceColor _playerColor; // Color assigned to the player
  final bool _isAIGame; // Whether playing against AI
  final bool _isLocalMultiplayer; // Whether local 2-player mode
  final int _aiDifficulty; // AI difficulty level (1-15)
  bool _isAIThinking = false;
  final List<ChessBoard> _boardHistory = [];
  bool _isBoardFlipped = false;

  GameStateProvider({
    PieceColor playerColor = PieceColor.white,
    bool isAIGame = false,
    bool isLocalMultiplayer = false,
    int aiDifficulty = 1,
    String? fen,
  }) : _board = fen != null
           ? ChessBoard.fromFEN(fen)
           : ChessBoard.standardSetup(),
       _gameStatus = GameStatus.ongoing,
       _legalMovesForSelectedPiece = [],
       _playerColor = playerColor,
       _isAIGame = isAIGame,
       _isLocalMultiplayer = isLocalMultiplayer,
       _aiDifficulty = aiDifficulty {
    // If AI plays white (player selected black), AI moves first
    if (_isAIGame && _playerColor == PieceColor.black) {
      _makeAIMove();
      _isBoardFlipped = true; // Auto-flip for black
    }
  }

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
  bool get isAIThinking => _isAIThinking;
  bool get isBoardFlipped => _isBoardFlipped;
  List<ChessMove> get moveHistory => _board.moveHistory;
  ChessMove? get lastMove =>
      _board.moveHistory.isNotEmpty ? _board.moveHistory.last : null;
  List<ChessPiece> get capturedPieces => _board.capturedPieces;

  void toggleBoardFlip() {
    _isBoardFlipped = !_isBoardFlipped;
    notifyListeners();
  }

  /// Selects a piece at the given position
  void selectPiece(Position position) {
    if (_isAIThinking) return; // Prevent interaction while AI thinks

    // In AI mode, prevent selecting opponent's pieces if not your turn
    if (_isAIGame && _board.currentTurn != _playerColor) return;

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
    if (_isAIThinking) return false;
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

    // Save state before move
    _boardHistory.add(_board.copy());

    // Make the move
    _board.makeMove(move);

    // Update game status
    _gameStatus = GameRules.getGameStatus(_board);

    // Clear selection
    _selectedPosition = null;
    _legalMovesForSelectedPiece = [];

    notifyListeners();

    // Trigger AI move if applicable
    if (_isAIGame &&
        _gameStatus == GameStatus.ongoing &&
        _board.currentTurn != _playerColor) {
      _makeAIMove();
    }

    return true;
  }

  /// Makes the AI move
  Future<void> _makeAIMove() async {
    _isAIThinking = true;
    notifyListeners();

    try {
      // Small delay for UX so it doesn't feel instant/robotic
      await Future.delayed(const Duration(milliseconds: 500));

      // AI Logic shouldn't update history?
      // Actually we WANT to save history before AI move so we can undo it?
      // Yes, if we want to undo the AI's move AND our move.
      // But if we undo, we want to go back to OUR turn.

      final bestMove = await AIEngine.getBestMove(_board, _aiDifficulty);

      if (bestMove != null) {
        // Save history before AI move too
        _boardHistory.add(_board.copy());

        _board.makeMove(bestMove);
        _gameStatus = GameRules.getGameStatus(_board);
      } else {
        // AI has no moves? Should be handled by game status check, but just in case
        if (GameRules.getGameStatus(_board) == GameStatus.ongoing) {
          // Check for stalemate/mate if not already detected
          _gameStatus = GameRules.getGameStatus(_board);
        }
      }
    } finally {
      _isAIThinking = false;
      notifyListeners();
    }
  }

  /// Handles click/tap on a square
  void onSquareTapped(Position position) {
    if (_gameStatus != GameStatus.ongoing && _gameStatus != GameStatus.check) {
      return; // Game is over
    }

    if (_isAIThinking) return;

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
    _boardHistory.clear();
    _isAIThinking = false;

    notifyListeners();

    // If AI plays white, move first
    if (_isAIGame && _playerColor == PieceColor.black) {
      _makeAIMove();
    }
  }

  /// Undoes the last move (if possible)
  void undoMove() {
    if (_isAIThinking) return;
    if (_boardHistory.isEmpty) return;

    // If AI game, we need to undo 2 moves (AI's move + Player's move)
    // unless the AI just played and it's our turn?
    // Usually AI moves immediately. So we are likely at Player's turn.
    // _boardHistory should have: [Start, ... , PlayerMoved, AIMoved]
    // Current board is after AI move.

    if (_isAIGame) {
      if (_boardHistory.length >= 2) {
        _boardHistory
            .removeLast(); // This was the state BEFORE AI move (i.e. after Player move)
        _board = _boardHistory
            .removeLast(); // This was state BEFORE Player move
      } else if (_boardHistory.isNotEmpty) {
        // Edge case: maybe only 1 move happened (e.g. Player move, AI crashed?)
        _board = _boardHistory.removeLast();
      }
    } else {
      // Local multiplayer or puzzle: undo one move
      _board = _boardHistory.removeLast();
    }

    _gameStatus = GameRules.getGameStatus(_board);
    _selectedPosition = null;
    _legalMovesForSelectedPiece = [];
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
    if (_isAIGame) {
      // You lose
      _gameStatus = GameStatus.checkmate; // effectively
      // Logic to show "Black/White wins"
    }
    _gameStatus = GameStatus.checkmate; // treat as mate for now
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
