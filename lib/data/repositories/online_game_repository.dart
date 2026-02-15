import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game_room.dart';

/// Repository for managing online game rooms in Firestore
class OnlineGameRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _roomsCollection = 'game_rooms';

  /// Creates a new game room
  Future<GameRoom> createRoom({
    required String hostUid,
    required String hostName,
    required String hostColor,
  }) async {
    final roomCode = GameRoom.generateRoomCode();

    final gameRoom = GameRoom(
      roomId: roomCode,
      hostUid: hostUid,
      hostName: hostName,
      hostColor: hostColor,
      fenPosition:
          'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1', // Starting position
      currentTurn: 'white',
      status: 'waiting',
      moves: [],
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(_roomsCollection)
        .doc(roomCode)
        .set(gameRoom.toFirestore());

    return gameRoom;
  }

  /// Joins an existing room
  Future<GameRoom?> joinRoom({
    required String roomCode,
    required String guestUid,
    required String guestName,
  }) async {
    final roomDoc = await _firestore
        .collection(_roomsCollection)
        .doc(roomCode.toUpperCase())
        .get();

    if (!roomDoc.exists) {
      return null; // Room not found
    }

    final room = GameRoom.fromFirestore(roomDoc);

    if (room.guestUid != null) {
      return null; // Room is full
    }

    if (room.status != 'waiting') {
      return null; // Game already started or completed
    }

    // Assign opposite color to guest
    final guestColor = room.hostColor == 'white' ? 'black' : 'white';

    await _firestore.collection(_roomsCollection).doc(roomCode).update({
      'guest': {'uid': guestUid, 'name': guestName, 'color': guestColor},
      'gameState.status': 'active',
    });

    return GameRoom.fromFirestore(
      await _firestore.collection(_roomsCollection).doc(roomCode).get(),
    );
  }

  /// Gets a room by code
  Future<GameRoom?> getRoom(String roomCode) async {
    final roomDoc = await _firestore
        .collection(_roomsCollection)
        .doc(roomCode.toUpperCase())
        .get();

    if (!roomDoc.exists) return null;
    return GameRoom.fromFirestore(roomDoc);
  }

  /// Listens to room updates
  Stream<GameRoom?> watchRoom(String roomCode) {
    return _firestore
        .collection(_roomsCollection)
        .doc(roomCode.toUpperCase())
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;
          return GameRoom.fromFirestore(snapshot);
        });
  }

  /// Adds a move to the game
  Future<void> addMove({
    required String roomCode,
    required String from,
    required String to,
    required String piece,
    required String? capturedPiece,
    required String newFen,
  }) async {
    final move = {
      'from': from,
      'to': to,
      'piece': piece,
      'capturedPiece': capturedPiece,
      'timestamp': FieldValue.serverTimestamp(),
    };

    final room = await getRoom(roomCode);
    if (room == null) return;

    final newTurn = room.currentTurn == 'white' ? 'black' : 'white';

    await _firestore.collection(_roomsCollection).doc(roomCode).update({
      'moves': FieldValue.arrayUnion([move]),
      'gameState.fen': newFen,
      'gameState.currentTurn': newTurn,
      'lastMoveAt': FieldValue.serverTimestamp(),
    });
  }

  /// Updates game status (e.g., checkmate, draw)
  Future<void> updateGameStatus(String roomCode, String status) async {
    await _firestore.collection(_roomsCollection).doc(roomCode).update({
      'gameState.status': status,
    });
  }

  /// Deletes a room
  Future<void> deleteRoom(String roomCode) async {
    await _firestore.collection(_roomsCollection).doc(roomCode).delete();
  }
}
