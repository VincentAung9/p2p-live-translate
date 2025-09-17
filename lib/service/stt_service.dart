// services/stt_service.dart

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../signaling.dart';

class SttService {
  final Socket _socket = SignallingService.instance.socket!;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  StreamController<Uint8List>? _audioStreamController;
  final StreamController<String> _translationController =
      StreamController<String>.broadcast();

  Stream<String> get translationStream => _translationController.stream;

  Future<void> initialize({
    required String language,
    required String recipientId,
  }) async {
    await _recorder.openRecorder();

    // Listen for results from the server
    _socket.on("sttResult", (data) {
      _translationController.add(data["translated"]);
    });

    // Start the process
    await _start(language: language, recipientId: recipientId);
  }

  Future<void> _start({
    required String language,
    required String recipientId,
  }) async {
    _audioStreamController = StreamController<Uint8List>();
    _audioStreamController!.stream.listen((chunk) {
      _socket.emit("audioChunk", chunk);
    });

    _socket.emit("startSTT", {"language": language, "to": recipientId});

    await _recorder.startRecorder(
      toStream: _audioStreamController?.sink,
      codec: Codec.pcm16,
      sampleRate: 16000,
      numChannels: 1,
    );
  }

  Future<void> dispose() async {
    await _recorder.stopRecorder();
    _socket.emit("stopSTT");
    _audioStreamController?.close();
    _translationController.close();
    _socket.off("sttResult"); // Important: remove the listener
  }
}
