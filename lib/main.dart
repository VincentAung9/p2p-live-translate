import 'dart:math';
import 'package:flutter/material.dart';
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
  final String websocketUrl =
      "https://smagent-39445099784.asia-southeast1.run.app";

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      // home: HomePage(selfCallerID: selfCallerID),
      home: JoinScreen(selfCallerId: selfCallerID),
    );
  }
}
