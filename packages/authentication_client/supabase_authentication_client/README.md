# Supabase Authentication Client

A Supabase implementation of the authentication client interface for the Demo News app.

## Features

- Email/password authentication (login, signup, password recovery)
- OAuth authentication (Google, Apple, Facebook, Twitter)
- Magic link authentication (passwordless login)
- User session management
- Account deletion

## Setup

### 1. Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Once created, go to Settings > API
3. Copy your **Project URL** and **anon/public key**

### 2. Configure Authentication

In your main app file (e.g., `main_development.dart`), replace the placeholders with your Supabase credentials:

```dart
final authenticationClient = SupabaseAuthenticationClient(
  tokenStorage: tokenStorage,
  supabaseUrl: 'YOUR_SUPABASE_URL',  // Replace with your project URL
  supabaseAnonKey: 'YOUR_SUPABASE_ANON_KEY',  // Replace with your anon key
);
```

### 3. Enable Authentication Providers

In your Supabase dashboard:

1. Go to Authentication > Providers
2. Enable the providers you want to use:
   - **Email**: Enable email/password authentication
   - **Google**: Configure Google OAuth
   - **Apple**: Configure Apple OAuth
   - **Facebook**: Configure Facebook OAuth
   - **Twitter**: Configure Twitter OAuth

### 4. Configure Email Templates (Optional)

For password recovery emails, go to Authentication > Email Templates and customize:
- Reset Password template
- Magic Link template

## Usage

### Login with Email/Password

```dart
await userRepository.logInWithEmailPassword(
  email: 'user@example.com',
  password: 'password123',
);
```

### Sign Up with Email/Password

```dart
await userRepository.signUpWithEmailPassword(
  email: 'user@example.com',
  password: 'password123',
  name: 'John Doe',  // optional
);
```

### Password Recovery

```dart
await userRepository.sendPasswordRecoveryEmail(
  email: 'user@example.com',
);
```

### OAuth Login

```dart
// Google
await userRepository.logInWithGoogle();

// Apple
await userRepository.logInWithApple();

// Facebook
await userRepository.logInWithFacebook();

// Twitter
await userRepository.logInWithTwitter();
```

## Security Considerations

- **Never commit your Supabase credentials** to version control
- Use environment variables or secure configuration management
- The anon key is safe to use in client-side code (it has Row Level Security)
- For production, consider implementing Row Level Security (RLS) policies in Supabase

## Account Deletion

Note: Client-side account deletion requires a Supabase Edge Function for security.
The current implementation signs out the user. To implement full account deletion:

1. Create a Supabase Edge Function:

```javascript
import { createClient } from '@supabase/supabase-js'

Deno.serve(async (req) => {
  const supabaseAdmin = createClient(
    Deno.env.get('SUPABASE_URL'),
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
  )

  const { userId } = await req.json()
  await supabaseAdmin.auth.admin.deleteUser(userId)

  return new Response(JSON.stringify({ success: true }))
})
```

2. Update the `deleteAccount` method to call this function

## Dependencies

- `supabase_flutter: ^2.0.0`
- `authentication_client` (path: ../authentication_client)
- `token_storage` (path: ../token_storage)
