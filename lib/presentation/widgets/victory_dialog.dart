import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../data/models/chess_piece.dart';

/// Victory dialog shown when the game ends (checkmate, stalemate, or draw)
class VictoryDialog extends StatefulWidget {
  final String title;
  final String message;
  final PieceColor? winner;
  final VoidCallback onRematch;
  final VoidCallback onHome;
  final VoidCallback? onViewSummary;

  const VictoryDialog({
    super.key,
    required this.title,
    required this.message,
    this.winner,
    required this.onRematch,
    required this.onHome,
    this.onViewSummary,
  });

  @override
  State<VictoryDialog> createState() => _VictoryDialogState();
}

class _VictoryDialogState extends State<VictoryDialog>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    // Start animations
    _animationController.forward();
    if (widget.winner != null) {
      // Only show confetti if there's a winner (not for draws)
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Confetti overlay
        Positioned(
          top: 0,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            gravity: 0.1,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
              Colors.yellow,
            ],
          ),
        ),
        // Dialog content
        ScaleTransition(
          scale: _scaleAnimation,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 16,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.winner != null
                      ? [
                          widget.winner == PieceColor.white
                              ? const Color(0xFF4A90E2)
                              : const Color(0xFF2C2C2C),
                          widget.winner == PieceColor.white
                              ? const Color(0xFF357ABD)
                              : const Color(0xFF1A1A1A),
                        ]
                      : [Colors.grey[700]!, Colors.grey[800]!],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Trophy or draw icon
                  Icon(
                    widget.winner != null
                        ? Icons.emoji_events
                        : Icons.handshake,
                    size: 80,
                    color: widget.winner != null
                        ? Colors.amber
                        : Colors.white70,
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Message
                  Text(
                    widget.message,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Home button
                      _buildButton(
                        context,
                        icon: Icons.home,
                        label: 'Home',
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onHome();
                        },
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      // Rematch button
                      _buildButton(
                        context,
                        icon: Icons.refresh,
                        label: 'Rematch',
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onRematch();
                        },
                        color: Colors.green,
                        isPrimary: true,
                      ),
                    ],
                  ),
                  if (widget.onViewSummary != null) ...[
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onViewSummary!();
                      },
                      icon: const Icon(Icons.analytics, color: Colors.white70),
                      label: const Text(
                        'View Summary',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    bool isPrimary = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: isPrimary ? Colors.white : Colors.white70),
      label: Text(
        label,
        style: TextStyle(
          color: isPrimary ? Colors.white : Colors.white70,
          fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: isPrimary ? 4 : 0,
      ),
    );
  }
}

/// Helper function to show the victory dialog
void showVictoryDialog(
  BuildContext context, {
  required String title,
  required String message,
  PieceColor? winner,
  required VoidCallback onRematch,
  required VoidCallback onHome,
  VoidCallback? onViewSummary,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => VictoryDialog(
      title: title,
      message: message,
      winner: winner,
      onRematch: onRematch,
      onHome: onHome,
      onViewSummary: onViewSummary,
    ),
  );
}
