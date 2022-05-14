import 'package:flutter/material.dart';
import 'package:notes_app/presentation/screens/home_screen.dart';
import 'package:notes_app/presentation/screens/login_screen.dart';
import 'package:notes_app/presentation/screens/notes_screen.dart';
import 'package:notes_app/presentation/screens/signup_screen.dart';
import 'package:notes_app/presentation/screens/verify_email_screen.dart';

import 'constants/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Notes App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: homeRoute,
      routes: {
        homeRoute: (context) => const HomeScreen(),
        loginRoute: (context) => const LoginScreen(),
        signUpRoute: (context) => const SignupScreen(),
        notesRoute: (context) => const NotesScreen(),
        verifyEmailRoute: (context) => const VerifyEmailScreen(),
      },
    ),
  );
}
