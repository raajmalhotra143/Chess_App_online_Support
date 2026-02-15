/// Puzzle difficulty levels
enum PuzzleDifficulty { mateIn1, mateIn2, mateIn3 }

/// Chess puzzle model
class Puzzle {
  final String id;
  final String fenPosition; // FEN notation for starting position
  final PuzzleDifficulty difficulty;
  final List<String> solution; // Solution moves in algebraic notation
  final String theme; // e.g., 'fork', 'pin', 'back_rank_mate'
  final String? hint; // Optional hint text

  const Puzzle({
    required this.id,
    required this.fenPosition,
    required this.difficulty,
    required this.solution,
    required this.theme,
    this.hint,
  });

  /// Creates a Puzzle from JSON
  factory Puzzle.fromJson(Map<String, dynamic> json) {
    return Puzzle(
      id: json['id'] as String,
      fenPosition: json['fen'] as String,
      difficulty: _parseDifficulty(json['difficulty'] as String),
      solution: (json['solution'] as List<dynamic>).cast<String>(),
      theme: json['theme'] as String,
      hint: json['hint'] as String?,
    );
  }

  /// Converts Puzzle to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fen': fenPosition,
      'difficulty': _difficultyToString(difficulty),
      'solution': solution,
      'theme': theme,
      if (hint != null) 'hint': hint,
    };
  }

  static PuzzleDifficulty _parseDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'mate_in_1':
      case 'matein1':
        return PuzzleDifficulty.mateIn1;
      case 'mate_in_2':
      case 'matein2':
        return PuzzleDifficulty.mateIn2;
      case 'mate_in_3':
      case 'matein3':
        return PuzzleDifficulty.mateIn3;
      default:
        return PuzzleDifficulty.mateIn1;
    }
  }

  static String _difficultyToString(PuzzleDifficulty difficulty) {
    switch (difficulty) {
      case PuzzleDifficulty.mateIn1:
        return 'mate_in_1';
      case PuzzleDifficulty.mateIn2:
        return 'mate_in_2';
      case PuzzleDifficulty.mateIn3:
        return 'mate_in_3';
    }
  }

  /// Gets user-friendly difficulty description
  String get difficultyDescription {
    switch (difficulty) {
      case PuzzleDifficulty.mateIn1:
        return 'Mate in 1';
      case PuzzleDifficulty.mateIn2:
        return 'Mate in 2';
      case PuzzleDifficulty.mateIn3:
        return 'Mate in 3';
    }
  }
}
