// cubit/call_cubit.dart
import 'dart:async';
import 'package:equatable/equatable.dart';
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
// cubit/call_cubit.dart

// 1. Define the State
class CallState extends Equatable {
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;
  final bool isAudioOn;
  final bool isVideoOn;
  final bool isFrontCameraSelected;
  final String translationText;
  final CallStatus status; // <-- ADD THIS

  const CallState({
    required this.localRenderer,
    required this.remoteRenderer,
    this.isAudioOn = true,
    this.isVideoOn = true,
    this.isFrontCameraSelected = true,
    this.translationText = "",
    this.status = CallStatus.initial, // <-- ADD THIS
  });

  CallState copyWith({
    bool? isAudioOn,
    bool? isVideoOn,
    bool? isFrontCameraSelected,
    String? translationText,
    CallStatus? status, // <-- ADD THIS
  }) {
    return CallState(
      localRenderer: localRenderer,
      remoteRenderer: remoteRenderer,
      isAudioOn: isAudioOn ?? this.isAudioOn,
      isVideoOn: isVideoOn ?? this.isVideoOn,
      isFrontCameraSelected:
          isFrontCameraSelected ?? this.isFrontCameraSelected,
      translationText: translationText ?? this.translationText,
      status: status ?? this.status, // <-- ADD THIS
    );
  }

  @override
  List<Object> get props => [
    isAudioOn,
    isVideoOn,
    isFrontCameraSelected,
    translationText,
    status, // <-- ADD THIS TO PROPS
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
      // ✅ Now we are changing a property that is in `props`
      emit(state.copyWith(status: CallStatus.remoteStreamAttached));
    };
    _webRTCService.onLocalStream = (stream) {
      // ✅ This will now trigger a rebuild
      emit(state.copyWith(status: CallStatus.localStreamAttached));
    };
    // ✅ LISTEN FOR CONNECTION STATE CHANGES
    _webRTCService.onConnectionStateChanged = (connectionState) {
      if (connectionState ==
              RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          connectionState ==
              RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          connectionState ==
              RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        // Emit a state that reflects the disconnection
        emit(state.copyWith(status: CallStatus.disconnected));
      }
    };
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
      emit(state.copyWith(translationText: text));
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

  @override
  Future<void> close() {
    _webRTCService.dispose();
    _sttService.dispose();
    _translationSubscription?.cancel();
    return super.close();
  }
}
