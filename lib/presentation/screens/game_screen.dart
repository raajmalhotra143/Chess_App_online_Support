import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/chess_piece.dart';
import '../../presentation/providers/game_state_provider.dart';
import '../../presentation/widgets/chess_board_widget.dart';
import '../../presentation/widgets/game_controls.dart';

/// Main game screen displaying the chess board and controls
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('♟ Chess Master'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(context),
            tooltip: 'About',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.boardGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Responsive layout
              final isWideScreen = constraints.maxWidth > 800;

              if (isWideScreen) {
                // Desktop/tablet layout - side by side
                return Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 600),
                            child: const ChessBoardWidget(),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              const GameControls(),
                              const SizedBox(height: 16),
                              _buildMoveHistory(context),
                              const SizedBox(height: 16),
                              _buildCapturedPieces(context),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // Mobile layout - stacked
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const GameControls(),
                        const SizedBox(height: 16),
                        const ChessBoardWidget(),
                        const SizedBox(height: 16),
                        _buildCapturedPieces(context),
                        const SizedBox(height: 16),
                        _buildMoveHistory(context),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMoveHistory(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
        final moves = gameState.moveHistory;

        if (moves.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No moves yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }

        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Move History',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Divider(height: 1),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: (moves.length / 2).ceil(),
                  itemBuilder: (context, index) {
                    final moveNumber = index + 1;
                    final whiteMove = moves[index * 2];
                    final blackMove = index * 2 + 1 < moves.length
                        ? moves[index * 2 + 1]
                        : null;

                    return ListTile(
                      dense: true,
                      leading: Text(
                        '$moveNumber.',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      title: Row(
                        children: [
                          Expanded(child: Text(whiteMove.toAlgebraic())),
                          if (blackMove != null)
                            Expanded(child: Text(blackMove.toAlgebraic())),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCapturedPieces(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
        final capturedPieces = gameState.capturedPieces;

        if (capturedPieces.isEmpty) {
          return const SizedBox.shrink();
        }

        final whiteCaptured = capturedPieces
            .where((p) => p.color == PieceColor.white)
            .toList();
        final blackCaptured = capturedPieces
            .where((p) => p.color == PieceColor.black)
            .toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Captured Pieces',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (whiteCaptured.isNotEmpty) ...[
                  Text(
                    'White: ${whiteCaptured.map((p) => p.symbol).join(' ')}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
                if (blackCaptured.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Black: ${blackCaptured.map((p) => p.symbol).join(' ')}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Chess Master',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 Next-Generation Chess Game',
      children: [
        const SizedBox(height: 16),
        const Text('A beautiful, feature-rich chess game built with Flutter.'),
      ],
    );
  }
}
