// services/webrtc_service.dart

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../signaling.dart'; // Your signaling service

class WebRTCService {
  final Socket _socket = SignallingService.instance.socket!;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  List<RTCIceCandidate> _rtcIceCandidates = [];

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  // Callbacks to notify the Cubit/UI of changes
  Function(MediaStream stream)? onRemoteStream;
  Function(MediaStream stream)? onLocalStream;

  Future<void> initialize() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  Future<void> setupPeerConnection({
    required String calleeId,
    required String callerId,
    dynamic offer,
  }) async {
    _peerConnection = await createPeerConnection({
      'iceServers': [
        {
          'urls': [
            'turn:35.187.243.213:3478?transport=udp',
            'turn:35.187.243.213:3478?transport=tcp',
          ],
          'username': 'flutter',
          'credential': '123456',
        },
      ],
    });

    // Listen for remote peer's media stream
    _peerConnection!.onTrack = (event) {
      remoteRenderer.srcObject = event.streams[0];
      onRemoteStream?.call(event.streams[0]);
    };

    // Get local user media
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {'facingMode': 'user'},
    });

    // Add local media tracks to the connection
    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    localRenderer.srcObject = _localStream;
    onLocalStream?.call(_localStream!);

    if (offer != null) {
      // Incoming call flow
      await _handleIncomingCall(offer, callerId);
    } else {
      // Outgoing call flow
      await _handleOutgoingCall(calleeId);
    }
  }

  Future<void> _handleIncomingCall(dynamic offer, String callerId) async {
    _socket.on("IceCandidate", (data) {
      _peerConnection!.addCandidate(
        RTCIceCandidate(
          data["iceCandidate"]["candidate"],
          data["iceCandidate"]["id"],
          data["iceCandidate"]["label"],
        ),
      );
    });

    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(offer["sdp"], offer["type"]),
    );

    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    _socket.emit("answerCall", {
      "callerId": callerId,
      "sdpAnswer": answer.toMap(),
    });
  }

  Future<void> _handleOutgoingCall(String calleeId) async {
    _peerConnection!.onIceCandidate =
        (candidate) => _rtcIceCandidates.add(candidate);

    _socket.on("callAnswered", (data) async {
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(
          data["sdpAnswer"]["sdp"],
          data["sdpAnswer"]["type"],
        ),
      );

      for (RTCIceCandidate candidate in _rtcIceCandidates) {
        _socket.emit("IceCandidate", {
          "calleeId": calleeId,
          "iceCandidate": {
            "id": candidate.sdpMid,
            "label": candidate.sdpMLineIndex,
            "candidate": candidate.candidate,
          },
        });
      }
    });

    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    _socket.emit('makeCall', {"calleeId": calleeId, "sdpOffer": offer.toMap()});
  }

  void leaveCall({required String recipientId}) {
    _socket.emit("endCall", {"calleeId": recipientId});
    dispose();
  }

  void toggleMic(bool isAudioOn) {
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = isAudioOn;
    });
  }

  void toggleCamera(bool isVideoOn) {
    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = isVideoOn;
    });
  }

  void switchCamera() {
    _localStream?.getVideoTracks().forEach((track) {
      // ignore: deprecated_member_use
      track.switchCamera();
    });
  }

  void dispose() {
    localRenderer.dispose();
    remoteRenderer.dispose();
    _localStream?.dispose();
    _peerConnection?.dispose();
  }
}
