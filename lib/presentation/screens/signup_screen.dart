import 'package:flutter/material.dart';
import 'package:notes_app/constants/routes.dart';
import 'package:notes_app/presentation/global_widgets/global_sizedbox.dart';
import 'package:notes_app/presentation/global_widgets/global_textfield.dart';
import 'package:notes_app/presentation/global_widgets/global_validator.dart';
import 'package:notes_app/services/auth/auth_exceptions.dart';

import 'package:notes_app/services/auth/auth_service.dart';
import 'package:notes_app/utilities/dialogs/error_dialog.dart';

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
          future: AuthService.firebase().initialize(),
          builder: (context, snapshot) {
            return Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  globalTextFields(
                      controller: _emailController,
                      validator: emailValidator,
                      hintText: 'Enter your email',
                      suffixIcon: IconButton(
                        splashRadius: 1.0,
                        onPressed: () => _emailController.clear(),
                        icon: const Icon(Icons.close),
                      ),
                      obscureText: false,
                      keyboardType: TextInputType.emailAddress),
                  globalTextFields(
                    controller: _passwordController,
                    validator: passwordValidator,
                    hintText: 'Enter your password',
                    suffixIcon: IconButton(
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
                    obscureText: _showPassword,
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
                              final email = _emailController.text;
                              final password = _passwordController.text;
                              setState(() {
                                _isLoading = true;
                              });
                              if (_formKey.currentState!.validate()) {
                                try {
                                  await AuthService.firebase().createUser(
                                    email: email,
                                    password: password,
                                  );
                                  AuthService.firebase()
                                      .sendEmailVerification();
                                  Navigator.of(context)
                                      .pushNamed(verifyEmailRoute);
                                } on EmailAlreadyInUseAuthException {
                                  await showErrorDialog(
                                      context, 'Email already in use');
                                  setState(() => _isLoading = false);
                                } on GenericAuthException {
                                  await showErrorDialog(
                                      context, 'Something went wrong');
                                  setState(() => _isLoading = false);
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
