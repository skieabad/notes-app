import 'package:flutter/material.dart';
import 'package:notes_app/presentation/screens/login_screen.dart';
import 'package:notes_app/presentation/screens/signup_screen.dart';

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
        '/signupscreen': (context) => const SignupScreen(),
      },
    ),
  );
}
