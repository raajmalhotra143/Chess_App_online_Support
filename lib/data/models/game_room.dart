import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

/// Online game room model
class GameRoom {
  final String roomId;
  final String hostUid;
  final String hostName;
  final String hostColor; // 'white' or 'black'
  final String? guestUid;
  final String? guestName;
  final String? guestColor;
  final String fenPosition; // Current board state in FEN notation
  final String currentTurn; // 'white' or 'black'
  final String status; // 'waiting', 'active', 'completed'
  final List<Map<String, dynamic>> moves; // Move history
  final DateTime createdAt;
  final DateTime? lastMoveAt;

  GameRoom({
    required this.roomId,
    required this.hostUid,
    required this.hostName,
    required this.hostColor,
    this.guestUid,
    this.guestName,
    this.guestColor,
    required this.fenPosition,
    required this.currentTurn,
    required this.status,
    required this.moves,
    required this.createdAt,
    this.lastMoveAt,
  });

  /// Creates GameRoom from Firestore document
  factory GameRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GameRoom(
      roomId: doc.id,
      hostUid: data['host']['uid'] as String,
      hostName: data['host']['name'] as String,
      hostColor: data['host']['color'] as String,
      guestUid: data['guest']?['uid'] as String?,
      guestName: data['guest']?['name'] as String?,
      guestColor: data['guest']?['color'] as String?,
      fenPosition: data['gameState']['fen'] as String,
      currentTurn: data['gameState']['currentTurn'] as String,
      status: data['gameState']['status'] as String,
      moves: List<Map<String, dynamic>>.from(data['moves'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastMoveAt: data['lastMoveAt'] != null
          ? (data['lastMoveAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Converts to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'host': {'uid': hostUid, 'name': hostName, 'color': hostColor},
      'guest': guestUid != null
          ? {'uid': guestUid, 'name': guestName, 'color': guestColor}
          : null,
      'gameState': {
        'fen': fenPosition,
        'currentTurn': currentTurn,
        'status': status,
      },
      'moves': moves,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMoveAt': lastMoveAt != null ? Timestamp.fromDate(lastMoveAt!) : null,
    };
  }

  /// Generates a random 6-character room code
  static String generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }
}
