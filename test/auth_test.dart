import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/services/auth/auth_exceptions.dart';
import 'package:notes_app/services/auth/auth_provider.dart';
import 'package:notes_app/services/auth/auth_user.dart';

void main() {
  group('Mock Authentication', () {
    // create an instance of mockauthprovider
    final mockProvider = MockAuthProvider();

    test('Should not be initialized to begin with', () {
      expect(mockProvider.isInitialized, false);
    });

    test('Cannot logout if not initialized', () {
      expect(
        mockProvider.logoutUser(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test('Should be able to initialized', () async {
      await mockProvider.initialize();
      expect(mockProvider.isInitialized, true);
    });

    test('User should be null after initialization', () {
      expect(mockProvider.currentUser, null);
    });

    test(
      'Should be able to initialize in less than 2 seconds',
      () async {
        await mockProvider.initialize();
        expect(mockProvider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

    test('Create user should delegate to logIn function', () async {
      final badEmailUser = mockProvider.createUser(
        email: 'test@yahoo.com',
        password: 'anypassword',
      );

      expect(badEmailUser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>()));

      final badPasswordUser = mockProvider.createUser(
        email: 'testonly@yahoo.com',
        password: 'test123',
      );

      expect(badPasswordUser,
          throwsA(const TypeMatcher<WrongPasswordAuthException>()));

      final user = await mockProvider.createUser(
        email: 'test',
        password: 'only',
      );

      expect(mockProvider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test('Login user should be able to verified', () {
      mockProvider.sendEmailVerification();
      final user = mockProvider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Should be able to logout and login again', () async {
      await mockProvider.logoutUser();
      await mockProvider.loginUser(email: 'email', password: 'password');
      final user = mockProvider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;

  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return loginUser(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> loginUser({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'test@yahoo.com') throw UserNotFoundAuthException();
    if (password == 'test123') throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logoutUser() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
  }
}
