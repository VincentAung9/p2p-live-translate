// services/stt_service.dart

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../signaling.dart';

class SttService {
  final Socket _socket = SignallingService.instance.socket!;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  StreamController<Uint8List>? _audioStreamController;
  final StreamController<String> _translationController =
      StreamController<String>.broadcast();
  List<Uint8List> _recordChunks = [];

  Stream<String> get translationStream => _translationController.stream;
  bool _isInitialized = false;

  String? _language;
  String? _recipientId;
  Future<void> initialize({
    required String language,
    required String recipientId,
  }) async {
    // Store parameters for when we stop recording
    _language = language;
    _recipientId = recipientId;
    // Listen for results from the server
    //_socket.emit("startSTT", {"language": language, "to": recipientId});
    _socket.on("sttResult", (data) {
      _translationController.add(data["translated"]);
    });

    // Start the process
    /*  await _start(language: language, recipientId: recipientId); */
  }

  /*   Future<void> _start({
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
 */

  /// Starts recording audio to a temporary file.
  Future<void> startRecord() async {
    try {
      debugPrint("🔵 Attempting to open recorder...");
      await _recorder.openRecorder();
      debugPrint("✅ Recorder opened successfully.");
      _isInitialized = true;
    } catch (e) {
      debugPrint("❌ FAILED TO OPEN RECORDER: $e");
    }
    debugPrint(
      "🎸 start recording._isInitialized:${_isInitialized}.is_recording: ${_recorder.isRecording}..",
    );
    if (!_isInitialized || _recorder.isRecording) return;

    try {
      debugPrint("🎸 start recording....");
      _recordChunks.clear();
      _audioStreamController = StreamController<Uint8List>();
      _audioStreamController!.stream.listen((chunk) {
        _recordChunks.add(chunk);
      });
      await _recorder.startRecorder(
        toStream: _audioStreamController?.sink,
        codec: Codec.pcm16,
        sampleRate: 16000,
        numChannels: 1,
      );
    } catch (e) {
      debugPrint("🎸❗️ start recording error: ${e}");
    }
  }

  /// Stops recording and sends the complete audio file to the server.
  Future<void> stopRecord() async {
    if (!_isInitialized || !_recorder.isRecording) return;

    await _recorder.stopRecorder();
    await _audioStreamController?.close();

    // Merge all chunks into one Uint8List
    final totalLength = _recordChunks.fold<int>(0, (a, b) => a + b.length);
    final audioBytes = Uint8List(totalLength);
    int offset = 0;
    for (var chunk in _recordChunks) {
      audioBytes.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }

    // Base64 encode and send to backend
    _socket.emit("audioRecording", {
      "language": _language,
      "to": _recipientId,
      "audio": audioBytes,
      "format": "LINEAR16",
    });

    debugPrint("🚀 Audio sent. Total bytes: ${audioBytes.length}");
    _recordChunks.clear();
  }

  /// Cleans up all resources.
  Future<void> dispose() async {
    if (_recorder.isRecording) {
      await _recorder.stopRecorder();
    }
    await _recorder.closeRecorder();
    _translationController.close();
    _socket.off("sttResult");
    _isInitialized = false;
  }

  bool isRecording() {
    return _recorder.isRecording;
  }
}
