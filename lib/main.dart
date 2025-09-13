import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:video_live_translation/bloc/speech_cubit.dart';
import 'package:video_live_translation/screens/speech_test_screen.dart';
import 'package:video_live_translation/signaling.dart';

import 'screens/join_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // signalling server url
  final String websocketUrl = "http://192.168.1.33:3000";

  // generate callerID of local user
  final String selfCallerID = Random()
      .nextInt(999999)
      .toString()
      .padLeft(6, '0');

  @override
  void initState() {
    SignallingService.instance.init(
      websocketUrl: websocketUrl,
      selfCallerID: selfCallerID,
    );
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => SpeechCubit())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: /* SpeechTestScreen()  */ JoinScreen(selfCallerId: selfCallerID),
      ),
    );
  }
}
