import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/constants/routes.dart';
import 'package:notes_app/firebase_options.dart';
import 'package:notes_app/presentation/global_widgets/global_show_error_dialog.dart';
import 'package:notes_app/presentation/global_widgets/global_sizedbox.dart';
import 'package:notes_app/presentation/global_widgets/global_textfield.dart';
import 'package:notes_app/presentation/global_widgets/global_validator.dart';

// extension for logging
import 'dart:developer' as devtools show log;

// to show log
extension Log on Object {
  void log() => devtools.log(toString());
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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
                      TextInputType.emailAddress),
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
                    true,
                  ),
                  globalSizedBox(10),
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                              });
                              if (_formKey.currentState!.validate()) {
                                try {
                                  final email = _emailController.text;
                                  final password = _passwordController.text;
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  await FirebaseAuth.instance
                                      .createUserWithEmailAndPassword(
                                          email: email, password: password);
                                  await user!.sendEmailVerification();
                                  Navigator.of(context)
                                      .pushNamed(verifyEmailRoute);
                                } on FirebaseAuthException catch (e) {
                                  // email-already-in-use
                                  if (e.code == 'email-already-in-use') {
                                    await showErrorDialog(
                                        context, 'Email already in use');
                                    setState(() => _isLoading = false);
                                  }
                                }
                              }
                            },
                            child: const Text('Register'),
                          ),
                        ),
                  globalSizedBox(2),
                  TextButton(
                    onPressed: () => Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (route) => false),
                    child: const Text('Already have an account? Login'),
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
