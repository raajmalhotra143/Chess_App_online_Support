import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../data/repositories/online_game_repository.dart';
import '../../../data/models/game_room.dart';

/// Screen for joining an existing online game room
class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final OnlineGameRepository _repository = OnlineGameRepository();
  final TextEditingController _roomCodeController = TextEditingController();
  bool _isJoining = false;
  String? _error;
  bool _showScanner = false;

  Future<void> _joinRoom(String roomCode) async {
    if (roomCode.trim().isEmpty) {
      setState(() => _error = 'Please enter a room code');
      return;
    }

    setState(() {
      _isJoining = true;
      _error = null;
    });

    try {
      final room = await _repository.joinRoom(
        roomCode: roomCode.trim().toUpperCase(),
        guestUid:
            'user_${DateTime.now().millisecondsSinceEpoch}', // TODO: Use actual user ID
        guestName: 'Player 2', // TODO: Use actual user name
      );

      if (room == null) {
        setState(() {
          _error = 'Room not found or already full';
          _isJoining = false;
        });
        return;
      }

      // Successfully joined! Navigate to game
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/online-game',
          arguments: room,
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to join room: $e';
        _isJoining = false;
      });
    }
  }

  void _onQRScanned(BarcodeCapture capture) {
    if (capture.barcodes.isNotEmpty) {
      final code = capture.barcodes.first.rawValue;
      if (code != null && code.isNotEmpty) {
        setState(() => _showScanner = false);
        _joinRoom(code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Room'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: _showScanner ? _buildQRScanner() : _buildManualInput(),
    );
  }

  Widget _buildManualInput() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(
                Icons.meeting_room,
                size: 80,
                color: Color(0xFF2196F3),
              ),
              const SizedBox(height: 24),
              const Text(
                'Join Game',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter the 6-digit room code',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Room Code Input
              TextField(
                controller: _roomCodeController,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
                maxLength: 6,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'ABC123',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF2196F3),
                      width: 2,
                    ),
                  ),
                  errorText: _error,
                  counterText: '',
                ),
                onSubmitted: _joinRoom,
              ),

              const SizedBox(height: 24),

              // Join Button
              ElevatedButton(
                onPressed: _isJoining
                    ? null
                    : () => _joinRoom(_roomCodeController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: _isJoining
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Join Game',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              const SizedBox(height: 24),

              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 24),

              // Scan QR Code Button
              OutlinedButton.icon(
                onPressed: () => setState(() => _showScanner = true),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan QR Code'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2196F3),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFF2196F3), width: 2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQRScanner() {
    return Stack(
      children: [
        MobileScanner(onDetect: _onQRScanned),
        // Overlay
        Container(
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5)),
        ),
        // Scanner frame
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        // Instructions
        Positioned(
          top: 100,
          left: 0,
          right: 0,
          child: Text(
            'Scan the QR code',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(blurRadius: 4, color: Colors.black)],
            ),
          ),
        ),
        // Cancel button
        Positioned(
          top: 40,
          left: 16,
          child: IconButton(
            onPressed: () => setState(() => _showScanner = false),
            icon: const Icon(Icons.close, color: Colors.white, size: 32),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }
}
