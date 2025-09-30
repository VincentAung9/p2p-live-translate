/* import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:video_live_translation/bloc/call_cubit.dart';
import 'package:video_live_translation/service/stt_service.dart';
import 'package:video_live_translation/service/webrtc_service.dart';
import 'package:animate_do/animate_do.dart';

import 'join_screen.dart';

class CallScreen extends StatelessWidget {
  final String callerId, calleeId;
  final bool selfCaller;
  final dynamic offer;
  final Language selectedLanguage;

  const CallScreen({
    super.key,
    this.offer,
    required this.callerId,
    required this.calleeId,
    required this.selfCaller,
    required this.selectedLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => CallCubit(WebRTCService(), SttService())..init(
            callerId: callerId,
            calleeId: calleeId,
            selfCaller: selfCaller,
            selectedLanguage: selectedLanguage,
            offer: offer,
          ),
      child: const _CallScreenView(),
    );
  }
}

// Assuming other imports remain the same
class _CallScreenView extends StatelessWidget {
  const _CallScreenView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top half: Video section with equal size for caller and receiver
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.grey[200],
                child: Row(
                  children: [
                    // Remote video (receiver)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: BlocBuilder<CallCubit, CallState>(
                          builder: (context, state) {
                            if (state.status == CallStatus.disconnected) {
                              return _infoText("Participant disconnected.");
                            } else if (state.remoteRenderer.srcObject == null) {
                              return _infoText("Waiting for participant...");
                            } else {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: RTCVideoView(
                                  state.remoteRenderer,
                                  objectFit:
                                      RTCVideoViewObjectFit
                                          .RTCVideoViewObjectFitCover,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    // Local video (caller)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BlocBuilder<CallCubit, CallState>(
                            builder: (context, state) {
                              return RTCVideoView(
                                state.localRenderer,
                                mirror: state.isFrontCameraSelected,
                                objectFit:
                                    RTCVideoViewObjectFit
                                        .RTCVideoViewObjectFitCover,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom half: Subtitles & History
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Current transcription with animation
                    BlocSelector<CallCubit, CallState, Map<String, dynamic>>(
                      // Combine selectors
                      selector:
                          (state) => {
                            'text': state.translationText,
                            'isRecording':
                                state.recordingStatus ==
                                RecordingStatus.recordingStarted,
                          },
                      builder: (context, data) {
                        final text = data['text'] as String;
                        final isRecording = data['isRecording'] as bool;
                        return AnimatedOpacity(
                          opacity: text.isNotEmpty ? 1.0 : 0.7,
                          duration: const Duration(milliseconds: 300),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    // color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    text.isNotEmpty
                                        ? text
                                        : (isRecording
                                            ? "You are Speaking..."
                                            : "Listening..."),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              BlocSelector<
                                CallCubit,
                                CallState,
                                RecordingStatus
                              >(
                                selector: (state) => state.recordingStatus,
                                builder: (context, status) {
                                  final micOn =
                                      status ==
                                      RecordingStatus.recordingStarted;
                                  return Container(
                                    margin: const EdgeInsets.only(
                                      left: 12,
                                      right: 4,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          micOn
                                              ? Color.fromARGB(
                                                (0.9 * 255).toInt(),
                                                76,
                                                175,
                                                80,
                                              )
                                              : Color.fromARGB(
                                                (0.9 * 255).toInt(),
                                                244,
                                                67,
                                                54,
                                              ),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.08,
                                          ),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          micOn ? Icons.mic : Icons.mic_off,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          micOn ? 'Mic On' : 'Mic Off',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    // Subtitles history
                    Expanded(
                      child: BlocSelector<CallCubit, CallState, List<String>>(
                        selector: (state) => state.subtitleHistory,
                        builder: (context, history) {
                          return ListView.builder(
                            reverse: true, // Newest subtitles at the bottom
                            itemCount: history.length,
                            itemBuilder: (_, index) {
                              final messageNumber = index + 1;
                              final message = history[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Number badge
                                    Container(
                                      margin: const EdgeInsets.only(
                                        right: 8,
                                        top: 2,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '$messageNumber',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    // Chat bubble
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.03,
                                              ),
                                              blurRadius: 2,
                                              offset: Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          message,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const _CallControls(),
            ),
          ],
        ),
      ),
    );
  }

  // Helper: for video status messages
  Widget _infoText(String text) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _CallControls extends StatefulWidget {
  const _CallControls();

  @override
  State<_CallControls> createState() => _CallControlsState();
}

class _CallControlsState extends State<_CallControls>
    with SingleTickerProviderStateMixin {
  bool? _showCallEndResult; // null: nothing, true: Yes, false: No
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleCallEnd() async {
    setState(() {
      _showCallEndResult = null;
    });
    // Show animated dialog with BounceInDown
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return BounceInDown(
          duration: const Duration(milliseconds: 500),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 25),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: Color.fromARGB((0.98 * 255).toInt(), 255, 255, 255),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(
                      child: Text(
                        'Would you like end this call?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(ctx).pop(true);
                          },
                          icon: const Icon(Icons.phone, color: Colors.white),
                          label: const Text(
                            'End Now',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    setState(() {
      _showCallEndResult = result;
    });
    if (result == true) {
      final parent = context.findAncestorWidgetOfExactType<CallScreen>()!;
      context.read<CallCubit>().leaveCall(
        calleeId: parent.calleeId,
        callerId: parent.callerId,
        selfCaller: parent.selfCaller,
      );
      Navigator.pop(context);
    } else {
      // Show animated No for a moment
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        _showCallEndResult = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          decoration: BoxDecoration(
            color: Color.fromARGB((0.9 * 255).toInt(), 255, 255, 255),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color.fromARGB((0.25 * 255).toInt(), 255, 255, 255),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // End call button: red circle, white icon
              GestureDetector(
                onTap: _handleCallEnd,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: const Icon(
                    Icons.call_end,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              // Microphone button with listening animation
              BlocSelector<CallCubit, CallState, RecordingStatus>(
                selector: (state) => state.recordingStatus,
                builder: (context, status) {
                  return _AnimatedMicButton(
                    isRecording: status == RecordingStatus.recordingStarted,
                    onPressed: () {
                      final cubit = context.read<CallCubit>();
                      if (status == RecordingStatus.recordingStarted) {
                        cubit.stopRecord();
                      } else {
                        cubit.startRecord();
                      }
                    },
                  );
                },
              ),
              // Speaker toggle button
              BlocSelector<CallCubit, CallState, bool>(
                selector: (state) => state.isSpeakerOn,
                builder: (context, isSpeakerOn) {
                  return GestureDetector(
                    onTap: () => context.read<CallCubit>().toggleSpeaker(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isSpeakerOn ? Colors.green[100] : Colors.grey[200],
                      ),
                      child: Icon(
                        isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                        color:
                            isSpeakerOn ? Colors.green[800] : Colors.grey[900],
                        size: 30,
                      ),
                    ),
                  );
                },
              ),
              // Camera switch button: round with white color, icon changes on press
              BlocBuilder<CallCubit, CallState>(
                buildWhen:
                    (prev, curr) =>
                        prev.isFrontCameraSelected !=
                        curr.isFrontCameraSelected,
                builder: (context, state) {
                  final isFront = state.isFrontCameraSelected;
                  return GestureDetector(
                    onTap: () => context.read<CallCubit>().switchCamera(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                      ),
                      child: Icon(
                        isFront ? Icons.camera : Icons.camera_alt_outlined,
                        color: Colors.grey[900],
                        size: 30,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        // Animated Yes/No feedback after dialog
        if (_showCallEndResult != null)
          Positioned(
            top: -60,
            child: AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 400),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color:
                      _showCallEndResult!
                          ? Color.fromARGB((0.9 * 255).toInt(), 76, 175, 80)
                          : Color.fromARGB((0.9 * 255).toInt(), 244, 67, 54),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _showCallEndResult! ? Icons.check_circle : Icons.cancel,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _showCallEndResult! ? 'Yes' : 'No',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Helper widget for animated microphone button
class _AnimatedMicButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onPressed;

  const _AnimatedMicButton({
    required this.isRecording,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha(26),
      ),
      child: GestureDetector(
        onTap: onPressed,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Microphone icon
            Image.asset(
              isRecording ? "assets/microphone.gif" : "assets/microphone.png",
              width: isRecording ? 60 : 40,
              height: isRecording ? 60 : 40,
            ),
            // Pulsing effect when recording
            if (isRecording)
              AnimatedScale(
                scale: 1.2,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:video_live_translation/bloc/call_cubit.dart';
import 'package:video_live_translation/service/stt_service.dart';
import 'package:video_live_translation/service/livekit_service.dart'; // <--- CHANGED FROM webrtc_service.dart
import 'package:animate_do/animate_do.dart';

import 'join_screen.dart';

// 1. Update CallScreen parameters for LiveKit
class CallScreen extends StatelessWidget {
  // Retain these for context/history if needed, but they are not used for connection
  // final String callerId, calleeId;
  // final bool selfCaller;
  // final dynamic offer;

  // NEW LiveKit connection parameters
  final String livekitUrl;
  final String livekitToken;
  final Language selectedLanguage;

  const CallScreen({
    super.key,
    required this.livekitUrl, // <--- NEW PARAMETER
    required this.livekitToken, // <--- NEW PARAMETER
    required this.selectedLanguage,
    // Note: The previous WebRTC parameters (callerId, calleeId, selfCaller, offer)
    // are now obsolete for the initial connection phase in this component.
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // 2. Change service initialization and cubit creation
      // Pass LiveKitService and SttService
      create:
          (context) => CallCubit(LiveKitService(), SttService())..init(
            // <--- Updated init arguments
            url: livekitUrl,
            token: livekitToken,
            selectedLanguage: selectedLanguage,
          ),
      child: const _CallScreenView(),
    );
  }
}

// Assuming other imports remain the same
class _CallScreenView extends StatelessWidget {
  const _CallScreenView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top half: Video section with equal size for caller and receiver
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.grey[200],
                child: Row(
                  children: [
                    // Remote video (receiver)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: BlocBuilder<CallCubit, CallState>(
                          builder: (context, state) {
                            if (state.status == CallStatus.disconnected) {
                              return _infoText("Participant disconnected.");
                            } else if (state.remoteRenderer.srcObject == null) {
                              // LiveKit connection status is often faster, but we keep this check
                              return _infoText("Waiting for participant...");
                            } else {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: RTCVideoView(
                                  state.remoteRenderer,
                                  objectFit:
                                      RTCVideoViewObjectFit
                                          .RTCVideoViewObjectFitCover,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    // Local video (caller)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BlocBuilder<CallCubit, CallState>(
                            builder: (context, state) {
                              return RTCVideoView(
                                state.localRenderer,
                                mirror: state.isFrontCameraSelected,
                                objectFit:
                                    RTCVideoViewObjectFit
                                        .RTCVideoViewObjectFitCover,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom half: Subtitles & History
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Current transcription with animation
                    BlocSelector<CallCubit, CallState, Map<String, dynamic>>(
                      // Combine selectors
                      selector:
                          (state) => {
                            'text': state.translationText,
                            'isRecording':
                                state.recordingStatus ==
                                RecordingStatus.recordingStarted,
                          },
                      builder: (context, data) {
                        final text = data['text'] as String;
                        final isRecording = data['isRecording'] as bool;
                        return AnimatedOpacity(
                          opacity: text.isNotEmpty ? 1.0 : 0.7,
                          duration: const Duration(milliseconds: 300),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    // color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    text.isNotEmpty
                                        ? text
                                        : (isRecording
                                            ? "You are Speaking..."
                                            : "Listening..."),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              BlocSelector<
                                CallCubit,
                                CallState,
                                RecordingStatus
                              >(
                                selector: (state) => state.recordingStatus,
                                builder: (context, status) {
                                  final micOn =
                                      status ==
                                      RecordingStatus.recordingStarted;
                                  return Container(
                                    margin: const EdgeInsets.only(
                                      left: 12,
                                      right: 4,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          micOn
                                              ? Color.fromARGB(
                                                (0.9 * 255).toInt(),
                                                76,
                                                175,
                                                80,
                                              )
                                              : Color.fromARGB(
                                                (0.9 * 255).toInt(),
                                                244,
                                                67,
                                                54,
                                              ),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(
                                            0.08,
                                          ), // Used withOpacity for direct access
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          micOn ? Icons.mic : Icons.mic_off,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          micOn ? 'Mic On' : 'Mic Off',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    // Subtitles history
                    Expanded(
                      child: BlocSelector<CallCubit, CallState, List<String>>(
                        selector: (state) => state.subtitleHistory,
                        builder: (context, history) {
                          return ListView.builder(
                            reverse: true, // Newest subtitles at the bottom
                            itemCount: history.length,
                            itemBuilder: (_, index) {
                              final messageNumber = index + 1;
                              final message = history[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Number badge
                                    Container(
                                      margin: const EdgeInsets.only(
                                        right: 8,
                                        top: 2,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent.withOpacity(
                                          0.15,
                                        ), // Used withOpacity for direct access
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '$messageNumber',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    // Chat bubble
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.03,
                                              ), // Used withOpacity for direct access
                                              blurRadius: 2,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          message,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _CallControls(),
            ),
          ],
        ),
      ),
    );
  }

  // Helper: for video status messages
  Widget _infoText(String text) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _CallControls extends StatefulWidget {
  const _CallControls();

  @override
  State<_CallControls> createState() => _CallControlsState();
}

class _CallControlsState extends State<_CallControls>
    with SingleTickerProviderStateMixin {
  bool? _showCallEndResult; // null: nothing, true: Yes, false: No
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleCallEnd() async {
    setState(() {
      _showCallEndResult = null;
    });
    // Show animated dialog with BounceInDown
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return BounceInDown(
          duration: const Duration(milliseconds: 500),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 25),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: Color.fromARGB((0.98 * 255).toInt(), 255, 255, 255),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        0.08,
                      ), // Used withOpacity for direct access
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(
                      child: Text(
                        'Would you like end this call?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(ctx).pop(true);
                          },
                          icon: const Icon(Icons.phone, color: Colors.white),
                          label: const Text(
                            'End Now',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    setState(() {
      _showCallEndResult = result;
    });
    if (result == true) {
      // 3. Update cubit leave call to use the simpler LiveKit version
      // No need for callerId/calleeId/selfCaller
      context.read<CallCubit>().leaveCall();
      Navigator.pop(context);
    } else {
      // Show animated No for a moment
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        _showCallEndResult = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          decoration: BoxDecoration(
            color: Color.fromARGB((0.9 * 255).toInt(), 255, 255, 255),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color.fromARGB((0.25 * 255).toInt(), 255, 255, 255),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // End call button: red circle, white icon
              GestureDetector(
                onTap: _handleCallEnd,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: const Icon(
                    Icons.call_end,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              // Microphone button with listening animation
              BlocSelector<CallCubit, CallState, RecordingStatus>(
                selector: (state) => state.recordingStatus,
                builder: (context, status) {
                  return _AnimatedMicButton(
                    isRecording: status == RecordingStatus.recordingStarted,
                    onPressed: () {
                      final cubit = context.read<CallCubit>();
                      if (status == RecordingStatus.recordingStarted) {
                        cubit.stopRecord();
                      } else {
                        cubit.startRecord();
                      }
                    },
                  );
                },
              ),
              // Speaker toggle button
              BlocSelector<CallCubit, CallState, bool>(
                selector: (state) => state.isSpeakerOn,
                builder: (context, isSpeakerOn) {
                  return GestureDetector(
                    onTap: () => context.read<CallCubit>().toggleSpeaker(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isSpeakerOn ? Colors.green[100] : Colors.grey[200],
                      ),
                      child: Icon(
                        isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                        color:
                            isSpeakerOn ? Colors.green[800] : Colors.grey[900],
                        size: 30,
                      ),
                    ),
                  );
                },
              ),
              // Camera switch button: round with white color, icon changes on press
              /*       BlocBuilder<CallCubit, CallState>(
                buildWhen:
                    (prev, curr) =>
                        prev.isFrontCameraSelected !=
                        curr.isFrontCameraSelected,
                builder: (context, state) {
                  final isFront = state.isFrontCameraSelected;
                  return GestureDetector(
                    onTap: () => context.read<CallCubit>().switchCamera(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                      ),
                      child: Icon(
                        isFront ? Icons.camera : Icons.camera_alt_outlined,
                        color: Colors.grey[900],
                        size: 30,
                      ),
                    ),
                  );
                },
              ),
           */
            ],
          ),
        ),
        // Animated Yes/No feedback after dialog
        if (_showCallEndResult != null)
          Positioned(
            top: -60,
            child: AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 400),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color:
                      _showCallEndResult!
                          ? Color.fromARGB((0.9 * 255).toInt(), 76, 175, 80)
                          : Color.fromARGB((0.9 * 255).toInt(), 244, 67, 54),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        0.08,
                      ), // Used withOpacity for direct access
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _showCallEndResult! ? Icons.check_circle : Icons.cancel,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _showCallEndResult! ? 'Yes' : 'No',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Helper widget for animated microphone button
class _AnimatedMicButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onPressed;

  const _AnimatedMicButton({
    required this.isRecording,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.1), // Adjusted to use .withOpacity
      ),
      child: GestureDetector(
        onTap: onPressed,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Microphone icon
            Image.asset(
              isRecording ? "assets/microphone.gif" : "assets/microphone.png",
              width: isRecording ? 60 : 40,
              height: isRecording ? 60 : 40,
            ),
            // Pulsing effect when recording
            if (isRecording)
              AnimatedScale(
                scale: 1.2,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
