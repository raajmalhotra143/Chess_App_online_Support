import 'package:flutter/material.dart';
import 'offline/offline_mode_screen.dart';
import 'online/online_mode_screen.dart';

/// Main menu for selecting between online and offline game modes
class GameModeScreen extends StatelessWidget {
  const GameModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Title
                const Icon(
                  Icons.emoji_events,
                  size: 80,
                  color: Color(0xFF4A90E2),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Chess Master',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose your game mode',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 48),

                // Online Mode Card
                _buildModeCard(
                  context,
                  icon: Icons.public,
                  title: 'Online Multiplayer',
                  description:
                      'Play with friends online via QR code or room ID',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OnlineModeScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Offline Mode Card
                _buildModeCard(
                  context,
                  icon: Icons.devices,
                  title: 'Offline Modes',
                  description: 'Play locally, solve puzzles, or challenge AI',
                  gradient: LinearGradient(
                    colors: [Colors.green[600]!, Colors.green[800]!],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OfflineModeScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 48),

                // Settings button
                TextButton.icon(
                  onPressed: () {
                    // TODO: Navigate to settings
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Settings'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
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
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 48, color: Colors.white),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }
}
