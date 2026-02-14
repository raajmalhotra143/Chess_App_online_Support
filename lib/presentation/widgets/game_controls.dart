import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../presentation/providers/game_state_provider.dart';
import '../../presentation/providers/theme_provider.dart';
import '../../domain/chess_engine/game_rules.dart';

/// Game controls widget with buttons for game actions
class GameControls extends StatelessWidget {
  const GameControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Game status display
                _buildGameStatus(context, gameState),
                const SizedBox(height: 16),

                // Turn indicator
                if (!gameState.isGameOver)
                  Text(
                    '${gameState.currentTurn.name.toUpperCase()} to move',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                const SizedBox(height: 16),

                // Control buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        gameState.newGame();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('New Game'),
                    ),
                    if (!gameState.isGameOver) ...[
                      ElevatedButton.icon(
                        onPressed: () {
                          gameState.resign();
                          _showGameOverDialog(context, gameState);
                        },
                        icon: const Icon(Icons.flag),
                        label: const Text('Resign'),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 16),

                // Theme toggle
                _buildThemeToggle(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameStatus(BuildContext context, GameStateProvider gameState) {
    String statusText;
    Color? statusColor;

    switch (gameState.gameStatus) {
      case GameStatus.ongoing:
        statusText = 'Game in Progress';
        statusColor = Theme.of(context).colorScheme.primary;
        break;
      case GameStatus.check:
        statusText = 'CHECK!';
        statusColor = AppTheme.checkHighlight;
        break;
      case GameStatus.checkmate:
        final winner = gameState.getWinner();
        statusText = 'CHECKMATE - ${winner?.name.toUpperCase()} WINS!';
        statusColor = Theme.of(context).colorScheme.error;
        break;
      case GameStatus.stalemate:
        statusText = 'STALEMATE - Draw';
        statusColor = Theme.of(context).colorScheme.tertiary;
        break;
      case GameStatus.draw:
        statusText = 'DRAW';
        statusColor = Theme.of(context).colorScheme.tertiary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Text(
        statusText,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.brightness_6),
            const SizedBox(width: 8),
            Text('Theme', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: () => themeProvider.toggleTheme(),
              tooltip: 'Toggle Theme',
            ),
          ],
        );
      },
    );
  }

  void _showGameOverDialog(BuildContext context, GameStateProvider gameState) {
    if (!gameState.isGameOver) return;

    final winner = gameState.getWinner();
    String title;
    String message;

    switch (gameState.gameStatus) {
      case GameStatus.checkmate:
        title = 'Checkmate!';
        message = '${winner?.name.toUpperCase()} wins!';
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              gameState.newGame();
            },
            child: const Text('New Game'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
