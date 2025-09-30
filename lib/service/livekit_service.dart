import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart';

class LiveKitService {
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  Room? _room;
  EventsListener<RoomEvent>? _listener;

  Function(MediaStream stream)? onLocalStream;
  Function(MediaStream stream)? onRemoteStream;
  Function(ConnectionState state)? onConnectionStateChanged;

  Future<void> initialize() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  Future<void> connect({required String url, required String token}) async {
    final room = Room();
    await room.connect(
      url,
      token,
      roomOptions: const RoomOptions(adaptiveStream: true, dynacast: true),
    );
    _room = room;
    _listener = _room!.createListener();

    // Publish Local Tracks
    await _room!.localParticipant?.setMicrophoneEnabled(true);
    await _room!.localParticipant?.setCameraEnabled(true);

    //  For Local Tracks, binding MediaStream is often sufficient.
    for (final pub in _room!.localParticipant!.trackPublications.values) {
      if (pub.track is LocalVideoTrack) {
        final track = pub.track as LocalVideoTrack;
        localRenderer.srcObject = track.mediaStream;
        onLocalStream?.call(track.mediaStream);
        break;
      }
    }

    // This runs immediately after connecting to find tracks already in the room.
    for (final participant in _room!.remoteParticipants.values) {
      for (final trackPublication in participant.trackPublications.values) {
        if (trackPublication.track is RemoteVideoTrack) {
          final track = trackPublication.track as RemoteVideoTrack;

          remoteRenderer.srcObject = track.mediaStream;
          onRemoteStream?.call(track.mediaStream);
          return;
        }
      }
    }
    // ----------------------------------------------------------------------
    //for future participants joining the room.
    _listener!.on<TrackSubscribedEvent>((event) {
      if (event.track is RemoteVideoTrack) {
        final track = event.track as RemoteVideoTrack;
        remoteRenderer.srcObject = track.mediaStream;
        onRemoteStream?.call(track.mediaStream);
      }
    });

    // Connection state
    _listener!.on<ParticipantDisconnectedEvent>((event) {
      debugPrint(
        'Remote Participant Disconnected: ${event.participant.identity}',
      );

      remoteRenderer.srcObject = null;
      onConnectionStateChanged?.call(ConnectionState.disconnected);
    });

    _listener!.on<RoomDisconnectedEvent>((event) {
      onConnectionStateChanged?.call(_room!.connectionState);
    });
  }

  void toggleMic(bool isAudioOn) {
    _room?.localParticipant?.setMicrophoneEnabled(isAudioOn);
  }

  void toggleCamera(bool isVideoOn) {
    _room?.localParticipant?.setCameraEnabled(isVideoOn);
  }

  Future<void> disconnect() async {
    await _listener?.dispose();
    await _room?.disconnect();
    localRenderer.dispose();
    remoteRenderer.dispose();
  }
}
