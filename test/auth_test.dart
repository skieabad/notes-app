import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/services/auth/auth_exceptions.dart';
import 'package:notes_app/services/auth/auth_provider.dart';
import 'package:notes_app/services/auth/auth_user.dart';

void main() {
  group('Mock Authentication', () {
    // create an instance of MockAuthProvider
    final mockProvider = MockAuthProvider();

    test('Should not be initialized to begin with', () {
      expect(mockProvider.isInitialized, false);
    });

    test('Cannot logout if not initialized', () {
      expect(
        mockProvider.logoutUser(),
        // match to the logic of MockAuthProvider
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
      // if the initialize is greater than 2 seconds, this test will fail
      timeout: const Timeout(Duration(seconds: 2)),
    );

    test('Create user should delegate to logIn function', () async {
      final badEmailUser = mockProvider.createUser(
        email: 'test@yahoo.com',
        password: 'anypassword',
      );

      // match to the logic of the MockAuthProvider
      expect(badEmailUser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>()));

      final badPasswordUser = mockProvider.createUser(
        email: 'testonly@yahoo.com',
        password: 'test123',
      );

      // match to the logic of the MockAuthProvider
      expect(badPasswordUser,
          throwsA(const TypeMatcher<WrongPasswordAuthException>()));

      final user = await mockProvider.createUser(
        email: 'test',
        password: 'only',
      );

      // get the current user
      expect(mockProvider.currentUser, user);
      // check if the user is verified or not
      expect(user.isEmailVerified, false);

      // Note: Create user function delegate to the login function
    });

    test('Login user should be able to verified', () {
      mockProvider.sendEmailVerification();
      // initialize the currentuser
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
    const user = AuthUser(email: 'test@yahoo.com', isEmailVerified: false);
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
    const newUser = AuthUser(email: 'test@yahoo.com', isEmailVerified: true);
    _user = newUser;
  }
}
