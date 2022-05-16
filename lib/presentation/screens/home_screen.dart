import 'package:flutter/material.dart';
import 'package:notes_app/presentation/screens/login_screen.dart';
import 'package:notes_app/presentation/screens/notes/notes_screen.dart';

// extension for logging
import 'dart:developer' as devtools show log;

import 'package:notes_app/presentation/screens/verify_email_screen.dart';
import 'package:notes_app/services/auth/auth_service.dart';

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
          future: AuthService.firebase().initialize(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                // Syntax to get the current user in firebase
                final user = AuthService.firebase().currentUser;
                print(user);
                if (user != null) {
                  if (user.isEmailVerified) {
                    print('Email is verified');
                    return const NotesScreen();
                  } else {
                    print('not verified');
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
