/* // cubit/call_cubit.dart
import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:video_live_translation/screens/join_screen.dart';
import 'package:video_live_translation/service/stt_service.dart';
import 'package:video_live_translation/service/webrtc_service.dart';

// You can add this to your call_cubit.dart file
enum CallStatus {
  initial,
  localStreamAttached,
  remoteStreamAttached,
  disconnected,
}

enum RecordingStatus { recordingStarted, recordingStopped }
// cubit/call_cubit.dart

// 1. Define the State
class CallState extends Equatable {
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;
  final bool isAudioOn;
  final bool isVideoOn;
  final bool isFrontCameraSelected;
  final String translationText;
  final CallStatus status;
  final RecordingStatus recordingStatus;
  final List<String> subtitleHistory; // added
  final bool isSpeakerOn; // <-- added

  const CallState({
    required this.localRenderer,
    required this.remoteRenderer,
    this.isAudioOn = true,
    this.isVideoOn = true,
    this.isFrontCameraSelected = true,
    this.translationText = "",
    this.status = CallStatus.initial,
    this.recordingStatus = RecordingStatus.recordingStopped,
    this.subtitleHistory = const [],
    this.isSpeakerOn = true, // <-- default true
  });

  CallState copyWith({
    bool? isAudioOn,
    bool? isVideoOn,
    bool? isFrontCameraSelected,
    String? translationText,
    CallStatus? status,
    RecordingStatus? recordingStatus,
    List<String>? subtitleHistory, // added
    bool? isSpeakerOn, // <-- added
  }) {
    return CallState(
      localRenderer: localRenderer,
      remoteRenderer: remoteRenderer,
      isAudioOn: isAudioOn ?? this.isAudioOn,
      isVideoOn: isVideoOn ?? this.isVideoOn,
      isFrontCameraSelected:
          isFrontCameraSelected ?? this.isFrontCameraSelected,
      translationText: translationText ?? this.translationText,
      status: status ?? this.status,
      recordingStatus: recordingStatus ?? this.recordingStatus,
      subtitleHistory: subtitleHistory ?? this.subtitleHistory,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn, // <-- added
    );
  }

  @override
  List<Object> get props => [
    isAudioOn,
    isVideoOn,
    isFrontCameraSelected,
    translationText,
    status,
    recordingStatus,
    subtitleHistory, // added
    isSpeakerOn, // <-- added
  ];
}

// 2. Create the Cubit
class CallCubit extends Cubit<CallState> {
  final WebRTCService _webRTCService;
  final SttService _sttService;
  StreamSubscription? _translationSubscription;

  CallCubit(this._webRTCService, this._sttService)
    : super(
        CallState(
          localRenderer: _webRTCService.localRenderer,
          remoteRenderer: _webRTCService.remoteRenderer,
        ),
      ) {
    _webRTCService.onRemoteStream = (stream) {
      emit(state.copyWith(status: CallStatus.remoteStreamAttached));
    };
    _webRTCService.onLocalStream = (stream) {
      emit(state.copyWith(status: CallStatus.localStreamAttached));
    };
    _webRTCService.onConnectionStateChanged = (connectionState) {
      if (connectionState ==
              RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          connectionState ==
              RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          connectionState ==
              RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        emit(state.copyWith(status: CallStatus.disconnected));
      }
    };
    // Ensure speaker is on by default
    Helper.setSpeakerphoneOn(true);
  }

  Future<void> init({
    required String callerId,
    required String calleeId,
    required bool selfCaller,
    required Language selectedLanguage,
    dynamic offer,
  }) async {
    await _webRTCService.initialize();
    await _webRTCService.setupPeerConnection(
      calleeId: calleeId,
      callerId: callerId,
      offer: offer,
    );

    await _sttService.initialize(
      language: selectedLanguage == Language.en ? "en-US" : "my-MM",
      recipientId: selfCaller ? calleeId : callerId,
    );

    _translationSubscription = _sttService.translationStream.listen((text) {
      // append to subtitle history as new translations arrive
      final updatedHistory = [...state.subtitleHistory, text];
      emit(
        state.copyWith(translationText: text, subtitleHistory: updatedHistory),
      );
      Future.delayed(const Duration(seconds: 5), () {
        emit(state.copyWith(translationText: ""));
      });
    });
  }

  void leaveCall({
    required String calleeId,
    required String callerId,
    required bool selfCaller,
  }) {
    _webRTCService.leaveCall(recipientId: selfCaller ? calleeId : callerId);
  }

  void toggleMic() {
    final newAudioState = !state.isAudioOn;
    _webRTCService.toggleMic(newAudioState);
    emit(state.copyWith(isAudioOn: newAudioState));
  }

  void toggleCamera() {
    final newVideoState = !state.isVideoOn;
    _webRTCService.toggleCamera(newVideoState);
    emit(state.copyWith(isVideoOn: newVideoState));
  }

  void switchCamera() {
    final newCameraState = !state.isFrontCameraSelected;
    _webRTCService.switchCamera();
    emit(state.copyWith(isFrontCameraSelected: newCameraState));
  }

  void startRecord() async {
    debugPrint("🎸 Start Recording");
    await _sttService.startRecord();
    emit(state.copyWith(recordingStatus: RecordingStatus.recordingStarted));
  }

  void stopRecord() async {
    await _sttService.stopRecord();
    emit(state.copyWith(recordingStatus: RecordingStatus.recordingStopped));
  }

  void toggleSpeaker() {
    final newValue = !state.isSpeakerOn;
    Helper.setSpeakerphoneOn(newValue);
    emit(state.copyWith(isSpeakerOn: newValue));
  }

  void setSpeakerOn(bool value) {
    Helper.setSpeakerphoneOn(value);
    emit(state.copyWith(isSpeakerOn: value));
  }

  @override
  Future<void> close() {
    _webRTCService.dispose();
    _sttService.dispose();
    _translationSubscription?.cancel();
    return super.close();
  }
}
 */

import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart'; // <-- ADD THIS IMPORT
import 'package:video_live_translation/service/livekit_service.dart';
import 'package:video_live_translation/service/stt_service.dart';

import '../screens/join_screen.dart';

enum CallStatus {
  initial,
  localStreamAttached,
  remoteStreamAttached,
  disconnected,
}

enum RecordingStatus { recordingStarted, recordingStopped }

class CallState extends Equatable {
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;
  final bool isAudioOn;
  final bool isVideoOn;
  final bool isFrontCameraSelected;
  final String translationText;
  final CallStatus status;
  final RecordingStatus recordingStatus;
  final List<String> subtitleHistory;
  final bool isSpeakerOn;

  const CallState({
    required this.localRenderer,
    required this.remoteRenderer,
    this.isAudioOn = true,
    this.isVideoOn = true,
    this.isFrontCameraSelected = true,
    this.translationText = "",
    this.status = CallStatus.initial,
    this.recordingStatus = RecordingStatus.recordingStopped,
    this.subtitleHistory = const [],
    this.isSpeakerOn = true,
  });

  CallState copyWith({
    bool? isAudioOn,
    bool? isVideoOn,
    bool? isFrontCameraSelected,
    String? translationText,
    CallStatus? status,
    RecordingStatus? recordingStatus,
    List<String>? subtitleHistory,
    bool? isSpeakerOn,
  }) {
    return CallState(
      localRenderer: localRenderer,
      remoteRenderer: remoteRenderer,
      isAudioOn: isAudioOn ?? this.isAudioOn,
      isVideoOn: isVideoOn ?? this.isVideoOn,
      isFrontCameraSelected:
          isFrontCameraSelected ?? this.isFrontCameraSelected,
      translationText: translationText ?? this.translationText,
      status: status ?? this.status,
      recordingStatus: recordingStatus ?? this.recordingStatus,
      subtitleHistory: subtitleHistory ?? this.subtitleHistory,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
    );
  }

  @override
  List<Object> get props => [
    isAudioOn,
    isVideoOn,
    isFrontCameraSelected,
    translationText,
    status,
    recordingStatus,
    subtitleHistory,
    isSpeakerOn,
  ];
}

class CallCubit extends Cubit<CallState> {
  final LiveKitService _liveKitService;
  final SttService _sttService;
  StreamSubscription? _translationSubscription;

  CallCubit(this._liveKitService, this._sttService)
    : super(
        CallState(
          localRenderer: _liveKitService.localRenderer,
          remoteRenderer: _liveKitService.remoteRenderer,
        ),
      ) {
    _liveKitService.onLocalStream = (stream) {
      emit(state.copyWith(status: CallStatus.localStreamAttached));
    };
    _liveKitService.onRemoteStream = (stream) {
      emit(state.copyWith(status: CallStatus.remoteStreamAttached));
    };
    _liveKitService.onConnectionStateChanged = (connectionState) {
      // FIX: The type is 'ConnectionState' from livekit_client, not 'RoomState'.
      if (connectionState == ConnectionState.disconnected) {
        emit(state.copyWith(status: CallStatus.disconnected));
      }
    };
    // Speaker default ON
    Helper.setSpeakerphoneOn(true);
  }

  Future<void> init({
    required String url,
    required String token,
    required Language selectedLanguage,
  }) async {
    await _liveKitService.initialize();
    await _liveKitService.connect(url: url, token: token);

    await _sttService.initialize(
      language: selectedLanguage == Language.en ? "en-US" : "my-MM",
      recipientId: "livekit",
    );

    _translationSubscription = _sttService.translationStream.listen((text) {
      final updatedHistory = [...state.subtitleHistory, text];
      emit(
        state.copyWith(translationText: text, subtitleHistory: updatedHistory),
      );
      Future.delayed(const Duration(seconds: 5), () {
        emit(state.copyWith(translationText: ""));
      });
    });
  }

  void leaveCall() {
    _liveKitService.disconnect();
  }

  void toggleMic() {
    final newAudioState = !state.isAudioOn;
    _liveKitService.toggleMic(newAudioState);
    emit(state.copyWith(isAudioOn: newAudioState));
  }

  void toggleCamera() {
    final newVideoState = !state.isVideoOn;
    _liveKitService.toggleCamera(newVideoState);
    emit(state.copyWith(isVideoOn: newVideoState));
  }

  void startRecord() async {
    debugPrint("🎸 Start Recording");
    await _sttService.startRecord();
    emit(state.copyWith(recordingStatus: RecordingStatus.recordingStarted));
  }

  void stopRecord() async {
    await _sttService.stopRecord();
    emit(state.copyWith(recordingStatus: RecordingStatus.recordingStopped));
  }

  void toggleSpeaker() {
    final newValue = !state.isSpeakerOn;
    Helper.setSpeakerphoneOn(newValue);
    emit(state.copyWith(isSpeakerOn: newValue));
  }

  void setSpeakerOn(bool value) {
    Helper.setSpeakerphoneOn(value);
    emit(state.copyWith(isSpeakerOn: value));
  }

  @override
  Future<void> close() {
    _liveKitService.disconnect();
    _sttService.dispose();
    _translationSubscription?.cancel();
    return super.close();
  }
}
