import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';
import 'package:video_live_translation/bloc/speech_cubit.dart';
import '../debouncer.dart';
import '../signaling.dart';

class CallScreen extends StatefulWidget {
  final String callerId, calleeId;
  final bool selfCaller;
  final dynamic offer;
  const CallScreen({
    super.key,
    this.offer,
    required this.callerId,
    required this.calleeId,
    required this.selfCaller,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  //translation
  SpeechToText _speechToText = SpeechToText();
  final translator = GoogleTranslator();
  // socket instance
  final socket = SignallingService.instance.socket;

  // videoRenderer for localPeer
  final _localRTCVideoRenderer = RTCVideoRenderer();

  // videoRenderer for remotePeer
  final _remoteRTCVideoRenderer = RTCVideoRenderer();

  // mediaStream for localPeer
  MediaStream? _localStream;

  // RTC peer connection
  RTCPeerConnection? _rtcPeerConnection;

  // list of rtcCandidates to be sent over signalling
  List<RTCIceCandidate> rtcIceCadidates = [];

  // media status
  bool isAudioOn = true, isVideoOn = true, isFrontCameraSelected = true;

  @override
  void initState() {
    // initializing renderers
    _localRTCVideoRenderer.initialize();
    _remoteRTCVideoRenderer.initialize();

    // setup Peer Connection
    _setupPeerConnection();
    _initSpeech();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  //--For Speech--------
  void _initSpeech() async {
    await _speechToText.initialize();
    setState(() {});

    //listen incomming speech
    SignallingService.instance.socket!.on("incomeTranslation", (data) {
      var text = data["text"];
      if (mounted) {
        context.read<SpeechCubit>().change(text);
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) context.read<SpeechCubit>().change("");
        });
      }
    });
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    debugPrint("🔥Start Listenging...");
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    debugPrint("🔥Stop Listengin...");
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  final _debouncer = Debouncer(
    milliseconds: 100,
  ); // wait 0.8 sec after user stops speaking

  void _onSpeechResult(SpeechRecognitionResult result) {
    final text = result.recognizedWords;
    debugPrint("🔥TEXT: $text");
    // debounce the translation request
    _debouncer.run(() async {
      try {
        if (text.isNotEmpty) {
          translator.translate(text, to: widget.selfCaller ? 'my' : 'en').then((
            translationText,
          ) {
            debugPrint("🔥TEXT: $text");
            SignallingService.instance.socket!.emit("translationText", [
              {
                "to": widget.selfCaller ? widget.calleeId : widget.callerId,
                "text": translationText.text,
              },
            ]);

            Future.delayed(const Duration(seconds: 5), () {
              _stopListening();
            });
          });
        }
      } catch (e) {}
    });
  }
  //----------

  _setupPeerConnection() async {
    try {
      // create peer connection
      _rtcPeerConnection = await createPeerConnection({
        'iceServers': [
          {
            'urls': [
              'stun:stun1.l.google.com:19302',
              'stun:stun2.l.google.com:19302',
            ],
          },
        ],
      });

      // listen for remotePeer mediaTrack event
      _rtcPeerConnection!.onTrack = (event) {
        _remoteRTCVideoRenderer.srcObject = event.streams[0];
        setState(() {});
      };

      // get localStream
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': isAudioOn,
        'video':
            isVideoOn
                ? {'facingMode': isFrontCameraSelected ? 'user' : 'environment'}
                : false,
      });

      // add mediaTrack to peerConnection
      _localStream!.getTracks().forEach((track) {
        _rtcPeerConnection!.addTrack(track, _localStream!);
      });

      // set source for local video renderer
      _localRTCVideoRenderer.srcObject = _localStream;
      setState(() {});

      // for Incoming call
      if (widget.offer != null) {
        // listen for Remote IceCandidate
        socket!.on("IceCandidate", (data) {
          String candidate = data["iceCandidate"]["candidate"];
          String sdpMid = data["iceCandidate"]["id"];
          int sdpMLineIndex = data["iceCandidate"]["label"];

          // add iceCandidate
          _rtcPeerConnection!.addCandidate(
            RTCIceCandidate(candidate, sdpMid, sdpMLineIndex),
          );
        });

        // set SDP offer as remoteDescription for peerConnection
        await _rtcPeerConnection!.setRemoteDescription(
          RTCSessionDescription(widget.offer["sdp"], widget.offer["type"]),
        );

        // create SDP answer
        RTCSessionDescription answer = await _rtcPeerConnection!.createAnswer();

        // set SDP answer as localDescription for peerConnection
        _rtcPeerConnection!.setLocalDescription(answer);

        // send SDP answer to remote peer over signalling
        socket!.emit("answerCall", {
          "callerId": widget.callerId,
          "sdpAnswer": answer.toMap(),
        });
      }
      // for Outgoing Call
      else {
        // listen for local iceCandidate and add it to the list of IceCandidate
        _rtcPeerConnection!.onIceCandidate =
            (RTCIceCandidate candidate) => rtcIceCadidates.add(candidate);

        // when call is accepted by remote peer
        socket!.on("callAnswered", (data) async {
          // set SDP answer as remoteDescription for peerConnection
          await _rtcPeerConnection!.setRemoteDescription(
            RTCSessionDescription(
              data["sdpAnswer"]["sdp"],
              data["sdpAnswer"]["type"],
            ),
          );

          // send iceCandidate generated to remote peer over signalling
          for (RTCIceCandidate candidate in rtcIceCadidates) {
            socket!.emit("IceCandidate", {
              "calleeId": widget.calleeId,
              "iceCandidate": {
                "id": candidate.sdpMid,
                "label": candidate.sdpMLineIndex,
                "candidate": candidate.candidate,
              },
            });
          }
        });

        // create SDP Offer
        RTCSessionDescription offer = await _rtcPeerConnection!.createOffer();

        // set SDP offer as localDescription for peerConnection
        await _rtcPeerConnection!.setLocalDescription(offer);

        // make a call to remote peer over signalling
        socket!.emit('makeCall', {
          "calleeId": widget.calleeId,
          "sdpOffer": offer.toMap(),
        });
      }
      // Receive translated text from remote peer
      SignallingService.instance.socket!.on("translationText", (data) {
        context.read<SpeechCubit>().change(data["text"]);
      });
      //endCall from remote
      SignallingService.instance.socket!.on("callEnded", (data) {
        debugPrint("🔥------CALLENDED");
        _localRTCVideoRenderer.dispose();
        _remoteRTCVideoRenderer.dispose();
        _localStream?.dispose();
        _rtcPeerConnection?.dispose();
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text("End Call by ${data["from"]}"),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
        }
      });
    } catch (e) {}
  }

  _leaveCall() {
    //make endcall
    socket!.emit("endCall", {
      "calleeId": widget.selfCaller ? widget.calleeId : widget.callerId,
    });
    // Local cleanup
    _rtcPeerConnection?.close();
    _localStream?.getTracks().forEach((track) => track.stop());
    _localStream?.dispose();
    _localRTCVideoRenderer.srcObject = null;
    _remoteRTCVideoRenderer.srcObject = null;
    if (mounted) {
      Navigator.pop(context);
    }
  }

  _toggleMic() {
    // change status
    isAudioOn = !isAudioOn;
    // enable or disable audio track
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = isAudioOn;
    });
    setState(() {});
  }

  _toggleCamera() {
    // change status
    isVideoOn = !isVideoOn;

    // enable or disable video track
    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = isVideoOn;
    });
    setState(() {});
  }

  _switchCamera() {
    // change status
    isFrontCameraSelected = !isFrontCameraSelected;

    // switch camera
    _localStream?.getVideoTracks().forEach((track) {
      // ignore: deprecated_member_use
      track.switchCamera();
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(title: const Text("P2P Call App")),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  RTCVideoView(
                    _remoteRTCVideoRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: SizedBox(
                      height: 150,
                      width: 120,
                      child: RTCVideoView(
                        _localRTCVideoRenderer,
                        mirror: isFrontCameraSelected,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 80,
                    left: 20,
                    right: 20,
                    child: BlocBuilder<SpeechCubit, String>(
                      builder: (context, state) {
                        return Container(
                          height: 100,
                          color:
                              state.isNotEmpty
                                  ? Colors.black54
                                  : Colors.transparent,
                          padding: EdgeInsets.all(8),
                          child: Text(
                            state,
                            style: TextStyle(color: Colors.white, fontSize: 16),
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
                  IconButton(
                    icon: Icon(
                      _speechToText.isListening ? Icons.mic : Icons.mic_off,
                    ),
                    onPressed:
                        _speechToText.isListening
                            ? _stopListening
                            : _startListening,
                  ),
                  IconButton(
                    icon: Icon(isAudioOn ? Icons.mic : Icons.mic_off),
                    onPressed: _toggleMic,
                  ),
                  IconButton(
                    icon: const Icon(Icons.call_end),
                    iconSize: 30,
                    onPressed: _leaveCall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.cameraswitch),
                    onPressed: _switchCamera,
                  ),
                  IconButton(
                    icon: Icon(isVideoOn ? Icons.videocam : Icons.videocam_off),
                    onPressed: _toggleCamera,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _localRTCVideoRenderer.dispose();
    _remoteRTCVideoRenderer.dispose();
    _localStream?.dispose();
    _rtcPeerConnection?.dispose();

    super.dispose();
  }
}
