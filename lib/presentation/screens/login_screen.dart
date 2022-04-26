import 'package:flutter/material.dart';
import 'package:notes_app/base/stateful_widget_base.dart';
import 'package:notes_app/constants/routes.dart';
import 'package:notes_app/presentation/global_widgets/global_show_error_dialog.dart';
import 'package:notes_app/presentation/global_widgets/global_sizedbox.dart';
import 'package:notes_app/presentation/global_widgets/global_validator.dart';
import 'package:notes_app/services/auth/auth_exceptions.dart';
import 'package:notes_app/services/auth/auth_service.dart';
import '../global_widgets/global_textfield.dart';

// extension for logging
import 'dart:developer' as devtools show log;

// to show log
extension Log on Object {
  void log() => devtools.log(toString());
}

class LoginScreen extends StatefulWidgetBase {
  const LoginScreen({Key? key, title = 'Login'})
      : super(key: key, title: title);

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
    return MaterialApp(
      title: widget.title!,
      home: Scaffold(
        body: SafeArea(
          child: FutureBuilder(
            future: AuthService.firebase().initialize(),
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
                        splashRadius: 1.0,
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
                        splashRadius: 1.0,
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
                        : SizedBox(
                            width: 150,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => _isLoading = true);
                                  try {
                                    final email = _emailController.text;
                                    final password = _passwordController.text;
                                    final user =
                                        AuthService.firebase().currentUser;
                                    await AuthService.firebase().loginUser(
                                        email: email, password: password);

                                    if (user!.isEmailVerified) {
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil(
                                              homeRoute, (route) => false);
                                    } else {
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil(
                                              verifyEmailRoute,
                                              (route) => false);
                                    }
                                  } on WrongPasswordAuthException {
                                    await showErrorDialog(
                                        context, 'Wrong password');
                                    setState(() => _isLoading = false);
                                  } on UserNotFoundAuthException {
                                    await showErrorDialog(
                                        context, 'User not found');
                                    setState(() => _isLoading = false);
                                  } on GenericAuthException {
                                    await showErrorDialog(
                                        context, 'Authentication error');
                                    setState(() => _isLoading = false);
                                  }
                                }
                              },
                              child: const Text('Login'),
                            ),
                          ),
                    globalSizedBox(2),
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamedAndRemoveUntil(
                              signUpRoute, (route) => false),
                      child: const Text("Don't have an account? Sign up"),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
