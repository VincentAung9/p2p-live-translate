// screens/join_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  // ADD: State variable for the dropdown
  Language _selectedLanguage = Language.en;
  // Navigation logic remains in the UI layer
  void _joinCall({
    required BuildContext context,
    required String callerId,
    required String calleeId,
    required bool selfCaller,
    required Language selectedLanguage,
    dynamic offer,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => CallScreen(
              callerId: callerId,
              calleeId: calleeId,
              selfCaller: selfCaller,
              selectedLanguage: selectedLanguage,
              offer: offer,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(centerTitle: true, title: const Text("P2P Call App")),
      body: SafeArea(
        // Use a BlocBuilder to react to state changes from the JoinCubit
        child: Stack(
          children: [
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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

                    // Your ID TextField
                    TextField(
                      controller: TextEditingController(
                        text: widget.selfCallerId,
                      ),
                      readOnly: true,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: "Your Caller ID",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Remote ID TextField
                    TextField(
                      controller: remoteCallerIdTextEditingController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: "Remote Caller ID",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Invite Button
                    ElevatedButton(
                      child: const Text(
                        "Invite",
                        style: TextStyle(fontSize: 18),
                      ),
                      onPressed: () {
                        _joinCall(
                          context: context,
                          callerId: widget.selfCallerId,
                          calleeId: remoteCallerIdTextEditingController.text,
                          selectedLanguage: _selectedLanguage,
                          selfCaller: true,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Conditionally display the incoming call notification based on the Cubit's state
            BlocSelector<JoinCubit, JoinState, Map<String, dynamic>?>(
              selector: (state) => state.incomingOffer,
              builder: (context, state) {
                return state == null
                    ? const SizedBox()
                    : Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Card(
                        margin: const EdgeInsets.all(12),
                        child: ListTile(
                          title: Text(
                            "Incoming Call from ${state["callerId"]}",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.call_end,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () {
                                  // Tell the Cubit to clear the offer state
                                  context.read<JoinCubit>().rejectCall();
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.call,
                                  color: Colors.greenAccent,
                                ),
                                onPressed: () {
                                  _joinCall(
                                    context: context,
                                    callerId: state["callerId"],
                                    calleeId: widget.selfCallerId,
                                    selfCaller: false,
                                    selectedLanguage: _selectedLanguage,
                                    offer: state["sdpOffer"],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}
