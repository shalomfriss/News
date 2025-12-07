import 'dart:async';

import 'package:authentication_client/authentication_client.dart';
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

  @override
  Future<void> logInWithGoogle() async {
    try {
      await _client!.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.demo.news.dev://login-callback/',
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithOAuthFailure(error), stackTrace);
    }
  }

  @override
  Future<void> logInWithApple() async {
    try {
      await _client!.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'com.demo.news.dev://login-callback/',
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithOAuthFailure(error), stackTrace);
    }
  }

  @override
  Future<void> logInWithFacebook() async {
    try {
      await _client!.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: 'com.demo.news.dev://login-callback/',
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithOAuthFailure(error), stackTrace);
    }
  }

  @override
  Future<void> logInWithTwitter() async {
    try {
      await _client!.auth.signInWithOAuth(
        OAuthProvider.twitter,
        redirectTo: 'com.demo.news.dev://login-callback/',
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithOAuthFailure(error), stackTrace);
    }
  }

  @override
  Future<void> logInWithTikTok() async {
    // TikTok is not directly supported by Supabase OAuth providers.
    // To enable TikTok login, you need to:
    // 1. Set up a custom OAuth flow using TikTok's API
    // 2. Create a Supabase Edge Function to handle the OAuth callback
    // 3. Use the edge function to exchange the TikTok code for user data
    // For now, this throws an error indicating the feature is not yet implemented.
    throw LogInWithOAuthFailure(
      UnsupportedError(
        'TikTok OAuth is not yet supported. Please configure a custom OAuth flow in Supabase.',
      ),
    );
  }

  @override
  Future<void> logInWithInstagram() async {
    try {
      // Instagram OAuth - uses Facebook OAuth (Instagram is owned by Meta)
      // Note: You need to configure Facebook OAuth in Supabase with Instagram permissions
      // This provides user authentication via Facebook, which can include Instagram access
      await _client!.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: 'com.demo.news.dev://login-callback/',
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithOAuthFailure(error), stackTrace);
    }
  }

  @override
  Future<void> logInWithYouTube() async {
    try {
      // YouTube OAuth - uses Google OAuth (YouTube is owned by Google)
      // Note: This provides user authentication via Google, which includes YouTube access
      // You can request YouTube API scopes separately if needed
      await _client!.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.demo.news.dev://login-callback/',
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithOAuthFailure(error), stackTrace);
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
