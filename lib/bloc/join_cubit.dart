// cubit/join_cubit.dart

import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../signaling.dart';

// 1. Define the State
class JoinState extends Equatable {
  // This holds the data for the incoming call notification
  final Map<String, dynamic>? incomingOffer;
  final bool callEnd;

  const JoinState({this.incomingOffer, this.callEnd = false});

  JoinState copyWith({Map<String, dynamic>? incomingOffer, bool? callEnd}) =>
      JoinState(
        incomingOffer: incomingOffer ?? this.incomingOffer,
        callEnd: callEnd ?? this.callEnd,
      );

  @override
  List<Object?> get props => [incomingOffer, callEnd];
}

// 2. Create the Cubit
class JoinCubit extends Cubit<JoinState> {
  final Socket _socket = SignallingService.instance.socket!;

  JoinCubit() : super(const JoinState());

  void init() {
    // Listen for a new call offer from the server
    _socket.on("newCall", _onNewCall);

    // Listen for when the caller cancels the call before it's answered
    _socket.on("leaveCall", _onCallCancelled);

    // Listen for when a call is ended by the other party
    _socket.on("callEnded", _onCallCancelled);
  }

  void _onNewCall(dynamic data) {
    emit(JoinState(incomingOffer: data));
  }

  void _onCallCancelled(dynamic data) {
    emit(const JoinState(incomingOffer: null, callEnd: true));
    // Only clear the offer if the cancellation is for the current incoming call
    /* if (state.incomingOffer != null &&
        (state.incomingOffer!["callerId"] == data["to"] ||
            state.incomingOffer!["callerId"] == data["from"])) {
      debugPrint("Incoming call offer cancelled.");
      emit(const JoinState(incomingOffer: null, callEnd: true));
    } */
  }

  /// Called when the user manually rejects the incoming call.
  void rejectCall() {
    _socket.emit("endCall", {"calleeId": state.incomingOffer?["callerId"]});
    emit(const JoinState(incomingOffer: null));
  }

  void resetState() {
    debugPrint("🔥 Reset State...");
    emit(state.copyWith(callEnd: false, incomingOffer: null));
  }

  @override
  Future<void> close() {
    // IMPORTANT: Remove listeners to prevent memory leaks
    _socket.off("newCall", _onNewCall);
    _socket.off("leaveCall", _onCallCancelled);
    _socket.off("callEnded", _onCallCancelled);
    return super.close();
  }
}
