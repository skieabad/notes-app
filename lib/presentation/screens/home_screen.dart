import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/firebase_options.dart';
import 'package:notes_app/presentation/screens/login_screen.dart';
import 'package:notes_app/presentation/screens/notes_screen.dart';

// extension for logging
import 'dart:developer' as devtools show log;

import 'package:notes_app/presentation/screens/verify_email_screen.dart';

// to show log
extension Log on Object {
  void log() => devtools.log(toString());
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                // Syntax to get the current user in firebase
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  if (user.emailVerified) {
                    print('Email is verified');
                    return const NotesScreen();
                  } else {
                    return const VerifyEmailScreen();
                  }
                } else {
                  return const LoginScreen();
                }
              default:
                return const Center(
                  child: CircularProgressIndicator(),
                );
            }
          },
        ),
      ),
    );
  }
}
