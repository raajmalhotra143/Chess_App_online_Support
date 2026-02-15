import 'package:flutter/material.dart';

/// Placeholder for puzzle mode (will be implemented with full puzzle system)
class PuzzleScreen extends StatelessWidget {
  const PuzzleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puzzle Mode'),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.extension, size: 80, color: Color(0xFFFF9800)),
              const SizedBox(height: 24),
              const Text(
                'Puzzle Mode',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Solve chess puzzles to improve your tactical skills!\n\n'
                '• Mate in 1\n'
                '• Mate in 2\n'
                '• Mate in 3\n\n'
                'Full puzzle system with hints and solutions coming soon!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
