import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/firebase_options.dart';
import 'package:notes_app/presentation/global_widgets/global_sizedbox.dart';
import 'package:notes_app/presentation/global_widgets/global_snackbar.dart';
import 'package:notes_app/presentation/global_widgets/global_validator.dart';
import '../global_widgets/global_textfield.dart';

// extension for logging
import 'dart:developer' as devtools show log;

// to show log
extension Log on Object {
  void log() => devtools.log(toString());
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            return Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  globalTextFields(
                    _emailController,
                    emailValidator,
                    'Enter your email',
                    IconButton(
                      onPressed: () => _emailController.clear(),
                      icon: const Icon(Icons.close),
                    ),
                    false,
                    TextInputType.emailAddress,
                  ),
                  globalTextFields(
                    _passwordController,
                    passwordValidator,
                    'Enter your password',
                    IconButton(
                      onPressed: () => setState(() {
                        _showPassword = !_showPassword;
                      }),
                      icon: Icon(
                        _showPassword
                            ? (Icons.visibility_off)
                            : (Icons.visibility),
                      ),
                    ),
                    _showPassword,
                  ),
                  globalSizedBox(10),
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);
                              try {
                                final email = _emailController.text;
                                final password = _passwordController.text;
                                final userCredential = await FirebaseAuth
                                    .instance
                                    .signInWithEmailAndPassword(
                                        email: email, password: password);
                                userCredential.log();
                              } on FirebaseAuthException catch (e) {
                                switch (e.code) {
                                  case 'wrong-password':
                                    {
                                      globalSnackBar('Wrong password', context);
                                      setState(() => _isLoading = false);
                                    }
                                    break;
                                  case 'user-not-found':
                                    {
                                      globalSnackBar('User not found', context);
                                      setState(() => _isLoading = false);
                                    }
                                    break;
                                  default:
                                    {
                                      e.code.log();
                                    }
                                }
                              }
                            }
                          },
                          child: const Text('Login'),
                        ),
                  globalSizedBox(2),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/signupscreen'),
                    child: const Text("Don't have an account? Sign up"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
