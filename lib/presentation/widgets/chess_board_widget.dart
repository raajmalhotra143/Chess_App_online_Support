import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/position.dart';
import '../../presentation/providers/game_state_provider.dart';
import '../../core/theme/app_theme.dart';

/// Chess board widget that displays the 8x8 grid and pieces
class ChessBoardWidget extends StatelessWidget {
  const ChessBoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: AppTheme.boardBorder, width: 8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final squareSize = constraints.maxWidth / 8;
              return Stack(
                children: [
                  // Layer 1: The Board Grid (Squares & Highlights)
                  _buildBoardGrid(context, squareSize),

                  // Layer 2: Animated Pieces
                  _buildAnimatedPieces(context, squareSize),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBoardGrid(BuildContext context, double squareSize) {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
        return Column(
          children: List.generate(8, (rankIndex) {
            final rank = 7 - rankIndex;
            return Row(
              children: List.generate(8, (file) {
                final position = Position(rank: rank, file: file);
                final isLight = (rank + file) % 2 != 0;
                final isSelected = gameState.selectedPosition == position;
                final isValidMove = gameState.isValidMoveTarget(position);
                final isLastMoveFrom = gameState.lastMove?.from == position;
                final isLastMoveTo = gameState.lastMove?.to == position;

                Color color = isLight
                    ? AppTheme.premiumLightSquare
                    : AppTheme.premiumDarkSquare;

                if (isSelected) {
                  color = AppTheme.selectedSquare.withValues(alpha: 0.8);
                } else if (isLastMoveFrom || isLastMoveTo) {
                  color = AppTheme.selectedSquare.withValues(alpha: 0.5);
                }

                return GestureDetector(
                  onTap: () => gameState.onSquareTapped(position),
                  child: Container(
                    width: squareSize,
                    height: squareSize,
                    color: color,
                    child: Stack(
                      children: [
                        // Coordinates
                        if (file == 0)
                          Positioned(
                            left: 2,
                            top: 2,
                            child: Text(
                              '${rank + 1}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isLight
                                    ? AppTheme.premiumDarkSquare
                                    : AppTheme.premiumLightSquare,
                              ),
                            ),
                          ),
                        if (rankIndex == 7)
                          Positioned(
                            right: 2,
                            bottom: 2,
                            child: Text(
                              _getFileName(file),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isLight
                                    ? AppTheme.premiumDarkSquare
                                    : AppTheme.premiumLightSquare,
                              ),
                            ),
                          ),

                        // Valid Move Marker
                        if (isValidMove)
                          Center(
                            child: Container(
                              width: squareSize * 0.3,
                              height: squareSize * 0.3,
                              decoration: BoxDecoration(
                                color: AppTheme.validMoveHighlight,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            );
          }),
        );
      },
    );
  }

  Widget _buildAnimatedPieces(BuildContext context, double squareSize) {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
        // We render all pieces based on the board state
        // To animate, we use AnimatedPositioned

        final pieces = <Widget>[];

        // Iterate through the board to find pieces
        for (int rank = 0; rank < 8; rank++) {
          for (int file = 0; file < 8; file++) {
            final position = Position(rank: rank, file: file);
            final piece = gameState.board.getPieceAt(position);

            if (piece != null) {
              // We use specific keys for pieces to allow Flutter to track them for animation
              // A simple key based on piece position won't work for movement animation
              // Ideally, pieces should have unique IDs.
              // unique KEY is tricky without IDs.
              // BUT, for simple "snap" animation, we can just position them.
              // For REAL movement, we need to know "this pawn moved from A2 to A4".
              // Since our model doesn't have IDs yet, we will use Implicit Animations
              // on the Position, but wait... recreating the widget tree destroys state.

              // Only way to animate smoothly without IDs is to have a Stack of pieces
              // that persist.
              // For now, let's stick to a high-quality "snap" with visual flair layout
              // and maybe basic fade/scale transitions.
              // Truly smooth "glide" requires tracking piece identity.

              // Let's us AnimatedPositioned assuming logical stability?
              // Actually, if we just rebuild, it won't glide.
              // So for this step, we'll focus on the VISUAL QUALITY (Shadows, Size, Text).

              pieces.add(
                Positioned(
                  left: file * squareSize,
                  bottom:
                      rank *
                      squareSize, // flutter stack bottom-up? No, usually top-down.
                  // Stack is top-left (0,0). Rank 7 is top. Rank 0 is bottom.
                  // So Rank 7 is top: 0. Rank 0 is top: 7 * size.
                  top: (7 - rank) * squareSize,
                  child: IgnorePointer(
                    // Clicks should go to grid
                    child: Container(
                      width: squareSize,
                      height: squareSize,
                      alignment: Alignment.center,
                      child: Text(
                        piece.symbol,
                        style: TextStyle(
                          fontSize: squareSize * 0.85,
                          height: 1.0,
                          shadows: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          }
        }
        return Stack(children: pieces);
      },
    );
  }

  String _getFileName(int file) {
    return String.fromCharCode('a'.codeUnitAt(0) + file);
  }
}
