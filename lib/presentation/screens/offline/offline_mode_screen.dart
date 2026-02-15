import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/chess_piece.dart';
import '../../providers/game_setup_provider.dart';
import '../../providers/game_state_provider.dart';
import '../game_screen.dart';
import '../puzzle/puzzle_screen.dart';

/// Offline game modes menu
class OfflineModeScreen extends StatelessWidget {
  const OfflineModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      appBar: AppBar(
        title: const Text('Offline Modes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF2C2C2C),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Local Two Player
                _buildModeCard(
                  context,
                  icon: Icons.people,
                  title: 'Local Two Player',
                  description: 'Play with a friend on the same device',
                  color: const Color(0xFF4CAF50),
                  onTap: () => _startLocalMultiplayer(context),
                ),
                const SizedBox(height: 20),

                // Puzzle Mode
                _buildModeCard(
                  context,
                  icon: Icons.extension,
                  title: 'Puzzle Mode',
                  description: 'Solve chess puzzles (Mate in 1, 2, 3)',
                  color: const Color(0xFFFF9800),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PuzzleScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // AI Opponent (15 levels)
                _buildModeCard(
                  context,
                  icon: Icons.smart_toy,
                  title: 'AI Opponent',
                  description: '15 difficulty levels - Levels 10+ unbeatable!',
                  color: const Color(0xFF9C27B0),
                  onTap: () => _showAIDifficultySelector(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  void _startLocalMultiplayer(BuildContext context) {
    final setupProvider = context.read<GameSetupProvider>();
    setupProvider.setGameMode(GameMode.localTwoPlayer);

    // Navigate to game with local multiplayer mode
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => GameStateProvider(
            playerColor: PieceColor.white,
            isAIGame: false,
            isLocalMultiplayer: true,
          ),
          child: const GameScreen(),
        ),
      ),
    );
  }

  void _showAIDifficultySelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AILevelSelectorDialog(),
    );
  }
}

/// Dialog for selecting AI difficulty level
class AILevelSelectorDialog extends StatefulWidget {
  const AILevelSelectorDialog({super.key});

  @override
  State<AILevelSelectorDialog> createState() => _AILevelSelectorDialogState();
}

class _AILevelSelectorDialogState extends State<AILevelSelectorDialog> {
  int _selectedLevel = 5;
  PieceColor _selectedColor = PieceColor.white;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'AI Challenge',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Color selection
            const Text('Your Color:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildColorButton(PieceColor.white, 'White', Icons.circle),
                const SizedBox(width: 16),
                _buildColorButton(PieceColor.black, 'Black', Icons.circle),
              ],
            ),

            const SizedBox(height: 24),

            // Difficulty level
            Text(
              'Level $_selectedLevel',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              _getDifficultyDescription(_selectedLevel),
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Slider(
              value: _selectedLevel.toDouble(),
              min: 1,
              max: 15,
              divisions: 14,
              label: 'Level $_selectedLevel',
              onChanged: (value) {
                setState(() => _selectedLevel = value.toInt());
              },
            ),

            const SizedBox(height: 24),

            // Start button
            ElevatedButton(
              onPressed: () => _startAIGame(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Start Game',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorButton(PieceColor color, String label, IconData icon) {
    final isSelected = _selectedColor == color;
    return InkWell(
      onTap: () => setState(() => _selectedColor = color),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (color == PieceColor.white
                    ? Colors.grey[300]
                    : Colors.grey[800])
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF9C27B0) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color == PieceColor.white && !isSelected
                ? Colors.black87
                : isSelected && color == PieceColor.black
                ? Colors.white
                : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  String _getDifficultyDescription(int level) {
    if (level <= 3) return 'Beginner';
    if (level <= 6) return 'Easy';
    if (level <= 9) return 'Medium';
    if (level <= 12) return 'Hard';
    return 'Expert - Nearly Unbeatable!';
  }

  void _startAIGame(BuildContext context) {
    final setupProvider = context.read<GameSetupProvider>();
    setupProvider.setGameMode(GameMode.vsAI);
    setupProvider.setPlayerColor(_selectedColor);
    setupProvider.setAIDifficulty(_selectedLevel);
    setupProvider.lockColor();

    Navigator.pop(context); // Close dialog

    // Navigate to game with AI mode
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => GameStateProvider(
            playerColor: _selectedColor,
            isAIGame: true,
            isLocalMultiplayer: false,
          ),
          child: const GameScreen(),
        ),
      ),
    );
  }
}
