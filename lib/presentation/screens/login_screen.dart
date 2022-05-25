import 'package:flutter/material.dart';
import 'package:notes_app/base/stateful_widget_base.dart';
import 'package:notes_app/constants/routes.dart';
import 'package:notes_app/presentation/global_widgets/global_sizedbox.dart';
import 'package:notes_app/presentation/global_widgets/global_validator.dart';
import 'package:notes_app/services/auth/auth_exceptions.dart';
import 'package:notes_app/services/auth/auth_service.dart';
import 'package:notes_app/utilities/dialogs/error_dialog.dart';
import '../global_widgets/global_textfield.dart';

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
                    keyboardType: TextInputType.emailAddress,
                  ),
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
                              if (_formKey.currentState!.validate()) {
                                setState(() => _isLoading = true);
                                try {
                                  await AuthService.firebase().loginUser(
                                      email: email, password: password);
                                  final user =
                                      AuthService.firebase().currentUser;

                                  if (user?.isEmailVerified ?? false) {
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                            homeRoute, (route) => false);
                                  } else {
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                            verifyEmailRoute, (route) => false);
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
                            signUpRoute, (Route<dynamic> route) => false),
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
