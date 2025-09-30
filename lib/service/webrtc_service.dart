import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../signaling.dart'; // Your signaling service

class WebRTCService {
  final Socket _socket = SignallingService.instance.socket!;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  // FIX 1: This list is no longer needed because we will send candidates immediately.
  // List<RTCIceCandidate> _rtcIceCandidates = [];

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  // Callbacks to notify the Cubit/UI of changes
  Function(MediaStream stream)? onRemoteStream;
  Function(RTCPeerConnectionState state)? onConnectionStateChanged;
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
    // FIX 2: Added public STUN servers for better performance.
    // This allows for direct P2P connections when possible, before falling back to TURN.
    _peerConnection = await createPeerConnection({
      /*  'iceServers': [
        {
          'urls': [
            'stun:34.124.203.35:3478',
            'turn:34.124.203.35:3478?transport=udp',
            'turn:34.124.203.35:3478?transport=tcp',
            'turns:34.124.203.35:5349?transport=tcp',
          ],
          'username': 'username1',
          'credential': 'key1',
        },
      ],
      'iceTransportPolicy': 'relay', */
      'iceServers': [
        {
          'urls': [
            'relay1.expressturn.com:3480?transport=udp',
            'relay1.expressturn.com:3480?transport=tcp',
          ],
          'username': '000000002074284219',
          'credential': 'Hr0n60SicfAYt8FayOb86i1WAPU=',
        },
      ],
    });
    _peerConnection!.onConnectionState = (state) {
      debugPrint('🔥 Connection State Changed: $state');
      onConnectionStateChanged?.call(state);
    };

    _peerConnection!.onTrack = (event) {
      remoteRenderer.srcObject = event.streams[0];
      debugPrint("🔥 RemoteRenderer SrcObject: ${(event.streams[0])}");
      onRemoteStream?.call(event.streams[0]);
    };

    // FIX 3: Moved the ICE candidate listener here to avoid race conditions.
    // It now listens for candidates as soon as the peer connection is set up.
    _socket.on("IceCandidate", (data) {
      print("Received ICE candidate from remote peer");
      if (_peerConnection != null) {
        _peerConnection!.addCandidate(
          RTCIceCandidate(
            data["iceCandidate"]["candidate"],
            data["iceCandidate"]["id"],
            data["iceCandidate"]["label"],
          ),
        );
      }
    });

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
    // FIX 4: Send local ICE candidates immediately as they are discovered.
    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate != null) {
        print("Sending ICE candidate to caller");
        _socket.emit("IceCandidate", {
          // Note: Here we send to the 'callerId'
          "calleeId": callerId,
          "iceCandidate": {
            "id": candidate.sdpMid,
            "label": candidate.sdpMLineIndex,
            "candidate": candidate.candidate,
          },
        });
      }
    };

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
    // FIX 5: Send local ICE candidates immediately as they are discovered (Trickle ICE).
    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate != null) {
        print("Sending ICE candidate to callee");
        _socket.emit("IceCandidate", {
          "calleeId": calleeId,
          "iceCandidate": {
            "id": candidate.sdpMid,
            "label": candidate.sdpMLineIndex,
            "candidate": candidate.candidate,
          },
        });
      }
    };

    // FIX 6: The logic to send all candidates after getting an answer is removed.
    _socket.on("callAnswered", (data) async {
      print("Call answered, setting remote description");
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(
          data["sdpAnswer"]["sdp"],
          data["sdpAnswer"]["type"],
        ),
      );
      // The for-loop that sent candidates is now gone from here.
    });

    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    print("Making call with SDP offer");
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
    // It's good practice to remove the listener when disposing
    _socket.off("IceCandidate");
    _socket.off("callAnswered");
  }
}
