// screens/call_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:video_live_translation/bloc/call_cubit.dart';
import 'package:video_live_translation/bloc/join_cubit.dart';
import 'package:video_live_translation/screens/join_screen.dart';
import 'package:video_live_translation/service/stt_service.dart';
import 'package:video_live_translation/service/webrtc_service.dart';

class CallScreen extends StatefulWidget {
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
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  @override
  void deactivate() {
    debugPrint("❌----Deactivate----🔥");
    context.read<JoinCubit>().resetState();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => CallCubit(WebRTCService(), SttService())..init(
            callerId: widget.callerId,
            calleeId: widget.calleeId,
            selfCaller: widget.selfCaller,
            selectedLanguage: widget.selectedLanguage,
            offer: widget.offer,
          ),
      child: const _CallScreenView(),
    );
  }
}

class _CallScreenView extends StatelessWidget {
  const _CallScreenView();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Note: You may want to handle callEnded signal here and show a dialog
    // by listening to your signaling service and maybe pushing an event to the cubit.

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(title: const Text("P2P Call App")),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  BlocSelector<JoinCubit, JoinState, bool>(
                    selector: (state) => state.callEnd,
                    builder: (context, callEnd) {
                      return BlocConsumer<CallCubit, CallState>(
                        listener: (context, state) {},
                        listenWhen: (pre, cur) => pre.status != cur.status,
                        builder: (context, state) {
                          return state.remoteRenderer.srcObject == null ||
                                  callEnd
                              ? Container(
                                color: Colors.black,
                                height: size.height,
                                width: size.width,
                                child: Center(
                                  child: Text(
                                    callEnd
                                        ? "Participant disconnected."
                                        : "Waiting for the other participant to join…”",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                              : RTCVideoView(
                                state.remoteRenderer,
                                objectFit:
                                    RTCVideoViewObjectFit
                                        .RTCVideoViewObjectFitCover,
                              );
                        },
                      );
                    },
                  ),
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: SizedBox(
                      height: 150,
                      width: 120,
                      child: BlocConsumer<CallCubit, CallState>(
                        listener: (_, _) {},
                        listenWhen:
                            (pre, cur) =>
                                pre.status != cur.status ||
                                pre.isFrontCameraSelected !=
                                    cur.isFrontCameraSelected,
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
                  Positioned(
                    top: 80,
                    left: 20,
                    right: 20,
                    child: BlocSelector<CallCubit, CallState, String>(
                      selector: (state) => state.translationText,
                      builder: (context, state) {
                        return state.isEmpty
                            ? const SizedBox()
                            : Container(
                              height: 100,
                              color: Colors.black54,
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                state,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  BlocSelector<CallCubit, CallState, bool>(
                    selector: (state) => state.isAudioOn,
                    builder: (context, state) {
                      return IconButton(
                        icon: Icon(state ? Icons.mic : Icons.mic_off),
                        onPressed: () => context.read<CallCubit>().toggleMic(),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.call_end),
                    iconSize: 30,
                    onPressed: () {
                      // Access original widget properties to pass to leaveCall
                      final parent =
                          context.findAncestorWidgetOfExactType<CallScreen>()!;
                      context.read<CallCubit>().leaveCall(
                        calleeId: parent.calleeId,
                        callerId: parent.callerId,
                        selfCaller: parent.selfCaller,
                      );
                      Navigator.pop(context);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.cameraswitch),
                    onPressed: () => context.read<CallCubit>().switchCamera(),
                  ),
                  BlocSelector<CallCubit, CallState, bool>(
                    selector: (state) => state.isVideoOn,
                    builder: (context, state) {
                      return IconButton(
                        icon: Icon(state ? Icons.videocam : Icons.videocam_off),
                        onPressed:
                            () => context.read<CallCubit>().toggleCamera(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
