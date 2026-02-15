import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../data/models/puzzle.dart';
import '../../../data/models/chess_move.dart';
import '../../../data/models/chess_piece.dart'; // Added
import '../../providers/game_state_provider.dart';
import '../../widgets/chess_board_widget.dart';

/// Screen for solving chess puzzles
class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  List<Puzzle> _puzzles = [];
  int _currentPuzzleIndex = 0;
  bool _isLoading = true;
  String? _message;
  bool _isSuccess = false;
  ChessMove? _lastHandledMove; // Track handled moves

  @override
  void initState() {
    super.initState();
    _loadPuzzles();
  }

  Future<void> _loadPuzzles() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/puzzles.json',
      );
      final Map<String, dynamic> jsonData = json.decode(
        jsonString,
      ); // Fixed shadowing
      final List<dynamic> puzzlesJson = jsonData['puzzles'];

      setState(() {
        _puzzles = puzzlesJson.map((p) => Puzzle.fromJson(p)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Failed to load puzzles: $e';
      });
    }
  }

  void _nextPuzzle() {
    if (_currentPuzzleIndex < _puzzles.length - 1) {
      setState(() {
        _currentPuzzleIndex++;
        _message = null;
        _isSuccess = false;
      });
    }
  }

  void _onMoveMade(BuildContext context, GameStateProvider gameState) {
    // This is called when gameState changes
    final lastMove = gameState.lastMove;
    if (lastMove == null) return;

    // Check if we already handled this move (simple check: valid puzzle index implies we are active)
    if (_isSuccess || _message != null) return;

    final puzzle = _puzzles[_currentPuzzleIndex];

    // We need to compare lastMove with puzzle.solution[0]
    // puzzle.solution[0] is e.g. "Qxf7#"

    // The board is already updated, so we can't easily generate SAN that depends on "before" state (like ambiguity)
    // BUT, we can just check if the destination matches and piece matches.

    // Let's try matching the TARGET square and PIECE type.
    // Solution: "Qxf7#" -> Piece Q, To f7.
    // This is robust enough for most basic puzzles.

    final solutionStr = puzzle.solution.first;
    bool match = _checkSolutionMatch(lastMove, solutionStr, gameState.board);

    if (match) {
      _handleSuccess();
    } else {
      // If it was the player's turn and they made a wrong move
      // (Wait, only player moves trigger this?)
      // Yes, we only listen to changes.
      _handleFailure(gameState);
    }
  }

  bool _checkSolutionMatch(ChessMove move, String solutionSan, dynamic board) {
    // board is ChessBoard
    // simple parser
    // 1. Target square
    // "Qxf7#" -> f7.
    // Regex to find [a-h][1-8]
    final targetMatch = RegExp(r'([a-h][1-8])').firstMatch(solutionSan);
    if (targetMatch == null) return false;

    final targetStr = targetMatch.group(1)!;
    final moveTargetStr =
        '${String.fromCharCode('a'.codeUnitAt(0) + move.to.file)}${move.to.rank + 1}';

    if (targetStr != moveTargetStr) return false;

    // 2. Piece type
    // If starts with K, Q, R, B, N -> piece.
    // If lower case or no letter -> pawn.
    // But wait, solutionSan might be "O-O".
    if (solutionSan.startsWith('O-O')) {
      return move.isCastle;
    }

    // Check piece type
    // We need to know what piece moved. GameStateProvider doesn't easily store "movedPiece type" in lastMove
    // (it has it implicitly, but we'd need to look at the board BEFORE the move or info in move).
    // Actually `move.promotionPiece` exists.
    // But standard piece? We can look at the piece currently at 'to' square!
    final pieceAtTarget = (board as dynamic).getPieceAt(
      move.to,
    ); // Dynamic hack or cast
    if (pieceAtTarget == null) return false;

    String pieceChar = '';
    switch (pieceAtTarget.type) {
      case PieceType.pawn:
        pieceChar = '';
        break;
      case PieceType.knight:
        pieceChar = 'N';
        break;
      case PieceType.bishop:
        pieceChar = 'B';
        break;
      case PieceType.rook:
        pieceChar = 'R';
        break;
      case PieceType.queen:
        pieceChar = 'Q';
        break;
      case PieceType.king:
        pieceChar = 'K';
        break;
    }

    if (pieceChar == '' && !RegExp(r'^[a-h]').hasMatch(solutionSan)) {
      // Pawn move logic distinction
    }

    if (pieceChar != '' && !solutionSan.startsWith(pieceChar)) {
      // Special case: 'N' might be 'Ncd7'.
      // Just check if solution contains the piece char at start?
      return false;
    }

    return true;
  }

  void _handleSuccess() {
    setState(() {
      _isSuccess = true;
      _message = 'Puzzle Solved!';
    });
  }

  void _handleFailure(GameStateProvider gameState) {
    setState(() {
      _message = 'Incorrect! Try again.';
    });
    // Undo logic would go here
    Future.delayed(const Duration(seconds: 1), () {
      gameState.undoMove(); // If implemented
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_puzzles.isEmpty) {
      return const Scaffold(body: Center(child: Text("No puzzles found!")));
    }

    final puzzle = _puzzles[_currentPuzzleIndex];

    return ChangeNotifierProvider(
      key: ValueKey(puzzle.id), // Re-create provider for new puzzle
      create: (_) {
        _lastHandledMove = null; // Reset for new puzzle
        final playerColor = puzzle.fenPosition.contains(' w ')
            ? PieceColor.white
            : PieceColor.black;

        final provider = GameStateProvider(
          fen: puzzle.fenPosition,
          playerColor: playerColor,
        );

        // Flip board if playing as Black
        if (playerColor == PieceColor.black) {
          provider.toggleBoardFlip();
        }

        return provider;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Puzzle ${puzzle.id}'),
          backgroundColor: const Color(0xFFFF9800),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: _nextPuzzle,
            ),
          ],
        ),
        body: Column(
          children: [
            // Puzzle Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    puzzle.difficultyDescription,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(puzzle.theme.replaceAll('_', ' ').toUpperCase()),
                ],
              ),
            ),

            // Chess Board
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Consumer<GameStateProvider>(
                  builder: (context, gameState, _) {
                    // Listen for moves
                    if (gameState.lastMove != null &&
                        gameState.lastMove != _lastHandledMove) {
                      _lastHandledMove = gameState.lastMove;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _onMoveMade(context, gameState);
                      });
                    }

                    return Column(
                      children: [
                        const ChessBoardWidget(),
                        if (_message != null)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              _message!,
                              style: TextStyle(
                                fontSize: 18,
                                color: _isSuccess ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (_isSuccess)
                          ElevatedButton(
                            onPressed: _nextPuzzle,
                            child: const Text("Next Puzzle"),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
