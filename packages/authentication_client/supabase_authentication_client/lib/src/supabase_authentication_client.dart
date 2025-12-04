import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:authentication_client/authentication_client.dart';
import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:token_storage/token_storage.dart';

/// {@template supabase_authentication_client}
/// A Supabase implementation of the [AuthenticationClient] interface.
/// {@endtemplate}
class SupabaseAuthenticationClient implements AuthenticationClient {
  /// {@macro supabase_authentication_client}
  SupabaseAuthenticationClient({
    required TokenStorage tokenStorage,
    required String supabaseUrl,
    required String supabaseAnonKey,
  })  : _tokenStorage = tokenStorage,
        _supabaseUrl = supabaseUrl,
        _supabaseAnonKey = supabaseAnonKey {
    _initialize();
  }

  final TokenStorage _tokenStorage;
  final String _supabaseUrl;
  final String _supabaseAnonKey;

  SupabaseClient? _client;

  final StreamController<AuthenticationUser> _userController =
      StreamController<AuthenticationUser>.broadcast();

  StreamSubscription<AuthState>? _authSubscription;

  /// Initialize the Supabase client and start monitoring auth state
  Future<void> _initialize() async {
    try {
      await Supabase.initialize(
        url: _supabaseUrl,
        anonKey: _supabaseAnonKey,
      );
      _client = Supabase.instance.client;

      // Listen to auth state changes
      _authSubscription = _client!.auth.onAuthStateChange.listen(
        (data) {
          final user = data.session?.user;
          if (user != null) {
            _userController.add(_mapSupabaseUserToAuthUser(user));
            _tokenStorage.saveToken(user.id);
          } else {
            _userController.add(AuthenticationUser.anonymous);
            _tokenStorage.clearToken();
          }
        },
      );

      // Emit initial auth state
      final currentUser = _client!.auth.currentUser;
      if (currentUser != null) {
        _userController.add(_mapSupabaseUserToAuthUser(currentUser));
        await _tokenStorage.saveToken(currentUser.id);
      } else {
        _userController.add(AuthenticationUser.anonymous);
      }
    } catch (e) {
      _userController.add(AuthenticationUser.anonymous);
    }
  }

  @override
  Stream<AuthenticationUser> get user => _userController.stream;

  @override
  Future<void> logInWithApple() async {
    try {
      // Generate a random nonce for security
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256ofString(rawNonce);

      // Request Apple Sign In credentials with the hashed nonce
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      // Get the identity token from Apple
      final idToken = credential.identityToken;
      if (idToken == null) {
        throw LogInWithAppleFailure(
          Exception('Apple Sign In failed: No identity token received'),
        );
      }

      // Sign in to Supabase with the Apple credentials
      await _client!.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );
    } catch (error, stackTrace) {
      if (error is SignInWithAppleAuthorizationException) {
        // User canceled the sign in
        if (error.code == AuthorizationErrorCode.canceled) {
          Error.throwWithStackTrace(
            LogInWithAppleCanceled(error),
            stackTrace,
          );
        }
      }
      Error.throwWithStackTrace(LogInWithAppleFailure(error), stackTrace);
    }
  }

  /// Generates a cryptographically secure random nonce.
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future<void> logInWithGoogle() async {
    try {
      // Use Supabase's built-in OAuth flow
      // This launches a browser for authentication
      final response = await _client!.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutterdemo://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (!response) {
        throw LogInWithGoogleCanceled(
          Exception('Google Sign In was canceled by user'),
        );
      }
    } on LogInWithGoogleCanceled {
      rethrow;
    } catch (error, stackTrace) {
      // Check if it's a cancellation error
      if (error.toString().contains('cancel') ||
          error.toString().contains('Cancel')) {
        Error.throwWithStackTrace(
          LogInWithGoogleCanceled(error),
          stackTrace,
        );
      }
      Error.throwWithStackTrace(LogInWithGoogleFailure(error), stackTrace);
    }
  }

  @override
  Future<void> logInWithFacebook() async {
    try {
      // Use Supabase's built-in OAuth flow
      // This launches a browser for authentication
      final response = await _client!.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: 'io.supabase.flutterdemo://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (!response) {
        throw LogInWithFacebookCanceled(
          Exception('Facebook login was canceled by user'),
        );
      }
    } on LogInWithFacebookCanceled {
      rethrow;
    } catch (error, stackTrace) {
      // Check if it's a cancellation error
      if (error.toString().contains('cancel') ||
          error.toString().contains('Cancel')) {
        Error.throwWithStackTrace(
          LogInWithFacebookCanceled(error),
          stackTrace,
        );
      }
      Error.throwWithStackTrace(LogInWithFacebookFailure(error), stackTrace);
    }
  }

  @override
  Future<void> logInWithTwitter() async {
    try {
      // Use Supabase's built-in OAuth flow
      // This launches a browser for authentication
      final response = await _client!.auth.signInWithOAuth(
        OAuthProvider.twitter,
        redirectTo: 'io.supabase.flutterdemo://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (!response) {
        throw LogInWithTwitterCanceled(
          Exception('Twitter login was canceled by user'),
        );
      }
    } on LogInWithTwitterCanceled {
      rethrow;
    } catch (error, stackTrace) {
      // Check if it's a cancellation error
      if (error.toString().contains('cancel') ||
          error.toString().contains('Cancel')) {
        Error.throwWithStackTrace(
          LogInWithTwitterCanceled(error),
          stackTrace,
        );
      }
      Error.throwWithStackTrace(LogInWithTwitterFailure(error), stackTrace);
    }
  }

  /// Signs in with email and password.
  Future<void> logInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _client!.auth.signInWithPassword(
        email: email,
        password: password,
      );
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
      final response = await _client!.auth.signUp(
        email: email,
        password: password,
        data: name != null ? {'name': name} : null,
      );

      if (response.user == null) {
        throw Exception('Sign up failed: No user returned');
      }

      // User is automatically logged in after sign up in Supabase
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithEmailLinkFailure(error), stackTrace);
    }
  }

  /// Sends a password recovery email to the provided [email].
  ///
  /// The user will receive an email with a link to reset their password.
  Future<void> sendPasswordRecoveryEmail({
    required String email,
  }) async {
    try {
      await _client!.auth.resetPasswordForEmail(email);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(SendLoginEmailLinkFailure(error), stackTrace);
    }
  }

  /// Updates the user's password.
  ///
  /// This should be called after the user clicks the link in the recovery email.
  /// The user must be logged in to update their password.
  Future<void> updatePassword({
    required String newPassword,
  }) async {
    try {
      await _client!.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithEmailLinkFailure(error), stackTrace);
    }
  }

  @override
  Future<void> sendLoginEmailLink({
    required String email,
    required String appPackageName,
  }) async {
    try {
      // Supabase uses magic links (OTP) for passwordless authentication
      await _client!.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'com.$appPackageName://login-callback/',
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(SendLoginEmailLinkFailure(error), stackTrace);
    }
  }

  @override
  bool isLogInWithEmailLink({required String emailLink}) {
    try {
      final uri = Uri.parse(emailLink);
      // Check if the link contains OTP token parameters
      return uri.queryParameters.containsKey('token') ||
          uri.queryParameters.containsKey('type');
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
      final token = uri.queryParameters['token'];

      if (token == null) {
        throw Exception('Invalid magic link: missing token');
      }

      await _client!.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.magiclink,
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithEmailLinkFailure(error), stackTrace);
    }
  }

  @override
  Future<void> logOut() async {
    try {
      await _client!.auth.signOut();
      _userController.add(AuthenticationUser.anonymous);
      await _tokenStorage.clearToken();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogOutFailure(error), stackTrace);
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      // Note: Supabase doesn't provide a client-side account deletion method
      // for security reasons. You'll need to implement this via:
      // 1. A Supabase Edge Function
      // 2. A backend API endpoint that calls the Supabase Admin API
      //
      // For now, we'll sign out the user. To implement full account deletion,
      // create a Supabase Edge Function that uses the Admin API:
      //
      // const { createClient } = require('@supabase/supabase-js')
      // const supabaseAdmin = createClient(url, serviceRoleKey)
      // await supabaseAdmin.auth.admin.deleteUser(userId)
      //
      // Then call it here using the Supabase Functions client

      await _client!.auth.signOut();
      _userController.add(AuthenticationUser.anonymous);
      await _tokenStorage.clearToken();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(DeleteAccountFailure(error), stackTrace);
    }
  }

  /// Maps a Supabase user to an AuthenticationUser
  AuthenticationUser _mapSupabaseUserToAuthUser(User supabaseUser) {
    return AuthenticationUser(
      id: supabaseUser.id,
      email: supabaseUser.email,
      name: supabaseUser.userMetadata?['name'] as String?,
      photo: supabaseUser.userMetadata?['avatar_url'] as String?,
      isNewUser: false,
    );
  }

  /// Dispose resources
  void dispose() {
    _authSubscription?.cancel();
    _userController.close();
  }
}
