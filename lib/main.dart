import 'package:flutter/material.dart';
import 'package:notes_app/presentation/screens/home_screen.dart';
import 'package:notes_app/presentation/screens/login_screen.dart';
import 'package:notes_app/presentation/screens/notes_screen.dart';
import 'package:notes_app/presentation/screens/signup_screen.dart';

import 'constants/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Notes App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
      routes: {
        loginRoute: (context) => const LoginScreen(),
        signUpRoute: (context) => const SignupScreen(),
        homeRoute: (context) => const HomeScreen(),
        notesRoute: (context) => const NotesScreen(),
      },
    ),
  );
}
