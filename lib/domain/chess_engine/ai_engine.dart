import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../data/models/chess_move.dart';
import '../../data/models/chess_piece.dart';
import '../../data/models/position.dart';
import 'chess_board.dart';
import 'game_rules.dart';
import 'move_validator.dart';

/// AI Engine using Minimax algorithm with Alpha-Beta pruning
class AIEngine {
  /// Gets the best move for the current board state and difficulty level
  /// Runs in a separate isolate to prevent UI freezing
  static Future<ChessMove?> getBestMove(
    ChessBoard board,
    int difficulty,
  ) async {
    // For very low difficulty, just return a random move quickly
    if (difficulty <= 1) {
      final moves = GameRules.getAllLegalMoves(board);
      if (moves.isEmpty) return null;
      return moves[Random().nextInt(moves.length)];
    }

    return compute(_isolateEntry, _AIParams(board, difficulty));
  }

  /// Entry point for the isolate
  static ChessMove? _isolateEntry(_AIParams params) {
    final ai = _MinimaxAI(params.difficulty);
    return ai.findBestMove(params.board);
  }
}

class _AIParams {
  final ChessBoard board;
  final int difficulty;

  _AIParams(this.board, this.difficulty);
}

class _MinimaxAI {
  final int difficulty;
  static const int _infinity = 1000000;

  _MinimaxAI(this.difficulty);

  int get _maxDepth {
    if (difficulty <= 3) return 2;
    if (difficulty <= 6) return 3;
    if (difficulty <= 10) return 4;
    return 5; // Deep search for high levels (careful with performance)
  }

  ChessMove? findBestMove(ChessBoard board) {
    final legalMoves = GameRules.getAllLegalMoves(board);
    if (legalMoves.isEmpty) return null;

    // Shuffle moves to add a bit of randomness to equal moves
    legalMoves.shuffle();

    ChessMove? bestMove;
    int bestValue = -_infinity;
    int alpha = -_infinity;
    int beta = _infinity;

    for (final move in legalMoves) {
      final boardCopy = board.copy();
      boardCopy.makeMove(move);

      // Minimax
      final value = -_minimax(
        boardCopy,
        _maxDepth - 1,
        -beta,
        -alpha,
        board.currentTurn.opposite,
      );

      if (value > bestValue) {
        bestValue = value;
        bestMove = move;
      }

      alpha = max(alpha, value);
    }

    return bestMove;
  }

  int _minimax(
    ChessBoard board,
    int depth,
    int alpha,
    int beta,
    PieceColor color,
  ) {
    if (depth == 0) {
      return _evaluate(board, color);
    }

    final legalMoves = GameRules.getAllLegalMoves(board);

    // Checkmate or Stalemate detection
    if (legalMoves.isEmpty) {
      if (MoveValidator.isKingInCheck(board, color)) {
        return -(_infinity -
            (_maxDepth - depth)); // Checkmate (prefer faster mates)
      }
      return 0; // Stalemate = Draw
    }

    int bestValue = -_infinity;

    for (final move in legalMoves) {
      final boardCopy = board.copy();
      boardCopy.makeMove(move);

      final value = -_minimax(
        boardCopy,
        depth - 1,
        -beta,
        -alpha,
        color.opposite,
      );

      bestValue = max(bestValue, value);
      alpha = max(alpha, value);

      if (alpha >= beta) {
        break; // Pruning
      }
    }

    return bestValue;
  }

  /// Evaluation function
  /// Positive value is good for [color], negative is bad.
  int _evaluate(ChessBoard board, PieceColor color) {
    int score = 0;

    // Material values
    const pieceValues = {
      PieceType.pawn: 100,
      PieceType.knight: 320,
      PieceType.bishop: 330,
      PieceType.rook: 500,
      PieceType.queen: 900,
      PieceType.king: 20000,
    };

    // Evaluate material and position
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.getPieceAt(Position(rank: r, file: c));
        if (piece != null) {
          int value = pieceValues[piece.type] ?? 0;

          // Add positional score
          value += _getPieceSquareValue(piece, r, c);

          if (piece.color == color) {
            score += value;
          } else {
            score -= value;
          }
        }
      }
    }

    return score;
  }

  // Simplified Piece-Square Tables (adapted for 0-7 coordinates)
  // These encourage developing pieces to the center
  int _getPieceSquareValue(ChessPiece piece, int r, int c) {
    // Flip rank for black pieces to mirror the board
    final rank = piece.color == PieceColor.white ? r : 7 - r;
    final file = c; // Symmetric for file usually

    switch (piece.type) {
      case PieceType.pawn:
        return _pawnTable[rank][file];
      case PieceType.knight:
        return _knightTable[rank][file];
      case PieceType.bishop:
        return _bishopTable[rank][file];
      case PieceType.rook:
        return _rookTable[rank][file];
      case PieceType.queen:
        return _queenTable[rank][file];
      case PieceType.king:
        return _kingMidGameTable[rank][file];
    }
  }

  // Tables (Values from standard chess engines, simplified)
  static const _pawnTable = [
    [0, 0, 0, 0, 0, 0, 0, 0],
    [50, 50, 50, 50, 50, 50, 50, 50],
    [10, 10, 20, 30, 30, 20, 10, 10],
    [5, 5, 10, 25, 25, 10, 5, 5],
    [0, 0, 0, 20, 20, 0, 0, 0],
    [5, -5, -10, 0, 0, -10, -5, 5],
    [5, 10, 10, -20, -20, 10, 10, 5],
    [0, 0, 0, 0, 0, 0, 0, 0],
  ];

  static const _knightTable = [
    [-50, -40, -30, -30, -30, -30, -40, -50],
    [-40, -20, 0, 0, 0, 0, -20, -40],
    [-30, 0, 10, 15, 15, 10, 0, -30],
    [-30, 5, 15, 20, 20, 15, 5, -30],
    [-30, 0, 15, 20, 20, 15, 0, -30],
    [-30, 5, 10, 15, 15, 10, 5, -30],
    [-40, -20, 0, 5, 5, 0, -20, -40],
    [-50, -40, -30, -30, -30, -30, -40, -50],
  ];

  static const _bishopTable = [
    [-20, -10, -10, -10, -10, -10, -10, -20],
    [-10, 0, 0, 0, 0, 0, 0, -10],
    [-10, 0, 5, 10, 10, 5, 0, -10],
    [-10, 5, 5, 10, 10, 5, 5, -10],
    [-10, 0, 10, 10, 10, 10, 0, -10],
    [-10, 10, 10, 10, 10, 10, 10, -10],
    [-10, 5, 0, 0, 0, 0, 5, -10],
    [-20, -10, -10, -10, -10, -10, -10, -20],
  ];

  static const _rookTable = [
    [0, 0, 0, 0, 0, 0, 0, 0],
    [5, 10, 10, 10, 10, 10, 10, 5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [0, 0, 0, 5, 5, 0, 0, 0],
  ];

  static const _queenTable = [
    [-20, -10, -10, -5, -5, -10, -10, -20],
    [-10, 0, 0, 0, 0, 0, 0, -10],
    [-10, 0, 5, 5, 5, 5, 0, -10],
    [-5, 0, 5, 5, 5, 5, 0, -5],
    [0, 0, 5, 5, 5, 5, 0, -5],
    [-10, 5, 5, 5, 5, 5, 0, -10],
    [-10, 0, 5, 0, 0, 0, 0, -10],
    [-20, -10, -10, -5, -5, -10, -10, -20],
  ];

  static const _kingMidGameTable = [
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-20, -30, -30, -40, -40, -30, -30, -20],
    [-10, -20, -20, -20, -20, -20, -20, -10],
    [20, 20, 0, 0, 0, 0, 20, 20],
    [20, 30, 10, 0, 0, 10, 30, 20],
  ];
}
