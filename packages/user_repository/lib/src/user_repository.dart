import 'dart:async';

import 'package:authentication_client/authentication_client.dart';
import 'package:deep_link_client/deep_link_client.dart';
import 'package:equatable/equatable.dart';
import 'package:demo_news_api/client.dart' hide User;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_client/package_info_client.dart';
import 'package:rxdart/rxdart.dart';
import 'package:storage/storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:user_repository/user_repository.dart';

part 'user_storage.dart';

/// {@template user_failure}
/// A base failure for the user repository failures.
/// {@endtemplate}
abstract class UserFailure with EquatableMixin implements Exception {
  /// {@macro user_failure}
  const UserFailure(this.error);

  /// The error which was caught.
  final Object error;

  @override
  List<Object> get props => [error];
}

/// {@template fetch_app_opened_count_failure}
/// Thrown when fetching app opened count fails.
/// {@endtemplate}
class FetchAppOpenedCountFailure extends UserFailure {
  /// {@macro fetch_app_opened_count_failure}
  const FetchAppOpenedCountFailure(super.error);
}

/// {@template increment_app_opened_count_failure}
/// Thrown when incrementing app opened count fails.
/// {@endtemplate}
class IncrementAppOpenedCountFailure extends UserFailure {
  /// {@macro increment_app_opened_count_failure}
  const IncrementAppOpenedCountFailure(super.error);
}

/// {@template fetch_current_subscription_failure}
/// An exception thrown when fetching current subscription fails.
/// {@endtemplate}
class FetchCurrentSubscriptionFailure extends UserFailure {
  /// {@macro fetch_current_subscription_failure}
  const FetchCurrentSubscriptionFailure(super.error);
}

/// {@template user_repository}
/// Repository which manages the user domain.
/// {@endtemplate}
class UserRepository {
  /// {@macro user_repository}
  UserRepository({
    required DemoNewsApiClient apiClient,
    required AuthenticationClient authenticationClient,
    required PackageInfoClient packageInfoClient,
    required DeepLinkService deepLinkService,
    required UserStorage storage,
  })  : _apiClient = apiClient,
        _authenticationClient = authenticationClient,
        _packageInfoClient = packageInfoClient,
        _deepLinkService = deepLinkService,
        _storage = storage;

  final DemoNewsApiClient _apiClient;
  final AuthenticationClient _authenticationClient;
  final PackageInfoClient _packageInfoClient;
  final DeepLinkService _deepLinkService;
  final UserStorage _storage;

  /// Stream of [User] which will emit the current user when
  /// the authentication state or the subscription plan changes.
  ///
  Stream<User> get user =>
      Rx.combineLatest2<AuthenticationUser, SubscriptionPlan, User>(
        _authenticationClient.user,
        _currentSubscriptionPlanSubject.stream,
        (authenticationUser, subscriptionPlan) => User.fromAuthenticationUser(
          authenticationUser: authenticationUser,
          subscriptionPlan: authenticationUser != AuthenticationUser.anonymous
              ? subscriptionPlan
              : SubscriptionPlan.none,
        ),
      ).asBroadcastStream();

  final BehaviorSubject<SubscriptionPlan> _currentSubscriptionPlanSubject =
      BehaviorSubject.seeded(SubscriptionPlan.none);

  /// A stream of incoming email links used to authenticate the user.
  ///
  /// Emits when a new email link is emitted on [DeepLinkClient.deepLinkStream],
  /// which is validated using [AuthenticationClient.isLogInWithEmailLink].
  Stream<Uri> get incomingEmailLinks => _deepLinkService.deepLinkStream.where(
        (deepLink) => _authenticationClient.isLogInWithEmailLink(
          emailLink: deepLink.toString(),
        ),
      );

  /// Sends an authentication link to the provided [email].
  ///
  /// Throws a [SendLoginEmailLinkFailure] if an exception occurs.
  Future<void> sendLoginEmailLink({
    required String email,
  }) async {
    try {
      await _authenticationClient.sendLoginEmailLink(
        email: email,
        appPackageName: _packageInfoClient.packageName,
      );
    } on SendLoginEmailLinkFailure {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(SendLoginEmailLinkFailure(error), stackTrace);
    }
  }

  /// Signs in with the provided [email] and [emailLink].
  ///
  /// Throws a [LogInWithEmailLinkFailure] if an exception occurs.
  Future<void> logInWithEmailLink({
    required String email,
    required String emailLink,
  }) async {
    try {
      await _authenticationClient.logInWithEmailLink(
        email: email,
        emailLink: emailLink,
      );
    } on LogInWithEmailLinkFailure {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithEmailLinkFailure(error), stackTrace);
    }
  }

  /// Signs in with the provided [email] and [password].
  ///
  /// This method is specific to authentication clients that support
  /// email/password authentication (e.g., Appwrite).
  ///
  /// Throws a [LogInWithEmailLinkFailure] if an exception occurs.
  Future<void> logInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Use dynamic invocation to call Appwrite-specific method
      // This allows the method to work with AppwriteAuthenticationClient
      // without creating a direct dependency
      final authClient = _authenticationClient as dynamic;
      await authClient.logInWithEmailPassword(
        email: email,
        password: password,
      );
    } on LogInWithEmailLinkFailure {
      rethrow;
    } on NoSuchMethodError catch (error, stackTrace) {
      Error.throwWithStackTrace(
        LogInWithEmailLinkFailure(
          UnsupportedError(
            'Email/password login is not supported by the current authentication client',
          ),
        ),
        stackTrace,
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithEmailLinkFailure(error), stackTrace);
    }
  }

  /// Creates a new account with the provided [email], [password], and optional [name].
  ///
  /// This method is specific to authentication clients that support
  /// email/password authentication (e.g., Appwrite).
  ///
  /// Throws a [LogInWithEmailLinkFailure] if an exception occurs.
  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      // Use dynamic invocation to call Appwrite-specific method
      // This allows the method to work with AppwriteAuthenticationClient
      // without creating a direct dependency
      final authClient = _authenticationClient as dynamic;
      await authClient.signUpWithEmailPassword(
        email: email,
        password: password,
        name: name,
      );
    } on LogInWithEmailLinkFailure {
      rethrow;
    } on NoSuchMethodError catch (error, stackTrace) {
      Error.throwWithStackTrace(
        LogInWithEmailLinkFailure(
          UnsupportedError(
            'Email/password signup is not supported by the current authentication client',
          ),
        ),
        stackTrace,
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithEmailLinkFailure(error), stackTrace);
    }
  }

  /// Sends a password recovery email to the provided [email].
  ///
  /// This method is specific to authentication clients that support
  /// password recovery (e.g., Appwrite, Supabase).
  ///
  /// Throws a [SendLoginEmailLinkFailure] if an exception occurs.
  Future<void> sendPasswordRecoveryEmail({
    required String email,
  }) async {
    try {
      // Use dynamic invocation to call provider-specific method
      final authClient = _authenticationClient as dynamic;

      // Try calling with just email first (Supabase)
      try {
        await authClient.sendPasswordRecoveryEmail(email: email);
      } on NoSuchMethodError {
        // If that fails, try with url parameter (Appwrite)
        const recoveryUrl = 'https://your-app.com/password-reset';
        await authClient.sendPasswordRecoveryEmail(
          email: email,
          url: recoveryUrl,
        );
      }
    } on SendLoginEmailLinkFailure {
      rethrow;
    } on NoSuchMethodError catch (error, stackTrace) {
      Error.throwWithStackTrace(
        SendLoginEmailLinkFailure(
          UnsupportedError(
            'Password recovery is not supported by the current authentication client',
          ),
        ),
        stackTrace,
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(SendLoginEmailLinkFailure(error), stackTrace);
    }
  }

  /// Signs in with Google OAuth.
  ///
  /// Throws a [LogInWithOAuthFailure] if an exception occurs.
  Future<AuthResponse> logInWithGoogle() async {
    try {
      // await _authenticationClient.logInWithGoogle();

      var supabase = Supabase.instance.client;
      const webClientId = '335500197632-vkd7ebfp1q0hflautd2pi8iub7cj15sl.apps.googleusercontent.com';
      const iosClientId = '335500197632-85boqmogkjqjv6ua6h23b7he64g2qe1b.apps.googleusercontent.com';

      // Google sign in on Android will work without providing the Android
      // Client ID registered on Google Cloud.

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: iosClientId,
        serverClientId: webClientId,
      );
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      return await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

    } on LogInWithOAuthFailure {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithOAuthFailure(error), stackTrace);
    }
  }

  /// Signs in with Apple OAuth.
  ///
  /// Throws a [LogInWithOAuthFailure] if an exception occurs.
  Future<void> logInWithApple() async {
    try {
      await _authenticationClient.logInWithApple();
    } on LogInWithOAuthFailure {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithOAuthFailure(error), stackTrace);
    }
  }

  /// Signs in with Facebook OAuth.
  ///
  /// Throws a [LogInWithOAuthFailure] if an exception occurs.
  Future<void> logInWithFacebook() async {
    try {
      await _authenticationClient.logInWithFacebook();
    } on LogInWithOAuthFailure {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithOAuthFailure(error), stackTrace);
    }
  }

  /// Signs in with Twitter OAuth.
  ///
  /// Throws a [LogInWithOAuthFailure] if an exception occurs.
  Future<void> logInWithTwitter() async {
    try {
      await _authenticationClient.logInWithTwitter();
    } on LogInWithOAuthFailure {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithOAuthFailure(error), stackTrace);
    }
  }

  /// Signs in with TikTok OAuth.
  ///
  /// Throws a [LogInWithOAuthFailure] if an exception occurs.
  Future<void> logInWithTikTok() async {
    try {
      await _authenticationClient.logInWithTikTok();
    } on LogInWithOAuthFailure {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithOAuthFailure(error), stackTrace);
    }
  }

  /// Signs in with Instagram OAuth.
  ///
  /// Throws a [LogInWithOAuthFailure] if an exception occurs.
  Future<void> logInWithInstagram() async {
    try {
      await _authenticationClient.logInWithInstagram();
    } on LogInWithOAuthFailure {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithOAuthFailure(error), stackTrace);
    }
  }

  /// Signs in with YouTube OAuth.
  ///
  /// Throws a [LogInWithOAuthFailure] if an exception occurs.
  Future<void> logInWithYouTube() async {
    try {
      await _authenticationClient.logInWithYouTube();
    } on LogInWithOAuthFailure {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithOAuthFailure(error), stackTrace);
    }
  }

  /// Signs out the current user which will emit
  /// [User.anonymous] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> logOut() async {
    try {
      await _authenticationClient.logOut();
    } on LogOutFailure {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogOutFailure(error), stackTrace);
    }
  }

  /// Deletes the current user account.
  Future<void> deleteAccount() async {
    try {
      await _authenticationClient.deleteAccount();
    } on DeleteAccountFailure {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(DeleteAccountFailure(error), stackTrace);
    }
  }

  /// Returns the number of times the app was opened.
  Future<int> fetchAppOpenedCount() async {
    try {
      return await _storage.fetchAppOpenedCount();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        FetchAppOpenedCountFailure(error),
        stackTrace,
      );
    }
  }

  /// Increments the number of times the app was opened by 1.
  Future<void> incrementAppOpenedCount() async {
    try {
      final value = await fetchAppOpenedCount();
      final result = value + 1;
      await _storage.setAppOpenedCount(count: result);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        IncrementAppOpenedCountFailure(error),
        stackTrace,
      );
    }
  }

  /// Updates the current subscription plan of the user.
  Future<void> updateSubscriptionPlan() async {
    try {
      final response = await _apiClient.getCurrentUser();
      _currentSubscriptionPlanSubject.add(response.user.subscription);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        FetchCurrentSubscriptionFailure(error),
        stackTrace,
      );
    }
  }
}
