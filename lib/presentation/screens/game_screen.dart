import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/chess_piece.dart';
import '../../domain/chess_engine/game_rules.dart';
import '../../presentation/providers/game_state_provider.dart';
import '../../presentation/widgets/chess_board_widget.dart';
import '../../presentation/widgets/victory_dialog.dart';

/// Main game screen with professional chess.com-style design
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameStatus? _lastGameStatus;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Listen for game status changes
    final gameState = context.watch<GameStateProvider>();
    final currentStatus = gameState.gameStatus;

    // Show dialog only once when game ends
    if (_lastGameStatus != currentStatus && _isGameOver(currentStatus)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGameOverDialog(currentStatus, gameState);
      });
    }

    _lastGameStatus = currentStatus;
  }

  bool _isGameOver(GameStatus status) {
    return status == GameStatus.checkmate ||
        status == GameStatus.stalemate ||
        status == GameStatus.draw;
  }

  void _showGameOverDialog(GameStatus status, GameStateProvider gameState) {
    final winner = gameState.getWinner();
    String title;
    String message;

    switch (status) {
      case GameStatus.checkmate:
        title = 'Checkmate!';
        message = winner == PieceColor.white ? 'White wins!' : 'Black wins!';
        break;
      case GameStatus.stalemate:
        title = 'Stalemate';
        message = 'The game is a draw.';
        break;
      case GameStatus.draw:
        title = 'Draw';
        message = 'The game ended in a draw.';
        break;
      default:
        return;
    }

    showVictoryDialog(
      context,
      title: title,
      message: message,
      winner: winner,
      onRematch: () => gameState.newGame(),
      onHome: () {
        // TODO: Navigate to home screen (Phase 4)
        Navigator.pop(context);
      },
      onViewSummary: () {
        // TODO: Implement game summary (Phase 4)
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 900;

            if (isWideScreen) {
              return Row(
                children: [
                  // Left Sidebar
                  Container(
                    width: 320,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _buildSidebar(context),
                  ),
                  // Main game area
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(
                        top: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _buildGameArea(context),
                    ),
                  ),
                ],
              );
            } else {
              // Mobile layout
              return Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _buildGameArea(context),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile section
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Play Chess',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Difficulty selector
              const Text(
                'Difficulty',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildButton(context, 'Easy', false)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildButton(context, 'Medium', true)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildButton(context, 'Hard', false)),
                ],
              ),
              const SizedBox(height: 16),

              // Time control
              const Text(
                'Time Control',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildButton(context, '3 min', false)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildButton(context, '5 min', true)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildButton(context, '10 min', false)),
                ],
              ),
              const SizedBox(height: 16),

              // Color selection
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.circle, size: 16),
                      label: const Text('White'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.circle, size: 16),
                      label: const Text('Black'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Theme colors
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildColorCircle(const Color(0xFF8CA2AD)),
                  const SizedBox(width: 12),
                  _buildColorCircle(const Color(0xFF86C232)),
                  const SizedBox(width: 12),
                  _buildColorCircle(const Color(0xFFE94B3C)),
                ],
              ),
              const SizedBox(height: 24),

              // Action buttons
              ElevatedButton(
                onPressed: () => gameState.newGame(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2C2C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('New Game'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Settings'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameArea(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
        return Column(
          children: [
            // Top player card
            _buildPlayerCard(
              context,
              'Opponent',
              gameState.currentTurn == PieceColor.black,
              const Color(0xFF2C2C2C),
              isTop: true,
            ),

            // Chess board
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: const ChessBoardWidget(),
                  ),
                ),
              ),
            ),

            // Bottom player card
            _buildPlayerCard(
              context,
              'You',
              gameState.currentTurn == PieceColor.white,
              const Color(0xFF22A35A),
              isTop: false,
            ),

            // Bottom controls
            _buildBottomControls(context),
          ],
        );
      },
    );
  }

  Widget _buildPlayerCard(
    BuildContext context,
    String name,
    bool isActive,
    Color timerColor, {
    required bool isTop,
  }) {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
        final capturedPieces = gameState.capturedPieces
            .where(
              (p) => isTop
                  ? p.color == PieceColor.white
                  : p.color == PieceColor.black,
            )
            .toList();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: isTop
                  ? BorderSide(color: Colors.grey[200]!)
                  : BorderSide.none,
              top: !isTop
                  ? BorderSide(color: Colors.grey[200]!)
                  : BorderSide.none,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                child: Icon(
                  isTop ? Icons.computer : Icons.person,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (capturedPieces.isNotEmpty)
                      Text(
                        capturedPieces.map((p) => p.symbol).join(' '),
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isActive ? timerColor : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '09:26',
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Undo
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => Provider.of<GameStateProvider>(
              context,
              listen: false,
            ).undoMove(),
            tooltip: 'Undo',
          ),
          // Rotate Board
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () => Provider.of<GameStateProvider>(
              context,
              listen: false,
            ).toggleBoardFlip(),
            tooltip: 'Flip Board',
          ),
          // New Game
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _showRestartDialog(context),
            tooltip: 'New Game',
          ),
          // Exit
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Exit',
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.grey[200],
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildColorCircle(Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!, width: 2),
      ),
    );
  }

  void _showRestartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Game?'),
        content: const Text('Current progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<GameStateProvider>(context, listen: false).newGame();
            },
            child: const Text('New Game'),
          ),
        ],
      ),
    );
  }
}
