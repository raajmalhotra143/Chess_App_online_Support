import 'package:flutter/material.dart';

/// Placeholder for online multiplayer mode (Phase 3)
class OnlineModeScreen extends StatelessWidget {
  const OnlineModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Multiplayer'),
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.construction, size: 80, color: Colors.orange),
              const SizedBox(height: 24),
              const Text(
                'Coming Soon!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Online multiplayer with QR codes and room sharing will be available in Phase 3.',
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
