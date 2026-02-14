import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/position.dart';
import '../../presentation/providers/game_state_provider.dart';

/// Chess board widget that displays the 8x8 grid and pieces
class ChessBoardWidget extends StatelessWidget {
  const ChessBoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
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
                  final rank = 7 - rankIndex;
                  return Expanded(
                    child: Row(
                      children: List.generate(8, (file) {
                        final position = Position(rank: rank, file: file);
                        return Expanded(
                          child: _buildSquare(
                            context,
                            position,
                            gameState,
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
    GameStateProvider gameState,
    int rank,
    int file,
  ) {
    final piece = gameState.board.getPieceAt(position);
    final isSelected = gameState.selectedPosition == position;
    final isValidMove = gameState.isValidMoveTarget(position);
    final isLight = (rank + file) % 2 != 0;
    final isLastMoveFrom = gameState.lastMove?.from == position;
    final isLastMoveTo = gameState.lastMove?.to == position;

    // Determine square color
    Color squareColor;
    if (isSelected) {
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
      child: Container(
        decoration: BoxDecoration(
          color: squareColor,
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
