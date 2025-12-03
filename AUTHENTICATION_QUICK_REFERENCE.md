# Authentication Quick Reference

Quick reference for using authentication in the Demo News app.

## Available Auth Providers

| Provider | Status | Use Case |
|----------|--------|----------|
| **Supabase** | ✅ Active (Development) | Modern, full-featured, open-source |
| **Appwrite** | ✅ Available | Self-hosted alternative |
| **Firebase** | ✅ Available (Production) | Google's BaaS platform |

## Quick Setup - Supabase

### 1. Get Credentials

```
1. Go to https://supabase.com
2. Create new project
3. Copy URL and anon key from Settings → API
```

### 2. Configure App

```dart
// lib/main/main_development.dart
final authenticationClient = SupabaseAuthenticationClient(
  tokenStorage: tokenStorage,
  supabaseUrl: 'https://xxxxx.supabase.co',
  supabaseAnonKey: 'eyJhbGciOiJIUz...',
);
```

### 3. Enable Email Auth

```
Supabase Dashboard → Authentication → Providers → Email → Enable
```

## Common Code Snippets

### Login with Email/Password

```dart
await context.read<UserRepository>().logInWithEmailPassword(
  email: emailController.text,
  password: passwordController.text,
);
```

### Sign Up

```dart
await context.read<UserRepository>().signUpWithEmailPassword(
  email: emailController.text,
  password: passwordController.text,
  name: nameController.text,
);
```

### Forgot Password

```dart
await context.read<UserRepository>().sendPasswordRecoveryEmail(
  email: emailController.text,
);
```

### Social Login

```dart
// Google
await context.read<UserRepository>().logInWithGoogle();

// Apple
await context.read<UserRepository>().logInWithApple();

// Facebook
await context.read<UserRepository>().logInWithFacebook();
```

### Logout

```dart
await context.read<UserRepository>().logOut();
```

### Get Current User

```dart
final user = await context.read<UserRepository>().user.first;

if (!user.isAnonymous) {
  print('Email: ${user.email}');
  print('Name: ${user.name}');
  print('ID: ${user.id}');
}
```

### Listen to Auth State

```dart
StreamBuilder<User>(
  stream: context.read<UserRepository>().user,
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final user = snapshot.data!;
      return user.isAnonymous ? LoginPage() : HomePage();
    }
    return LoadingPage();
  },
)
```

## Error Handling

### Try-Catch Pattern

```dart
try {
  await userRepository.logInWithEmailPassword(
    email: email,
    password: password,
  );
  // Success
  Navigator.pop(context);
} on LogInWithEmailLinkFailure catch (e) {
  // Handle auth-specific error
  showSnackBar('Invalid email or password');
} catch (e) {
  // Handle general error
  showSnackBar('Something went wrong');
}
```

### Bloc Pattern (Recommended)

```dart
// In LoginBloc
try {
  await _userRepository.logInWithEmailPassword(
    email: event.email,
    password: event.password,
  );
  emit(state.copyWith(status: LoginStatus.success));
} catch (e) {
  emit(state.copyWith(
    status: LoginStatus.failure,
    errorMessage: e.toString(),
  ));
}

// In UI
BlocListener<LoginBloc, LoginState>(
  listener: (context, state) {
    if (state.status.isSuccess) {
      Navigator.pop(context);
    } else if (state.status.isFailure) {
      showSnackBar(state.errorMessage);
    }
  },
)
```

## Switching Providers

### Use Supabase

```dart
import 'package:supabase_authentication_client/supabase_authentication_client.dart';

final authenticationClient = SupabaseAuthenticationClient(
  tokenStorage: tokenStorage,
  supabaseUrl: 'YOUR_URL',
  supabaseAnonKey: 'YOUR_KEY',
);
```

### Use Appwrite

```dart
import 'package:appwrite_authentication_client/appwrite_authentication_client.dart';

final authenticationClient = AppwriteAuthenticationClient(
  tokenStorage: tokenStorage,
  projectId: 'YOUR_PROJECT_ID',
  endpoint: 'YOUR_ENDPOINT',
);
```

### Use Firebase

```dart
import 'package:firebase_authentication_client/firebase_authentication_client.dart';

final authenticationClient = FirebaseAuthenticationClient(
  tokenStorage: tokenStorage,
);
```

## File Locations

```
lib/
├── login/
│   ├── bloc/
│   │   ├── login_bloc.dart          # Login business logic
│   │   └── login_event.dart         # Login events
│   ├── view/
│   │   ├── login_with_email_password_page.dart  # Email login UI
│   │   └── signup_with_email_password_page.dart # Sign up UI
│   └── widgets/
│       └── forgot_password_dialog.dart          # Password recovery UI
│
packages/
├── authentication_client/
│   ├── supabase_authentication_client/    # Supabase implementation
│   ├── appwrite_authentication_client/    # Appwrite implementation
│   └── firebase_authentication_client/    # Firebase implementation
│
└── user_repository/
    └── lib/src/user_repository.dart       # Auth business logic layer
```

## Validation Examples

### Email Validation

```dart
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Please enter a valid email';
  }
  return null;
}
```

### Password Validation

```dart
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 8) {
    return 'Password must be at least 8 characters';
  }
  if (!value.contains(RegExp(r'[A-Z]'))) {
    return 'Password must contain an uppercase letter';
  }
  if (!value.contains(RegExp(r'[a-z]'))) {
    return 'Password must contain a lowercase letter';
  }
  if (!value.contains(RegExp(r'[0-9]'))) {
    return 'Password must contain a number';
  }
  if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
    return 'Password must contain a special character';
  }
  return null;
}
```

### Name Validation

```dart
String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Name is required';
  }
  if (value.length < 2) {
    return 'Name must be at least 2 characters';
  }
  if (value.length > 50) {
    return 'Name must be less than 50 characters';
  }
  return null;
}
```

## Testing

### Mock Authentication Client

```dart
class MockAuthenticationClient extends Mock implements AuthenticationClient {}

void main() {
  group('UserRepository', () {
    late MockAuthenticationClient authClient;
    late UserRepository repository;

    setUp(() {
      authClient = MockAuthenticationClient();
      repository = UserRepository(
        authenticationClient: authClient,
        // ... other dependencies
      );
    });

    test('logInWithEmailPassword calls auth client', () async {
      when(() => authClient.logInWithEmailPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => {});

      await repository.logInWithEmailPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      verify(() => authClient.logInWithEmailPassword(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
    });
  });
}
```

## Environment Variables

### .env File

```env
# Supabase
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUz...

# Appwrite
APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
APPWRITE_PROJECT_ID=xxxxx

# OAuth
GOOGLE_CLIENT_ID=xxxxx
APPLE_CLIENT_ID=xxxxx
```

### Load in Dart

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  final supabaseUrl = dotenv.env['SUPABASE_URL']!;
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY']!;

  runApp(MyApp());
}
```

## Useful Commands

```bash
# Get dependencies
flutter pub get

# Run app in development mode
flutter run

# Run tests
flutter test

# Build for production
flutter build apk        # Android
flutter build ios        # iOS
flutter build web        # Web

# Check for outdated packages
flutter pub outdated

# Update packages
flutter pub upgrade
```

## Troubleshooting One-Liners

```bash
# Clear build cache
flutter clean && flutter pub get

# Reset Supabase client cache
rm -rf ~/.supabase

# Check Flutter doctor
flutter doctor -v

# Rebuild code generation
flutter pub run build_runner build --delete-conflicting-outputs
```

## Security Checklist

- [ ] Use HTTPS for all endpoints
- [ ] Never commit API keys to version control
- [ ] Use environment variables for secrets
- [ ] Enable Row Level Security in Supabase
- [ ] Implement rate limiting
- [ ] Validate all user input
- [ ] Use strong password requirements
- [ ] Enable email verification (production)
- [ ] Implement account lockout after failed attempts
- [ ] Log authentication events
- [ ] Use secure token storage
- [ ] Implement session timeout
- [ ] Enable 2FA (if available)

## Performance Tips

```dart
// Cache user data
final userCache = <String, User>{};

Future<User> getUser(String id) async {
  if (userCache.containsKey(id)) {
    return userCache[id]!;
  }

  final user = await fetchUser(id);
  userCache[id] = user;
  return user;
}

// Debounce form submissions
Timer? _debounce;

void onSearchChanged(String query) {
  _debounce?.cancel();
  _debounce = Timer(const Duration(milliseconds: 500), () {
    performSearch(query);
  });
}

// Use StreamBuilder wisely
Stream<User> get user => _userController.stream
    .distinct()  // Only emit when value changes
    .asBroadcastStream();
```

## Links

- 📚 [Full Documentation](SUPABASE_AUTHENTICATION_GUIDE.md)
- 🔗 [Supabase Dashboard](https://app.supabase.com)
- 📖 [Supabase Docs](https://supabase.com/docs)
- 🎯 [Flutter Docs](https://docs.flutter.dev)
- 💬 [Get Help](https://discord.supabase.com)
