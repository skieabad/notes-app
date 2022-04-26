import 'package:notes_app/services/auth/auth_user.dart';
import 'package:notes_app/services/auth/auth_provider.dart';
import 'package:notes_app/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider authProvider;
  const AuthService(this.authProvider);

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) =>
      authProvider.createUser(
        email: email,
        password: password,
      );

  @override
  AuthUser? get currentUser => authProvider.currentUser;

  @override
  Future<AuthUser> loginUser({
    required String email,
    required String password,
  }) =>
      authProvider.loginUser(email: email, password: password);

  @override
  Future<void> logoutUser() => authProvider.logoutUser();

  @override
  Future<void> sendEmailVerification() => authProvider.sendEmailVerification();

  // Delegate the authprovider
  @override
  Future<void> initialize() => authProvider.initialize();
}
