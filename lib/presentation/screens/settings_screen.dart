import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/sound_service.dart';

/// Settings screen for configuring app preferences
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF2C2C2C),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // Sound Settings
          _buildSectionHeader('Sound'),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return SwitchListTile(
                title: const Text('Sound Effects'),
                subtitle: const Text('Enable move, capture, and check sounds'),
                value: settings.soundEnabled,
                onChanged: (value) {
                  settings.setSoundEnabled(value);
                  SoundService().setMuted(!value);
                  if (value) {
                    SoundService().playMove(); // Test sound
                  }
                },
              );
            },
          ),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return ListTile(
                title: const Text('Volume'),
                subtitle: Slider(
                  value: settings.volume,
                  onChanged: settings.soundEnabled
                      ? (value) {
                          settings.setVolume(value);
                          SoundService().setVolume(value);
                        }
                      : null,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  label: '${(settings.volume * 100).round()}%',
                ),
              );
            },
          ),
          const Divider(),

          // Board Theme
          _buildSectionHeader('Board Theme'),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return Column(
                children: BoardTheme.values.map((theme) {
                  return RadioListTile<BoardTheme>(
                    title: Row(
                      children: [
                        Text(theme.displayName),
                        const SizedBox(width: 16),
                        // Color preview
                        Container(
                          width: 40,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  color: _getThemeLightColor(theme),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  color: _getThemeDarkColor(theme),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    value: theme,
                    groupValue: settings.boardTheme,
                    onChanged: (value) {
                      if (value != null) {
                        settings.setBoardTheme(value);
                      }
                    },
                  );
                }).toList(),
              );
            },
          ),
          const Divider(),

          // Gameplay Settings
          _buildSectionHeader('Gameplay'),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return SwitchListTile(
                title: const Text('Show Legal Moves'),
                subtitle: const Text(
                  'Highlight possible moves when a piece is selected',
                ),
                value: settings.showLegalMoves,
                onChanged: settings.setShowLegalMoves,
              );
            },
          ),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return ListTile(
                title: const Text('Animation Speed'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Slider(
                      value: settings.animationSpeed,
                      onChanged: settings.setAnimationSpeed,
                      min: 0.5,
                      max: 2.0,
                      divisions: 3,
                      label: _getAnimationSpeedLabel(settings.animationSpeed),
                    ),
                    Text(
                      _getAnimationSpeedLabel(settings.animationSpeed),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),

          // About Section
          _buildSectionHeader('About'),
          const ListTile(title: Text('Version'), subtitle: Text('1.0.0')),
          const ListTile(
            title: Text('Chess App'),
            subtitle: Text(
              'A feature-rich chess application with AI, puzzles, and online play',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2196F3),
        ),
      ),
    );
  }

  Color _getThemeLightColor(BoardTheme theme) {
    switch (theme) {
      case BoardTheme.classic:
        return const Color(0xFFF0D9B5);
      case BoardTheme.modern:
        return const Color(0xFFEBECD0);
      case BoardTheme.blue:
        return const Color(0xFFDEE3E6);
      case BoardTheme.green:
        return const Color(0xFFAAD751);
      case BoardTheme.purple:
        return const Color(0xFFCBB4D4);
    }
  }

  Color _getThemeDarkColor(BoardTheme theme) {
    switch (theme) {
      case BoardTheme.classic:
        return const Color(0xFFB58863);
      case BoardTheme.modern:
        return const Color(0xFF769656);
      case BoardTheme.blue:
        return const Color(0xFF8CA2AD);
      case BoardTheme.green:
        return const Color(0xFF769656);
      case BoardTheme.purple:
        return const Color(0xFF8B7FA8);
    }
  }

  String _getAnimationSpeedLabel(double speed) {
    if (speed <= 0.7) return 'Slow';
    if (speed <= 1.2) return 'Normal';
    if (speed <= 1.7) return 'Fast';
    return 'Very Fast';
  }
}
