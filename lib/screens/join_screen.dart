// screens/join_screen.dart

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:video_live_translation/bloc/join_cubit.dart';
import 'call_screen.dart';
// lib/language.dart (or at the top of join_screen.dart)

enum Language { en, my }

class JoinScreen extends StatelessWidget {
  final String selfCallerId;

  const JoinScreen({super.key, required this.selfCallerId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // The Cubit is created and its listeners are initialized here.
      // The BlocProvider will automatically call cubit.close() when the screen is disposed.
      create: (context) => JoinCubit()..init(),
      child: _JoinScreenView(selfCallerId: selfCallerId),
    );
  }
}

class _JoinScreenView extends StatefulWidget {
  final String selfCallerId;

  const _JoinScreenView({required this.selfCallerId});

  @override
  State<_JoinScreenView> createState() => _JoinScreenViewState();
}

class _JoinScreenViewState extends State<_JoinScreenView> {
  final remoteCallerIdTextEditingController = TextEditingController();
  Language _selectedLanguage = Language.en;
  String? livekitToken;
  String livekitUrl = "wss://p2p-test-omq0i7wx.livekit.cloud";

  Future<String?> fetchToken(String identity, String roomName) async {
    final response = await http.post(
      Uri.parse("https://smagent-39445099784.asia-southeast1.run.app/getToken"),
      body: jsonEncode({"identity": identity, "roomName": roomName}),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      log("🔥. TOKEN received for room: $roomName");
      return jsonDecode(response.body)["token"];
    } else {
      log("❌ Failed to fetch token: ${response.body}");
      return null;
    }
  }

  void _joinCall({
    required BuildContext context,
    required String roomName,
    required Language selectedLanguage,
    required String token,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => CallScreen(
              livekitUrl: livekitUrl,
              livekitToken: token,
              selectedLanguage: selectedLanguage,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Video Call Icon and Title
                    Column(
                      children: [
                        Icon(
                          Icons.videocam_outlined,
                          color: Colors.blue,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Live Translation',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: DropdownButtonFormField<Language>(
                        value: _selectedLanguage,
                        decoration: InputDecoration(
                          labelText: "Your Native Language",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: Language.en,
                            child: Text("🇬🇧  English"),
                          ),
                          DropdownMenuItem(
                            value: Language.my,
                            child: Text("🇲🇲  Myanmar"),
                          ),
                        ],
                        onChanged: (Language? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedLanguage = newValue;
                            });
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    const SizedBox(height: 12),
                    TextField(
                      controller: remoteCallerIdTextEditingController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: "Enter Room Name or Partner ID",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Start Meeting Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Start Meeting Now",
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () async {
                        final roomName =
                            remoteCallerIdTextEditingController.text.trim();
                        if (roomName.isEmpty) {
                          // Show error/snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter a Room ID."),
                            ),
                          );
                          return;
                        }

                        // Fetch token for the dynamic room
                        final token = await fetchToken(
                          widget.selfCallerId,
                          roomName,
                        );

                        if (token != null && mounted) {
                          // Join the LiveKit room
                          _joinCall(
                            context: context,
                            roomName: roomName,
                            selectedLanguage: _selectedLanguage,
                            token: token,
                          );
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Failed to get LiveKit token."),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
