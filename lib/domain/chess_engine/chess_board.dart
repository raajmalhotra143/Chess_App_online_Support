import '../../data/models/chess_piece.dart';
import '../../data/models/position.dart';
import '../../data/models/chess_move.dart';

/// Represents the chess board state
class ChessBoard {
  // 8x8 board representation where null means empty square
  final List<List<ChessPiece?>> _board;

  // Move history
  final List<ChessMove> _moveHistory;

  // Captured pieces
  final List<ChessPiece> _capturedPieces;

  // En passant target square
  Position? enPassantTarget;

  // Castling rights
  bool whiteCanCastleKingSide;
  bool whiteCanCastleQueenSide;
  bool blackCanCastleKingSide;
  bool blackCanCastleQueenSide;

  // Current turn
  PieceColor currentTurn;

  // Halfmove clock for 50-move rule
  int halfmoveClock;

  // Fullmove number
  int fullmoveNumber;

  ChessBoard({
    List<List<ChessPiece?>>? board,
    List<ChessMove>? moveHistory,
    List<ChessPiece>? capturedPieces,
    this.enPassantTarget,
    this.whiteCanCastleKingSide = true,
    this.whiteCanCastleQueenSide = true,
    this.blackCanCastleKingSide = true,
    this.blackCanCastleQueenSide = true,
    this.currentTurn = PieceColor.white,
    this.halfmoveClock = 0,
    this.fullmoveNumber = 1,
  }) : _board = board ?? _createEmptyBoard(),
       _moveHistory = moveHistory ?? [],
       _capturedPieces = capturedPieces ?? [];

  /// Creates an empty 8x8 board
  static List<List<ChessPiece?>> _createEmptyBoard() {
    return List.generate(8, (_) => List.filled(8, null));
  }

  /// Initializes the board with standard starting position
  factory ChessBoard.standardSetup() {
    final board = ChessBoard();
    board._setupStandardPieces();
    return board;
  }

  /// Initializes the board from a FEN string
  factory ChessBoard.fromFEN(String fen) {
    final board = ChessBoard();
    final parts = fen.split(' ');

    // 1. Piece placement
    final ranks = parts[0].split('/');
    for (int r = 0; r < 8; r++) {
      final rank = 7 - r;
      int file = 0;
      for (int i = 0; i < ranks[r].length; i++) {
        final char = ranks[r][i];
        if (RegExp(r'[1-8]').hasMatch(char)) {
          file += int.parse(char);
        } else {
          final color = char == char.toUpperCase()
              ? PieceColor.white
              : PieceColor.black;
          final type = _getPieceTypeFromChar(char.toLowerCase());
          board.setPieceAt(
            Position(rank: rank, file: file),
            ChessPiece(type: type, color: color),
          );
          file++;
        }
      }
    }

    // 2. Active color
    board.currentTurn = parts[1] == 'w' ? PieceColor.white : PieceColor.black;

    // 3. Castling availability
    final castling = parts[2];
    board.whiteCanCastleKingSide = castling.contains('K');
    board.whiteCanCastleQueenSide = castling.contains('Q');
    board.blackCanCastleKingSide = castling.contains('k');
    board.blackCanCastleQueenSide = castling.contains('q');

    // 4. En passant target square
    // (Simplified: Parsing logic for en passant target if needed)

    // 5. Halfmove clock
    if (parts.length > 4) {
      board.halfmoveClock = int.tryParse(parts[4]) ?? 0;
    }

    // 6. Fullmove number
    if (parts.length > 5) {
      board.fullmoveNumber = int.tryParse(parts[5]) ?? 1;
    }

    return board;
  }

  static PieceType _getPieceTypeFromChar(String char) {
    switch (char) {
      case 'p':
        return PieceType.pawn;
      case 'n':
        return PieceType.knight;
      case 'b':
        return PieceType.bishop;
      case 'r':
        return PieceType.rook;
      case 'q':
        return PieceType.queen;
      case 'k':
        return PieceType.king;
      default:
        return PieceType.pawn;
    }
  }

  /// Sets up pieces in standard chess starting position
  void _setupStandardPieces() {
    // Set up pawns
    for (int file = 0; file < 8; file++) {
      setPieceAt(
        Position(rank: 1, file: file),
        const ChessPiece(type: PieceType.pawn, color: PieceColor.white),
      );
      setPieceAt(
        Position(rank: 6, file: file),
        const ChessPiece(type: PieceType.pawn, color: PieceColor.black),
      );
    }

    // Set up white pieces
    _setupBackRank(0, PieceColor.white);

    // Set up black pieces
    _setupBackRank(7, PieceColor.black);
  }

  /// Sets up the back rank for a given color
  void _setupBackRank(int rank, PieceColor color) {
    final pieces = [
      PieceType.rook,
      PieceType.knight,
      PieceType.bishop,
      PieceType.queen,
      PieceType.king,
      PieceType.bishop,
      PieceType.knight,
      PieceType.rook,
    ];

    for (int file = 0; file < 8; file++) {
      setPieceAt(
        Position(rank: rank, file: file),
        ChessPiece(type: pieces[file], color: color),
      );
    }
  }

  /// Gets the piece at a given position
  ChessPiece? getPieceAt(Position position) {
    if (!position.isValid) return null;
    return _board[position.rank][position.file];
  }

  /// Sets a piece at a given position
  void setPieceAt(Position position, ChessPiece? piece) {
    if (!position.isValid) return;
    _board[position.rank][position.file] = piece;
  }

  /// Removes and returns the piece at a given position
  ChessPiece? removePieceAt(Position position) {
    final piece = getPieceAt(position);
    setPieceAt(position, null);
    return piece;
  }

  /// Makes a move on the board
  void makeMove(ChessMove move) {
    final piece = getPieceAt(move.from);
    if (piece == null) return;

    // Handle capture
    if (move.isCapture) {
      final capturedPiece = getPieceAt(move.to);
      if (capturedPiece != null) {
        _capturedPieces.add(capturedPiece);
      }

      // Handle en passant capture
      if (move.isEnPassant) {
        final capturedPawnRank = piece.color == PieceColor.white ? 4 : 3;
        final capturedPawnPos = Position(
          rank: capturedPawnRank,
          file: move.to.file,
        );
        final capturedPawn = removePieceAt(capturedPawnPos);
        if (capturedPawn != null) {
          _capturedPieces.add(capturedPawn);
        }
      }
    }

    // Move the piece
    removePieceAt(move.from);
    setPieceAt(move.to, piece);

    // Handle pawn promotion
    if (move.isPromotion && move.promotionPiece != null) {
      setPieceAt(
        move.to,
        ChessPiece(type: move.promotionPiece!, color: piece.color),
      );
    }

    // Handle castling
    if (move.isCastle) {
      _performCastling(move);
    }

    // Update en passant target
    enPassantTarget = null;
    if (piece.type == PieceType.pawn) {
      final rankDiff = (move.to.rank - move.from.rank).abs();
      if (rankDiff == 2) {
        // Pawn moved two squares, set en passant target
        final targetRank = piece.color == PieceColor.white ? 2 : 5;
        enPassantTarget = Position(rank: targetRank, file: move.from.file);
      }
    }

    // Update castling rights
    _updateCastlingRights(move, piece);

    // Update halfmove clock
    if (piece.type == PieceType.pawn || move.isCapture) {
      halfmoveClock = 0;
    } else {
      halfmoveClock++;
    }

    // Update fullmove number
    if (currentTurn == PieceColor.black) {
      fullmoveNumber++;
    }

    // Add to move history
    _moveHistory.add(move);

    // Switch turn
    currentTurn = currentTurn.opposite;
  }

  /// Performs castling move
  void _performCastling(ChessMove move) {
    final isKingSide = move.castleType == CastleType.kingSide;
    final rank = currentTurn == PieceColor.white ? 0 : 7;
    final rookFromFile = isKingSide ? 7 : 0;
    final rookToFile = isKingSide ? 5 : 3;

    final rook = removePieceAt(Position(rank: rank, file: rookFromFile));
    if (rook != null) {
      setPieceAt(Position(rank: rank, file: rookToFile), rook);
    }
  }

  /// Updates castling rights based on the move
  void _updateCastlingRights(ChessMove move, ChessPiece piece) {
    // If king moves, lose all castling rights for that color
    if (piece.type == PieceType.king) {
      if (piece.color == PieceColor.white) {
        whiteCanCastleKingSide = false;
        whiteCanCastleQueenSide = false;
      } else {
        blackCanCastleKingSide = false;
        blackCanCastleQueenSide = false;
      }
    }

    // If rook moves from initial position, lose that castling right
    if (piece.type == PieceType.rook) {
      if (piece.color == PieceColor.white && move.from.rank == 0) {
        if (move.from.file == 0) whiteCanCastleQueenSide = false;
        if (move.from.file == 7) whiteCanCastleKingSide = false;
      } else if (piece.color == PieceColor.black && move.from.rank == 7) {
        if (move.from.file == 0) blackCanCastleQueenSide = false;
        if (move.from.file == 7) blackCanCastleKingSide = false;
      }
    }
  }

  /// Finds the position of the king for the given color
  Position? findKing(PieceColor color) {
    for (int rank = 0; rank < 8; rank++) {
      for (int file = 0; file < 8; file++) {
        final position = Position(rank: rank, file: file);
        final piece = getPieceAt(position);
        if (piece != null &&
            piece.type == PieceType.king &&
            piece.color == color) {
          return position;
        }
      }
    }
    return null;
  }

  /// Gets all pieces of a given color
  List<MapEntry<Position, ChessPiece>> getPiecesOfColor(PieceColor color) {
    final pieces = <MapEntry<Position, ChessPiece>>[];
    for (int rank = 0; rank < 8; rank++) {
      for (int file = 0; file < 8; file++) {
        final position = Position(rank: rank, file: file);
        final piece = getPieceAt(position);
        if (piece != null && piece.color == color) {
          pieces.add(MapEntry(position, piece));
        }
      }
    }
    return pieces;
  }

  /// Gets move history
  List<ChessMove> get moveHistory => List.unmodifiable(_moveHistory);

  /// Gets captured pieces
  List<ChessPiece> get capturedPieces => List.unmodifiable(_capturedPieces);

  /// Creates a deep copy of the board
  ChessBoard copy() {
    final boardCopy = List.generate(
      8,
      (rank) => List.generate(8, (file) => _board[rank][file]),
    );

    return ChessBoard(
      board: boardCopy,
      moveHistory: List.from(_moveHistory),
      capturedPieces: List.from(_capturedPieces),
      enPassantTarget: enPassantTarget,
      whiteCanCastleKingSide: whiteCanCastleKingSide,
      whiteCanCastleQueenSide: whiteCanCastleQueenSide,
      blackCanCastleKingSide: blackCanCastleKingSide,
      blackCanCastleQueenSide: blackCanCastleQueenSide,
      currentTurn: currentTurn,
      halfmoveClock: halfmoveClock,
      fullmoveNumber: fullmoveNumber,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    for (int rank = 7; rank >= 0; rank--) {
      buffer.write('${rank + 1} ');
      for (int file = 0; file < 8; file++) {
        final piece = _board[rank][file];
        buffer.write(piece?.symbol ?? '·');
        buffer.write(' ');
      }
      buffer.writeln();
    }
    buffer.writeln('  a b c d e f g h');
    return buffer.toString();
  }
}
