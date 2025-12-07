# Demo News App - Project Documentation

## Overview

Demo News is a full-featured Flutter news application that provides fact-checked news stories with accuracy scoring and propaganda detection. The app uses Supabase for backend authentication and data storage, and implements a clean architecture pattern with BLoC state management.

## Table of Contents

1. [Architecture](#architecture)
2. [Project Structure](#project-structure)
3. [Authentication System](#authentication-system)
4. [Features](#features)
5. [State Management](#state-management)
6. [API Integration](#api-integration)
7. [News Feed System](#news-feed-system)
8. [Stories & Fact-Checking](#stories--fact-checking)
9. [Configuration](#configuration)
10. [Building & Running](#building--running)

---

## Architecture

The app follows a **layered clean architecture** pattern:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│   (UI, Widgets, BLoC, Pages)           │
├─────────────────────────────────────────┤
│         Domain Layer                    │
│   (Business Logic, Use Cases)           │
├─────────────────────────────────────────┤
│         Data Layer                      │
│   (Repositories, Data Sources)          │
├─────────────────────────────────────────┤
│         Infrastructure                  │
│   (APIs, Database, Authentication)      │
└─────────────────────────────────────────┘
```

### Key Architectural Principles

- **Separation of Concerns**: Each layer has distinct responsibilities
- **Dependency Inversion**: Higher layers don't depend on lower layers
- **Package-by-Feature**: Code organized by feature, not by type
- **Repository Pattern**: Abstracts data sources from business logic
- **BLoC Pattern**: Manages state and business logic predictably

---

## Project Structure

```
demo_news/
├── lib/
│   ├── app/                    # App initialization and routing
│   │   ├── bloc/              # Global app state (AppBloc)
│   │   ├── routes/            # Navigation configuration
│   │   └── view/              # Main app widget
│   │
│   ├── login/                  # Authentication feature
│   │   ├── bloc/              # Login state management
│   │   ├── view/              # Login screens
│   │   └── widgets/           # Login form components
│   │
│   ├── feed/                   # News feed feature
│   │   ├── bloc/              # Feed state management
│   │   ├── view/              # Feed screens
│   │   └── widgets/           # Feed item components
│   │
│   ├── stories/                # Fact-checked stories
│   │   └── view/              # Stories list and cards
│   │
│   ├── article/                # Article detail view
│   │   ├── bloc/              # Article state
│   │   ├── view/              # Article page
│   │   └── widgets/           # Article components
│   │
│   ├── categories/             # News categories
│   │   ├── bloc/              # Category state
│   │   └── view/              # Category tabs
│   │
│   ├── onboarding/             # First-time user flow
│   ├── subscriptions/          # Premium features
│   ├── ads/                    # Advertisement integration
│   └── main/                   # App entry points
│       ├── main_development.dart
│       ├── main_production.dart
│       └── bootstrap/
│
├── packages/                   # Shared packages
│   ├── authentication_client/  # Auth abstraction layer
│   │   ├── authentication_client/        # Interface
│   │   └── supabase_authentication_client/ # Implementation
│   │
│   ├── user_repository/        # User data management
│   ├── news_repository/        # News data management
│   ├── stories_repository/     # Stories data management
│   ├── article_repository/     # Article data management
│   ├── app_ui/                # Shared UI components
│   ├── form_inputs/           # Form validation
│   └── token_storage/         # Secure token storage
│
├── api/                        # Backend API (Dart Frog)
│   ├── routes/                # API endpoints
│   └── lib/                   # Shared API models
│
└── ios/                        # iOS-specific configuration
```

---

## Authentication System

### Overview

The app uses **Supabase** for authentication with email/password login and user registration.

### Architecture

```
┌──────────────┐
│  LoginBloc   │ ← Presentation Layer
└──────┬───────┘
       │
┌──────▼──────────────┐
│  UserRepository     │ ← Domain Layer
└──────┬──────────────┘
       │
┌──────▼──────────────────────┐
│  AuthenticationClient       │ ← Data Layer (Interface)
└──────┬──────────────────────┘
       │
┌──────▼──────────────────────┐
│ SupabaseAuthenticationClient│ ← Infrastructure (Implementation)
└─────────────────────────────┘
```

### Flow

1. **User Input** → User enters credentials in login form
2. **LoginBloc** → Validates input and triggers login event
3. **UserRepository** → Receives login request
4. **SupabaseAuthenticationClient** → Performs authentication with Supabase
5. **Token Storage** → Securely stores auth token
6. **AppBloc** → Updates global auth state
7. **UI Navigation** → Redirects to home page

### Key Files

- `lib/login/bloc/login_bloc.dart` - Login state management
- `lib/login/widgets/login_form.dart` - Login UI
- `packages/user_repository/` - User data abstraction
- `packages/authentication_client/supabase_authentication_client/` - Supabase integration

### Email/Password Authentication

```dart
// Sign Up
await userRepository.signUpWithEmailPassword(
  email: 'user@example.com',
  password: 'securePassword123',
  name: 'John Doe',
);

// Sign In
await userRepository.logInWithEmailPassword(
  email: 'user@example.com',
  password: 'securePassword123',
);

// Sign Out
await userRepository.logOut();
```

---

## Features

### 1. News Feed

- **Multi-Category Tabs**: Browse news by category (Top, Business, Tech, Sports, etc.)
- **Infinite Scroll**: Automatically loads more news as you scroll
- **Pull-to-Refresh**: Swipe down to refresh news feed
- **Article Preview**: Tappable cards with headline and summary

**Key Components:**
- `lib/feed/view/feed_view.dart` - Main feed interface
- `lib/feed/widgets/category_feed.dart` - Category-specific feed
- `lib/feed/bloc/feed_bloc.dart` - Feed state management

### 2. Fact-Checked Stories

- **Accuracy Scoring**: Each story has an accuracy score (0-100)
- **Propaganda Detection**: Identifies propaganda indicators
- **Source Analysis**: Shows sources used by authors and AI
- **Collapsible Sections**: Tap to expand detailed analysis

**Key Components:**
- `lib/stories/view/stories_view.dart` - Stories list
- `packages/stories_repository/` - Stories data management

### 3. Article Reader

- **Full Article View**: Read complete articles with images
- **Rich Content**: Supports markdown, images, videos
- **Share Functionality**: Share articles via native share sheet
- **Subscription Prompts**: Paywall for premium content

### 4. User Profiles

- **Login/Logout**: Email/password authentication
- **Profile Management**: View and edit user information
- **Subscription Status**: Premium vs free tier

### 5. Onboarding

- **First Launch**: Welcome screen with app introduction
- **Notifications**: Request notification permissions
- **Ad Consent**: GDPR-compliant ad personalization

### 6. Offline Support

- **Hydrated BLoC**: Persists state locally
- **Page Storage**: Remembers scroll positions
- **Network Error Handling**: Graceful offline mode

---

## State Management

### BLoC Pattern

The app uses the **BLoC (Business Logic Component)** pattern for state management.

#### Key BLoCs

1. **AppBloc** (`lib/app/bloc/app_bloc.dart`)
   - Global app state
   - Authentication status
   - User information
   - Subscription state

2. **LoginBloc** (`lib/login/bloc/login_bloc.dart`)
   - Login form state
   - Email/password validation
   - Login submission status

3. **FeedBloc** (`lib/feed/bloc/feed_bloc.dart`)
   - News feed data
   - Category selection
   - Loading states
   - Pagination

4. **CategoriesBloc** (`lib/categories/bloc/categories_bloc.dart`)
   - Available categories
   - Selected category
   - Category switching

5. **ArticleBloc** (`lib/article/bloc/article_bloc.dart`)
   - Article content
   - Sharing functionality
   - View tracking

### State Flow Example

```dart
// 1. UI triggers event
context.read<FeedBloc>().add(
  FeedRequested(category: Category.technology),
);

// 2. BLoC processes event
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc() : super(FeedState.initial()) {
    on<FeedRequested>(_onFeedRequested);
  }

  Future<void> _onFeedRequested(
    FeedRequested event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.copyWith(status: FeedStatus.loading));

    final news = await _newsRepository.getNews(
      category: event.category,
    );

    emit(state.copyWith(
      status: FeedStatus.success,
      feed: news,
    ));
  }
}

// 3. UI rebuilds with new state
BlocBuilder<FeedBloc, FeedState>(
  builder: (context, state) {
    if (state.status == FeedStatus.loading) {
      return CircularProgressIndicator();
    }
    return NewsListView(news: state.feed);
  },
)
```

---

## API Integration

### Supabase

**URL**: `https://nxfiplvukpehppydgseh.supabase.co`

**Services Used:**
- **Authentication**: User login and registration
- **Database**: User profiles and preferences
- **Storage**: Article images and media

**Configuration:**
```dart
// lib/main/main_development.dart
final authenticationClient = SupabaseAuthenticationClient(
  tokenStorage: tokenStorage,
  supabaseUrl: 'https://nxfiplvukpehppydgseh.supabase.co',
  supabaseAnonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
);
```

### News API

The app uses a custom Dart Frog API (`api/`) for news content.

**Endpoints:**
- `GET /stories` - Fetch fact-checked stories
- `GET /categories` - Get available categories
- `GET /feed/{category}` - Get news by category

---

## News Feed System

### How It Works

1. **Category Selection**
   - User taps category tab
   - `CategoriesBloc` emits selected category
   - `FeedBloc` listens and loads category news

2. **Infinite Scroll**
   - `CategoryFeedLoaderItem` widget detects when visible
   - Triggers `FeedRequested` event with pagination
   - New items appended to existing feed

3. **Scroll Optimization**
   - Custom scroll physics for smooth scrolling
   - Reduced sensitivity for better control
   - Separate `ScrollController` per category
   - Page storage preserves scroll position

### Category Tabs

```dart
TabController(
  length: categories.length,
  vsync: this,
)

TabBarView(
  controller: _tabController,
  children: categories.map((category) =>
    CategoryFeed(category: category)
  ).toList(),
)
```

---

## Stories & Fact-Checking

### Story Model

```dart
class Story {
  final String? summary;
  final int? accuracyScore;      // 0-100
  final int? propagandaScore;    // 0-100
  final String? accuracyAssessment;
  final String? propagandaIndicators;
  final String? authorSources;
  final String? aiSources;
  final String? overallMetrics;
}
```

### Scoring System

- **Accuracy Score (0-100)**
  - 70-100: High accuracy (green)
  - 40-69: Medium accuracy (orange)
  - 0-39: Low accuracy (red)

- **Propaganda Score (0-100)**
  - 0-50: Low propaganda (orange)
  - 51-100: High propaganda (red)

### Data Source

Stories are fetched from `StoriesRepository`:

```dart
final response = await storiesRepository.getStories(
  limit: 10,
  offset: 0,
);
```

---

## Configuration

### Flavors

The app supports multiple build flavors:

1. **Development** (`lib/main/main_development.dart`)
   - Debug mode
   - Development API endpoints
   - Verbose logging

2. **Production** (`lib/main/main_production.dart`)
   - Release mode
   - Production API endpoints
   - Analytics enabled

### Environment Variables

Required environment variables:

```bash
SUPABASE_ANON_KEY=your_supabase_anon_key
FACEBOOK_APP_ID=your_facebook_app_id
FACEBOOK_CLIENT_TOKEN=your_facebook_client_token
ADMOB_APP_ID=your_admob_app_id
```

### iOS Configuration

Key files:
- `ios/Runner/Info.plist` - App metadata and URL schemes
- `ios/Runner/Runner.entitlements` - Capabilities
- `ios/Runner/Config/` - Environment-specific configs

---

## Building & Running

### Development

```bash
# Run development flavor
flutter run --flavor development -t lib/main/main_development.dart

# Build iOS development
flutter build ios --flavor development -t lib/main/main_development.dart
```

### Production

```bash
# Run production flavor
flutter run --flavor production -t lib/main/main_production.dart

# Build iOS production
flutter build ios --flavor production -t lib/main/main_production.dart
```

### Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

---

## Key Technologies

- **Flutter**: 3.x
- **Dart**: 3.x
- **State Management**: flutter_bloc ^8.1.6
- **Backend**: Supabase ^2.0.0
- **Routing**: flow_builder
- **Storage**: hydrated_bloc
- **UI**: app_ui (custom package)
- **Analytics**: analytics_repository
- **Ads**: google_mobile_ads

---

## Safe Area Handling

The app properly handles iOS safe areas:

- Login modal uses `useSafeArea: true` in `showModalBottomSheet`
- Onboarding page wrapped in `SafeArea`
- All modals respect notch, status bar, and home indicator

---

## Scroll Configuration

Custom scroll physics reduce sensitivity:

```dart
class _ReducedVelocityScrollPhysics extends ScrollPhysics {
  @override
  double applyPhysicsToUserOffset(
    ScrollMetrics position,
    double offset,
  ) {
    return super.applyPhysicsToUserOffset(position, offset * 0.5);
  }
}
```

---

## Troubleshooting

### Common Issues

1. **Build Fails**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Delete `ios/Pods` and run `pod install`

2. **Authentication Not Working**
   - Check `SUPABASE_ANON_KEY` is set
   - Verify Supabase URL is correct
   - Check network connection

3. **News Feed Empty**
   - Verify API is running (`api/` directory)
   - Check network permissions in `Info.plist`

---

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Write/update tests
5. Submit a pull request

---

## License

Copyright © 2024 Demo News App
