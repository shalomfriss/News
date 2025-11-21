# Appwrite Authentication Integration

This document describes the integration of Appwrite authentication into the demo_news application.

## Overview

The Appwrite authentication flow has been successfully linked to the email login flow. The application now supports email/password authentication via Appwrite alongside the existing Firebase magic link authentication.

## What Was Implemented

### 1. AppwriteAuthenticationClient Package

Created a new authentication client package at `packages/authentication_client/appwrite_authentication_client/` that implements the `AuthenticationClient` interface.

**Key Features:**
- Email/password authentication (login and signup)
- OAuth2 support for Google, Apple, and Facebook
- Magic URL support (Appwrite's passwordless authentication)
- Session management with automatic state monitoring
- Token storage integration

**Files Created:**
- `packages/authentication_client/appwrite_authentication_client/lib/src/appwrite_authentication_client.dart`
- `packages/authentication_client/appwrite_authentication_client/lib/appwrite_authentication_client.dart`
- `packages/authentication_client/appwrite_authentication_client/pubspec.yaml`

### 2. Email/Password Login UI

Created a new login page for email/password authentication.

**File Created:**
- `lib/login/view/login_with_email_password_page.dart`

**Features:**
- Email input field
- Password input field with show/hide toggle
- Form validation
- Loading states
- Error handling

### 3. LoginBloc Enhancement

Added support for email/password authentication to the existing LoginBloc.

**Changes:**
- Added `LoginEmailPasswordSubmitted` event in `lib/login/bloc/login_event.dart`
- Added handler for email/password login in `lib/login/bloc/login_bloc.dart`

### 4. UserRepository Updates

Extended UserRepository to support email/password authentication methods.

**Changes in `packages/user_repository/lib/src/user_repository.dart`:**
- Added `logInWithEmailPassword()` method
- Added `signUpWithEmailPassword()` method
- Uses dynamic type checking to support Appwrite-specific functionality

### 5. Main Application Configuration

Updated the main application to use AppwriteAuthenticationClient.

**Changes in `lib/main/main_development.dart`:**
- Replaced `FirebaseAuthenticationClient` with `AppwriteAuthenticationClient`
- Configured Appwrite endpoint and project ID

### 6. Login Form Update

Added a new button to access the email/password login page.

**Changes in `lib/login/widgets/login_form.dart`:**
- Added "Sign in with Email & Password" button
- Button navigates to `LoginWithEmailPasswordPage`

## Configuration

### Appwrite Settings

The application is configured to use Appwrite Cloud with the following settings:

```dart
projectId: '6911690b003198add805'
endpoint: 'https://sfo.cloud.appwrite.io/v1'
```

## How It Works

### Email/Password Login Flow

1. User clicks "Sign in with Email & Password" on the login modal
2. User enters email and password on the login page
3. `LoginBloc` dispatches `LoginEmailPasswordSubmitted` event
4. `UserRepository.logInWithEmailPassword()` is called
5. `AppwriteAuthenticationClient.logInWithEmailPassword()` creates a session with Appwrite
6. Session is validated and user state is updated
7. User is redirected to the home page

### OAuth Login Flow

1. User clicks social login button (Google, Apple, Facebook)
2. `AppwriteAuthenticationClient` creates an OAuth2 session
3. User is redirected to the provider's authentication page
4. After successful authentication, user is redirected back to the app
5. Session is validated and user state is updated

### Session Management

The `AppwriteAuthenticationClient` monitors authentication state by:
- Checking the current session on initialization
- Polling the session every 30 seconds
- Emitting user state changes via a stream
- Storing authentication tokens via `TokenStorage`

## Limitations

- Twitter/X OAuth is not currently supported in this Appwrite integration
- Appwrite OAuth requires proper redirect URL configuration in the Appwrite console
- The session polling interval is fixed at 30 seconds

## Testing

To test the integration:

1. Run the app: `flutter run`
2. Click "Sign in with Email & Password" button
3. Create a new account or sign in with existing credentials
4. Verify successful authentication and navigation to home page

## Next Steps

To fully utilize this integration:

1. Configure OAuth providers in the Appwrite console
2. Set up proper redirect URLs for your app
3. Test with real Appwrite backend
4. Consider implementing account recovery flows
5. Add two-factor authentication support

## Architecture Benefits

This implementation follows clean architecture principles:

- **Abstraction**: Uses the `AuthenticationClient` interface
- **Separation of Concerns**: Authentication logic is isolated in dedicated packages
- **Flexibility**: Easy to switch between Firebase and Appwrite
- **Maintainability**: Clear separation between UI, business logic, and data layers
- **Testability**: Each component can be tested independently

## Files Modified

### New Files
- `packages/authentication_client/appwrite_authentication_client/`
- `lib/login/view/login_with_email_password_page.dart`
- `APPWRITE_INTEGRATION.md`

### Modified Files
- `lib/login/bloc/login_event.dart`
- `lib/login/bloc/login_bloc.dart`
- `lib/login/view/view.dart`
- `lib/login/widgets/login_form.dart`
- `lib/main/main_development.dart`
- `packages/user_repository/lib/src/user_repository.dart`
- `pubspec.yaml`

## Dependencies Added

```yaml
appwrite_authentication_client:
  path: packages/authentication_client/appwrite_authentication_client
```

## Conclusion

The Appwrite authentication has been successfully integrated into the app, providing an alternative to Firebase authentication with support for email/password login and OAuth providers.
