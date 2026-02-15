import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/position.dart';
import '../../data/models/chess_piece.dart';
import '../../domain/chess_engine/game_rules.dart';
import '../../presentation/providers/game_state_provider.dart';

/// Chess board widget that displays the 8x8 grid and pieces
class ChessBoardWidget extends StatelessWidget {
  const ChessBoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Selector instead of Consumer for better performance
    // Only rebuild when board state, selected position, legal moves, or flip state changes
    return Selector<GameStateProvider, _BoardState>(
      selector: (context, gameState) => _BoardState(
        board: gameState.board,
        selectedPosition: gameState.selectedPosition,
        legalMoves: gameState.legalMovesForSelectedPiece,
        isBoardFlipped: gameState.isBoardFlipped,
        lastMove: gameState.lastMove,
        isKingInCheck: gameState.gameStatus == GameStatus.check,
        currentTurn: gameState.board.currentTurn,
      ),
      shouldRebuild: (previous, next) =>
          previous.board != next.board ||
          previous.selectedPosition != next.selectedPosition ||
          previous.legalMoves != next.legalMoves ||
          previous.isBoardFlipped != next.isBoardFlipped ||
          previous.lastMove != next.lastMove ||
          previous.isKingInCheck != next.isKingInCheck ||
          previous.currentTurn != next.currentTurn,
      builder: (context, boardState, child) {
        return AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Column(
                children: List.generate(8, (rankIndex) {
                  final rank = boardState.isBoardFlipped
                      ? rankIndex
                      : 7 - rankIndex;

                  return Expanded(
                    child: Row(
                      children: List.generate(8, (fileIndex) {
                        final file = boardState.isBoardFlipped
                            ? 7 - fileIndex
                            : fileIndex;

                        final position = Position(rank: rank, file: file);
                        return Expanded(
                          child: _buildSquare(
                            context,
                            position,
                            boardState,
                            rank,
                            file,
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSquare(
    BuildContext context,
    Position position,
    _BoardState boardState,
    int rank,
    int file,
  ) {
    final piece = boardState.board.getPieceAt(position);
    final isSelected = boardState.selectedPosition == position;
    final isValidMove = boardState.legalMoves.any(
      (move) => move.to == position,
    );
    final isLight = (rank + file) % 2 != 0;
    final isLastMoveFrom = boardState.lastMove?.from == position;
    final isLastMoveTo = boardState.lastMove?.to == position;

    // Check if this square contains a king in check
    final isKingInCheck =
        piece != null &&
        piece.type == PieceType.king &&
        boardState.isKingInCheck &&
        piece.color == boardState.currentTurn;

    // Access gameState only for onTap (doesn't cause rebuild)
    final gameState = Provider.of<GameStateProvider>(context, listen: false);

    // Determine square color
    Color squareColor;
    if (isKingInCheck) {
      squareColor = const Color(
        0xFFFF5252,
      ).withValues(alpha: 0.7); // Red glow for check
    } else if (isSelected) {
      squareColor = const Color(0xFF9DB4FF); // Blue highlight
    } else if (isLastMoveFrom || isLastMoveTo) {
      squareColor = const Color(0xFFCDD26A); // Yellow highlight for last move
    } else {
      squareColor = isLight
          ? const Color(0xFFF0D9B5) // Light square
          : const Color(0xFFB58863); // Dark square
    }

    return GestureDetector(
      onTap: () => gameState.onSquareTapped(position),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: squareColor,
          // Add box shadow for king in check
          boxShadow: isKingInCheck
              ? [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.6),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
          // Add diagonal stripes to light squares
          image: isLight && !isSelected && !isLastMoveFrom && !isLastMoveTo
              ? DecorationImage(
                  image: const AssetImage('assets/images/stripe_pattern.png'),
                  repeat: ImageRepeat.repeat,
                  opacity: 0.15,
                  fit: BoxFit.none,
                )
              : null,
        ),
        child: CustomPaint(
          painter: isLight && !isSelected && !isLastMoveFrom && !isLastMoveTo
              ? DiagonalStripePainter()
              : null,
          child: Stack(
            children: [
              // Valid move indicator
              if (isValidMove)
                Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              // Chess piece
              if (piece != null)
                Center(
                  child: Text(
                    piece.symbol,
                    style: const TextStyle(fontSize: 42, height: 1.0),
                  ),
                ),
              // Coordinate labels
              if (file == 0)
                Positioned(
                  left: 4,
                  top: 4,
                  child: Text(
                    '${rank + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isLight
                          ? const Color(0xFFB58863)
                          : const Color(0xFFF0D9B5),
                    ),
                  ),
                ),
              if (rank == 0)
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Text(
                    String.fromCharCode('a'.codeUnitAt(0) + file),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isLight
                          ? const Color(0xFFB58863)
                          : const Color(0xFFF0D9B5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for diagonal stripes on light squares
class DiagonalStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.08)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const spacing = 6.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Immutable state class for optimized board rendering
class _BoardState {
  final dynamic board; // ChessBoard
  final Position? selectedPosition;
  final List<dynamic> legalMoves; // List<ChessMove>
  final bool isBoardFlipped;
  final dynamic lastMove; // ChessMove?
  final bool isKingInCheck;
  final dynamic currentTurn; // PieceColor

  const _BoardState({
    required this.board,
    required this.selectedPosition,
    required this.legalMoves,
    required this.isBoardFlipped,
    required this.lastMove,
    required this.isKingInCheck,
    required this.currentTurn,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _BoardState &&
          runtimeType == other.runtimeType &&
          board == other.board &&
          selectedPosition == other.selectedPosition &&
          _listEquals(legalMoves, other.legalMoves) &&
          isBoardFlipped == other.isBoardFlipped &&
          lastMove == other.lastMove &&
          isKingInCheck == other.isKingInCheck &&
          currentTurn == other.currentTurn;

  @override
  int get hashCode =>
      board.hashCode ^
      (selectedPosition?.hashCode ?? 0) ^
      Object.hashAll(legalMoves) ^
      isBoardFlipped.hashCode ^
      (lastMove?.hashCode ?? 0) ^
      isKingInCheck.hashCode ^
      (currentTurn?.hashCode ?? 0);

  bool _listEquals(List a, List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
