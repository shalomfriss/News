# Authentication Architecture

This document explains the architecture of the authentication system in the Demo News app.

## Architecture Overview

The authentication system follows a **layered architecture** with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────┐
│                     UI Layer                            │
│  (LoginPage, SignUpPage, ForgotPasswordDialog)         │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│                  Presentation Layer                     │
│              (LoginBloc, AppBloc)                       │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│                  Domain Layer                           │
│                (UserRepository)                         │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│              Data Layer (Interface)                     │
│            (AuthenticationClient)                       │
└────────────────┬────────────────────────────────────────┘
                 │
      ┌──────────┼──────────┬──────────┐
      ▼          ▼          ▼          ▼
┌──────────┐┌──────────┐┌──────────┐┌──────────┐
│ Supabase ││ Appwrite ││ Firebase ││  Custom  │
│  Client  ││  Client  ││  Client  ││  Client  │
└──────────┘└──────────┘└──────────┘└──────────┘
```

## Layer Responsibilities

### 1. UI Layer

**Location**: `lib/login/view/`

**Responsibilities**:
- Display login, signup, and password recovery forms
- Capture user input (email, password, etc.)
- Show loading states and error messages
- Navigate between screens

**Key Components**:
- `LoginWithEmailPasswordPage` - Email/password login UI
- `SignUpWithEmailPasswordPage` - User registration UI
- `ForgotPasswordDialog` - Password recovery UI
- `LoginPage` - Main login screen with provider options

**Dependencies**:
- Presentation Layer (LoginBloc)
- UI components from `app_ui` package

### 2. Presentation Layer (BLoC)

**Location**: `lib/login/bloc/`

**Responsibilities**:
- Manage authentication state
- Handle user actions (events)
- Coordinate with UserRepository
- Emit UI states (loading, success, failure)

**Key Components**:
- `LoginBloc` - Handles login logic
- `LoginEvent` - User actions (submit, Google login, etc.)
- `LoginState` - Current state (idle, loading, success, failure)
- `AppBloc` - App-wide authentication state

**Pattern**: BLoC (Business Logic Component)

```dart
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const LoginState()) {
    on<LoginEmailPasswordSubmitted>(_onEmailPasswordSubmitted);
    on<LoginWithGoogleRequested>(_onGoogleRequested);
    // ... other events
  }

  Future<void> _onEmailPasswordSubmitted(
    LoginEmailPasswordSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.inProgress));

    try {
      await _userRepository.logInWithEmailPassword(
        email: event.email,
        password: event.password,
      );
      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      emit(state.copyWith(status: LoginStatus.failure));
    }
  }
}
```

### 3. Domain Layer (Repository)

**Location**: `packages/user_repository/`

**Responsibilities**:
- Define business logic
- Provide high-level authentication API
- Coordinate with authentication client
- Handle app-specific user operations
- Manage subscription state

**Key Components**:
- `UserRepository` - Main repository class
- `User` - User domain model
- `UserFailure` - Domain-specific exceptions

**Benefits**:
- Abstracts authentication implementation details
- Provides consistent API regardless of provider
- Easy to mock for testing
- Single source of truth for user state

```dart
class UserRepository {
  Future<void> logInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final authClient = _authenticationClient as dynamic;
      await authClient.logInWithEmailPassword(
        email: email,
        password: password,
      );
    } on LogInWithEmailLinkFailure {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        LogInWithEmailLinkFailure(error),
        stackTrace,
      );
    }
  }

  Stream<User> get user =>
      Rx.combineLatest2<AuthenticationUser, SubscriptionPlan, User>(
        _authenticationClient.user,
        _currentSubscriptionPlanSubject.stream,
        (authUser, subscription) => User.fromAuthenticationUser(
          authenticationUser: authUser,
          subscriptionPlan: subscription,
        ),
      );
}
```

### 4. Data Layer (Interface)

**Location**: `packages/authentication_client/authentication_client/`

**Responsibilities**:
- Define authentication contract (interface)
- Specify common exceptions
- Define AuthenticationUser model

**Key Components**:
- `AuthenticationClient` - Abstract interface
- `AuthenticationException` - Base exception type
- `AuthenticationUser` - Authentication user model

**Interface**:

```dart
abstract class AuthenticationClient {
  Stream<AuthenticationUser> get user;

  Future<void> logInWithApple();
  Future<void> logInWithGoogle();
  Future<void> logInWithFacebook();
  Future<void> logInWithTwitter();

  Future<void> sendLoginEmailLink({
    required String email,
    required String appPackageName,
  });

  bool isLogInWithEmailLink({required String emailLink});

  Future<void> logInWithEmailLink({
    required String email,
    required String emailLink,
  });

  Future<void> logOut();
  Future<void> deleteAccount();
}
```

### 5. Implementation Layer

**Location**: `packages/authentication_client/*/`

**Responsibilities**:
- Implement AuthenticationClient interface
- Handle provider-specific logic
- Manage sessions and tokens
- Handle provider-specific errors

**Implementations**:

#### Supabase Implementation

```dart
class SupabaseAuthenticationClient implements AuthenticationClient {
  SupabaseAuthenticationClient({
    required TokenStorage tokenStorage,
    required String supabaseUrl,
    required String supabaseAnonKey,
  });

  Future<void> logInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    await _client!.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Additional Supabase-specific methods
  Future<void> signUpWithEmailPassword({...}) async {...}
  Future<void> sendPasswordRecoveryEmail({...}) async {...}
}
```

#### Appwrite Implementation

```dart
class AppwriteAuthenticationClient implements AuthenticationClient {
  AppwriteAuthenticationClient({
    required TokenStorage tokenStorage,
    required String projectId,
    required String endpoint,
  });

  Future<void> logInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    await _account.createEmailPasswordSession(
      email: email,
      password: password,
    );
  }

  // Additional Appwrite-specific methods
  Future<void> signUpWithEmailPassword({...}) async {...}
  Future<void> sendPasswordRecoveryEmail({...}) async {...}
}
```

## Data Flow

### Login Flow

```
1. User enters email/password
         │
         ▼
2. UI dispatches LoginEmailPasswordSubmitted event
         │
         ▼
3. LoginBloc receives event
         │
         ▼
4. LoginBloc calls UserRepository.logInWithEmailPassword()
         │
         ▼
5. UserRepository calls AuthenticationClient.logInWithEmailPassword()
         │
         ▼
6. SupabaseAuthenticationClient calls Supabase API
         │
         ▼
7. Supabase returns user session
         │
         ▼
8. AuthenticationClient emits user on stream
         │
         ▼
9. UserRepository transforms to User model
         │
         ▼
10. AppBloc receives user update
         │
         ▼
11. UI updates to show authenticated state
```

### Registration Flow

```
1. User fills signup form (email, password, name)
         │
         ▼
2. UI calls UserRepository.signUpWithEmailPassword()
         │
         ▼
3. UserRepository calls dynamic method on AuthenticationClient
         │
         ▼
4. SupabaseAuthenticationClient.signUpWithEmailPassword()
         │
         ▼
5. Supabase creates user account
         │
         ▼
6. User automatically logged in
         │
         ▼
7. Auth state stream emits new user
         │
         ▼
8. UI shows success and navigates away
```

### Password Recovery Flow

```
1. User clicks "Forgot Password?"
         │
         ▼
2. Dialog opens, user enters email
         │
         ▼
3. UI calls UserRepository.sendPasswordRecoveryEmail()
         │
         ▼
4. UserRepository calls dynamic method on AuthenticationClient
         │
         ▼
5. SupabaseAuthenticationClient.sendPasswordRecoveryEmail()
         │
         ▼
6. Supabase sends recovery email
         │
         ▼
7. User clicks link in email
         │
         ▼
8. Deep link opens app with token
         │
         ▼
9. User enters new password
         │
         ▼
10. UI calls updatePassword()
         │
         ▼
11. Password updated, user logged in
```

## Dependency Injection

The app uses manual dependency injection through the bootstrap process:

```dart
// lib/main/main_development.dart
void main() {
  bootstrap((
    firebaseDynamicLinks,
    firebaseMessaging,
    sharedPreferences,
    analyticsRepository,
  ) async {
    // 1. Create storage
    final tokenStorage = InMemoryTokenStorage();
    final persistentStorage = PersistentStorage(
      sharedPreferences: sharedPreferences,
    );

    // 2. Create authentication client
    final authenticationClient = SupabaseAuthenticationClient(
      tokenStorage: tokenStorage,
      supabaseUrl: 'YOUR_SUPABASE_URL',
      supabaseAnonKey: 'YOUR_SUPABASE_ANON_KEY',
    );

    // 3. Create repository
    final userRepository = UserRepository(
      authenticationClient: authenticationClient,
      // ... other dependencies
    );

    // 4. Create app with repositories
    return App(
      userRepository: userRepository,
      // ... other repositories
    );
  });
}
```

The `App` widget then provides repositories to the widget tree:

```dart
class App extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _userRepository),
        RepositoryProvider.value(value: _newsRepository),
        // ... other repositories
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AppBloc(
              userRepository: _userRepository,
              user: _user,
            ),
          ),
          // ... other blocs
        ],
        child: MaterialApp(...),
      ),
    );
  }
}
```

Widgets can then access repositories and blocs:

```dart
// Access repository
final userRepository = context.read<UserRepository>();

// Access bloc
final loginBloc = context.read<LoginBloc>();

// Watch bloc state
final state = context.watch<LoginBloc>().state;

// Listen to bloc changes
BlocListener<LoginBloc, LoginState>(
  listener: (context, state) {
    // React to state changes
  },
)
```

## State Management

### Authentication State

The app uses **streams** to manage authentication state:

```dart
// In AuthenticationClient
final StreamController<AuthenticationUser> _userController =
    StreamController<AuthenticationUser>.broadcast();

Stream<AuthenticationUser> get user => _userController.stream;

// In UserRepository
Stream<User> get user =>
    Rx.combineLatest2<AuthenticationUser, SubscriptionPlan, User>(
      _authenticationClient.user,
      _currentSubscriptionPlanSubject.stream,
      (authUser, subscription) => User.fromAuthenticationUser(
        authenticationUser: authUser,
        subscriptionPlan: subscription,
      ),
    );
```

### UI State

The app uses **BLoC pattern** for UI state:

```dart
// State
class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
    this.errorMessage,
  });

  final LoginStatus status;
  final String? errorMessage;

  LoginState copyWith({
    LoginStatus? status,
    String? errorMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}

// Event
abstract class LoginEvent extends Equatable {
  const LoginEvent();
}

class LoginEmailPasswordSubmitted extends LoginEvent {
  const LoginEmailPasswordSubmitted({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}

// Bloc
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const LoginState()) {
    on<LoginEmailPasswordSubmitted>(_onEmailPasswordSubmitted);
  }

  Future<void> _onEmailPasswordSubmitted(
    LoginEmailPasswordSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.inProgress));

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
  }
}
```

## Error Handling

### Exception Hierarchy

```
Exception
│
├── AuthenticationException (abstract)
│   ├── LogInWithAppleFailure
│   ├── LogInWithGoogleFailure
│   ├── LogInWithGoogleCanceled
│   ├── LogInWithFacebookFailure
│   ├── LogInWithFacebookCanceled
│   ├── LogInWithTwitterFailure
│   ├── LogInWithTwitterCanceled
│   ├── LogInWithEmailLinkFailure
│   ├── SendLoginEmailLinkFailure
│   ├── IsLogInWithEmailLinkFailure
│   ├── LogOutFailure
│   └── DeleteAccountFailure
│
└── UserFailure (abstract)
    ├── FetchAppOpenedCountFailure
    ├── IncrementAppOpenedCountFailure
    └── FetchCurrentSubscriptionFailure
```

### Error Propagation

```dart
// Layer 1: Implementation throws specific error
throw LogInWithEmailLinkFailure(error);

// Layer 2: Repository catches and rethrows or wraps
try {
  await authClient.logInWithEmailPassword(...);
} on LogInWithEmailLinkFailure {
  rethrow;  // Pass through
} catch (error, stackTrace) {
  Error.throwWithStackTrace(
    LogInWithEmailLinkFailure(error),
    stackTrace,
  );
}

// Layer 3: BLoC catches and updates state
try {
  await userRepository.logInWithEmailPassword(...);
  emit(state.copyWith(status: LoginStatus.success));
} catch (e) {
  emit(state.copyWith(
    status: LoginStatus.failure,
    errorMessage: _mapErrorToMessage(e),
  ));
}

// Layer 4: UI displays error
BlocListener<LoginBloc, LoginState>(
  listener: (context, state) {
    if (state.status.isFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage ?? 'Login failed')),
      );
    }
  },
)
```

## Testing Strategy

### Unit Tests

Test each layer independently:

```dart
// Test AuthenticationClient
group('SupabaseAuthenticationClient', () {
  test('logInWithEmailPassword succeeds', () async {
    // Test implementation
  });
});

// Test UserRepository
group('UserRepository', () {
  late MockAuthenticationClient mockAuthClient;
  late UserRepository repository;

  setUp(() {
    mockAuthClient = MockAuthenticationClient();
    repository = UserRepository(
      authenticationClient: mockAuthClient,
      // ... other mocks
    );
  });

  test('logInWithEmailPassword calls auth client', () async {
    when(() => mockAuthClient.logInWithEmailPassword(
      email: any(named: 'email'),
      password: any(named: 'password'),
    )).thenAnswer((_) async => {});

    await repository.logInWithEmailPassword(
      email: 'test@example.com',
      password: 'password123',
    );

    verify(() => mockAuthClient.logInWithEmailPassword(
      email: 'test@example.com',
      password: 'password123',
    )).called(1);
  });
});

// Test BLoC
group('LoginBloc', () {
  late MockUserRepository mockUserRepository;
  late LoginBloc loginBloc;

  setUp(() {
    mockUserRepository = MockUserRepository();
    loginBloc = LoginBloc(userRepository: mockUserRepository);
  });

  blocTest<LoginBloc, LoginState>(
    'emits success when login succeeds',
    build: () {
      when(() => mockUserRepository.logInWithEmailPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => {});
      return loginBloc;
    },
    act: (bloc) => bloc.add(
      LoginEmailPasswordSubmitted(
        email: 'test@example.com',
        password: 'password123',
      ),
    ),
    expect: () => [
      LoginState(status: LoginStatus.inProgress),
      LoginState(status: LoginStatus.success),
    ],
  );
});
```

### Integration Tests

Test complete flows:

```dart
void main() {
  testWidgets('Complete login flow', (tester) async {
    await tester.pumpWidget(MyApp());

    // Navigate to login
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    // Enter credentials
    await tester.enterText(
      find.byKey(Key('emailInput')),
      'test@example.com',
    );
    await tester.enterText(
      find.byKey(Key('passwordInput')),
      'password123',
    );

    // Submit
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    // Verify navigation to home
    expect(find.text('Home'), findsOneWidget);
  });
}
```

## Performance Considerations

### Stream Optimization

```dart
// Use broadcast streams for multiple listeners
final _userController = StreamController<AuthenticationUser>.broadcast();

// Use distinct to prevent unnecessary updates
Stream<User> get user => _userController.stream
    .distinct()
    .map((authUser) => User.fromAuthenticationUser(authUser));

// Debounce rapid changes
Stream<User> get user => _userController.stream
    .debounceTime(Duration(milliseconds: 300));
```

### Caching

```dart
// Cache user data
User? _cachedUser;
DateTime? _cacheTime;

Future<User> getUser() async {
  if (_cachedUser != null &&
      _cacheTime != null &&
      DateTime.now().difference(_cacheTime!) < Duration(minutes: 5)) {
    return _cachedUser!;
  }

  final user = await _fetchUser();
  _cachedUser = user;
  _cacheTime = DateTime.now();
  return user;
}
```

### Lazy Initialization

```dart
// Lazy-load authentication client
SupabaseClient? _client;

SupabaseClient get client {
  if (_client == null) {
    _client = Supabase.instance.client;
  }
  return _client!;
}
```

## Security Considerations

### Token Storage

```dart
// Use secure storage for sensitive tokens
class SecureTokenStorage implements TokenStorage {
  final FlutterSecureStorage _storage;

  @override
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  @override
  Future<String?> readToken() async {
    return await _storage.read(key: 'auth_token');
  }

  @override
  Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
  }
}
```

### Input Validation

Always validate user input before sending to backend:

```dart
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) return 'Email required';
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return 'Invalid email';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Password required';
  if (value.length < 8) return 'Minimum 8 characters';
  // Add more validation rules
  return null;
}
```

### Session Management

```dart
// Auto-refresh tokens
Timer.periodic(Duration(minutes: 50), (_) async {
  await _refreshSession();
});

// Handle expired sessions
try {
  await makeAuthenticatedRequest();
} on SessionExpiredException {
  await _refreshSession();
  await makeAuthenticatedRequest();
}
```

## Extension Points

### Adding New Auth Provider

1. Create new package:
```
packages/authentication_client/my_provider_authentication_client/
```

2. Implement interface:
```dart
class MyProviderAuthenticationClient implements AuthenticationClient {
  // Implement all required methods
}
```

3. Update main.dart:
```dart
final authenticationClient = MyProviderAuthenticationClient(...);
```

### Adding New Auth Method

1. Add method to interface (if common):
```dart
abstract class AuthenticationClient {
  Future<void> logInWithBiometrics();
}
```

2. Implement in each client:
```dart
class SupabaseAuthenticationClient implements AuthenticationClient {
  @override
  Future<void> logInWithBiometrics() async {
    // Implementation
  }
}
```

3. Add to repository:
```dart
class UserRepository {
  Future<void> logInWithBiometrics() async {
    await _authenticationClient.logInWithBiometrics();
  }
}
```

4. Create UI and BLoC:
```dart
class LoginEvent {}
class LoginWithBiometricsRequested extends LoginEvent {}

// In BLoC
on<LoginWithBiometricsRequested>(_onBiometricsRequested);
```

## Conclusion

This architecture provides:

✅ **Separation of Concerns**: Each layer has clear responsibilities
✅ **Testability**: Easy to mock and test each layer
✅ **Flexibility**: Easy to swap authentication providers
✅ **Maintainability**: Changes are localized to specific layers
✅ **Scalability**: Easy to add new features and providers
✅ **Type Safety**: Full Dart type checking
✅ **Error Handling**: Structured exception hierarchy
✅ **Performance**: Optimized with streams and caching

The layered approach ensures the app remains maintainable as it grows and makes it easy to switch between different authentication providers without affecting the UI or business logic.
