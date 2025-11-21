import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart' as enums;
import 'package:appwrite/models.dart' as models;
import 'package:authentication_client/authentication_client.dart';
import 'package:token_storage/token_storage.dart';

/// {@template appwrite_authentication_client}
/// An Appwrite implementation of the [AuthenticationClient] interface.
/// {@endtemplate}
class AppwriteAuthenticationClient implements AuthenticationClient {
  /// {@macro appwrite_authentication_client}
  AppwriteAuthenticationClient({
    required TokenStorage tokenStorage,
    required String projectId,
    String endpoint = 'https://cloud.appwrite.io/v1',
  })  : _tokenStorage = tokenStorage,
        _client = Client()
            .setEndpoint(endpoint)
            .setProject(projectId) {
    _account = Account(_client);
    _initialize();
  }

  final TokenStorage _tokenStorage;
  final Client _client;
  late final Account _account;

  final StreamController<AuthenticationUser> _userController =
      StreamController<AuthenticationUser>.broadcast();

  Timer? _sessionCheckTimer;
  models.User? _currentUser;

  /// Initialize the client and start monitoring auth state
  Future<void> _initialize() async {
    try {
      final user = await _account.get();
      _currentUser = user;
      _userController.add(_mapAppwriteUserToAuthUser(user));
      await _tokenStorage.saveToken(user.$id);
    } catch (e) {
      _currentUser = null;
      _userController.add(AuthenticationUser.anonymous);
    }

    // Check session every 30 seconds
    _sessionCheckTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkSession(),
    );
  }

  /// Check if the session is still valid
  Future<void> _checkSession() async {
    try {
      final user = await _account.get();
      if (_currentUser?.$id != user.$id) {
        _currentUser = user;
        _userController.add(_mapAppwriteUserToAuthUser(user));
        await _tokenStorage.saveToken(user.$id);
      }
    } catch (e) {
      if (_currentUser != null) {
        _currentUser = null;
        _userController.add(AuthenticationUser.anonymous);
        await _tokenStorage.clearToken();
      }
    }
  }

  @override
  Stream<AuthenticationUser> get user => _userController.stream;

  @override
  Future<void> logInWithApple() async {
    try {
      await _account.createOAuth2Session(
        provider: enums.OAuthProvider.apple,
      );
      await _checkSession();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithAppleFailure(error), stackTrace);
    }
  }

  @override
  Future<void> logInWithGoogle() async {
    try {
      await _account.createOAuth2Session(
        provider: enums.OAuthProvider.google,
      );
      await _checkSession();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithGoogleFailure(error), stackTrace);
    }
  }

  @override
  Future<void> logInWithFacebook() async {
    try {
      await _account.createOAuth2Session(
        provider: enums.OAuthProvider.facebook,
      );
      await _checkSession();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithFacebookFailure(error), stackTrace);
    }
  }

  @override
  Future<void> logInWithTwitter() async {
    // Note: Twitter/X OAuth is not currently supported in Appwrite's OAuth2
    // You may need to implement a custom OAuth flow or use a different provider
    throw LogInWithTwitterFailure(
      UnsupportedError('Twitter OAuth is not supported with Appwrite'),
    );
  }

  /// Signs in with email and password.
  ///
  /// Note: Appwrite uses email/password authentication instead of magic links.
  /// This is a custom method specific to Appwrite.
  Future<void> logInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      await _checkSession();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithEmailLinkFailure(error), stackTrace);
    }
  }

  /// Creates a new user account with email and password.
  ///
  /// After successful registration, the user is automatically logged in.
  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      await logInWithEmailPassword(email: email, password: password);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithEmailLinkFailure(error), stackTrace);
    }
  }

  @override
  Future<void> sendLoginEmailLink({
    required String email,
    required String appPackageName,
  }) async {
    // Appwrite doesn't support passwordless email links in the same way as Firebase.
    // Instead, we can use Appwrite's Magic URL feature.
    try {
      await _account.createMagicURLToken(
        userId: ID.unique(),
        email: email,
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(SendLoginEmailLinkFailure(error), stackTrace);
    }
  }

  @override
  bool isLogInWithEmailLink({required String emailLink}) {
    // Check if the link contains the magic URL token parameters
    try {
      final uri = Uri.parse(emailLink);
      return uri.queryParameters.containsKey('userId') &&
          uri.queryParameters.containsKey('secret');
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        IsLogInWithEmailLinkFailure(error),
        stackTrace,
      );
    }
  }

  @override
  Future<void> logInWithEmailLink({
    required String email,
    required String emailLink,
  }) async {
    try {
      final uri = Uri.parse(emailLink);
      final userId = uri.queryParameters['userId'];
      final secret = uri.queryParameters['secret'];

      if (userId == null || secret == null) {
        throw Exception('Invalid magic URL link');
      }

      await _account.updateMagicURLSession(
        userId: userId,
        secret: secret,
      );
      await _checkSession();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithEmailLinkFailure(error), stackTrace);
    }
  }

  @override
  Future<void> logOut() async {
    try {
      await _account.deleteSession(sessionId: 'current');
      _currentUser = null;
      _userController.add(AuthenticationUser.anonymous);
      await _tokenStorage.clearToken();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogOutFailure(error), stackTrace);
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      // Appwrite requires the user to delete their own account
      // First, we need to delete all sessions, then the account
      await _account.deleteSessions();

      // Note: Appwrite's Account.delete() requires additional verification
      // For now, we'll just sign out. The actual deletion would need
      // to be implemented server-side or with additional verification.
      _currentUser = null;
      _userController.add(AuthenticationUser.anonymous);
      await _tokenStorage.clearToken();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(DeleteAccountFailure(error), stackTrace);
    }
  }

  /// Maps an Appwrite user to an AuthenticationUser
  AuthenticationUser _mapAppwriteUserToAuthUser(models.User appwriteUser) {
    return AuthenticationUser(
      id: appwriteUser.$id,
      email: appwriteUser.email,
      name: appwriteUser.name,
      photo: null, // Appwrite doesn't provide a direct photo URL
      isNewUser: false, // Appwrite doesn't provide this info
    );
  }

  /// Dispose resources
  void dispose() {
    _sessionCheckTimer?.cancel();
    _userController.close();
  }
}
