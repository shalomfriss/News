# Flutter News Demo App - Comprehensive Codebase Overview

## 1. Project Overview & Architecture

### Overall Structure
This is a **Flutter news application** with a multi-package architecture following clean architecture principles. The app provides news content, authentication, subscriptions, and ad management with state management through BLoC pattern.

**Key Technologies:**
- **State Management**: BLoC (8.1.0) + Hydrated BLoC (9.0.0) for persistence
- **Authentication**: Firebase Auth (6.1.2) + Custom Authentication Client
- **Networking**: Custom REST API client (demo_news_api)
- **Ads**: Google Mobile Ads (5.0.0)
- **Analytics**: Firebase Analytics (12.0.4)
- **Notifications**: Firebase Messaging (16.0.4)
- **Storage**: SharedPreferences + Persistent Storage wrapper
- **Backend Integration**: Appwrite (17.0.0) for additional backend services
- **Code Generation**: JSON Serializable (6.8.0)

---

## 2. Main Directory Structure

### Root-Level Directories

```
/lib                    # Main application code
├── ads/                # Ad management (Google Mobile Ads)
├── analytics/          # Analytics tracking (Firebase)
├── app/                # App-level BLoC and routing
├── article/            # Article viewing and content
├── categories/         # News categories management
├── feed/               # News feed display
├── home/               # Home screen and navigation
├── l10n/               # Localization (ARB files)
├── login/              # Authentication screens and logic
├── magic_link_prompt/  # Magic link verification UI
├── main/               # App entry points and bootstrap
├── navigation/         # Navigation structure
├── network_error/      # Network error handling UI
├── newsletter/         # Newsletter subscription
├── notification_preferences/ # Push notification settings
├── onboarding/         # First-time user experience
├── search/             # Article search functionality
├── slideshow/          # Article slideshow view
├── subscriptions/      # In-app purchase subscriptions
├── terms_of_service/   # Terms display
├── theme_selector/     # Theme switching (light/dark)
└── user_profile/       # User profile management

/packages               # Shared packages (modular architecture)
├── ads_consent_client/          # Google Consent Management
├── analytics_repository/        # Analytics abstraction
├── app_ui/                      # UI components & theming
├── article_repository/          # Article data management
├── authentication_client/       # Auth abstraction layer
├── deep_link_client/            # Deep linking abstraction
├── email_launcher/              # Email functionality
├── form_inputs/                 # Form validation
├── in_app_purchase_repository/  # IAP management
├── news_blocks_ui/              # News content UI blocks
├── news_repository/             # News data management
├── notifications_client/        # Push notifications abstraction
├── notifications_repository/    # Notification preferences
├── package_info_client/         # App info
├── permission_client/           # Permissions handling
├── purchase_client/             # IAP client
├── share_launcher/              # Share functionality
├── storage/                     # Storage abstraction
├── user_repository/             # User data management
└── authentication_client/
    ├── authentication_client/   # Base auth interface
    ├── firebase_authentication_client/ # Firebase implementation
    └── token_storage/           # Token persistence

/api                   # Backend API layer
├── lib/src/
│   ├── client/        # DemoNewsApiClient
│   ├── data/          # Network adapters
│   ├── middleware/    # HTTP middleware
│   └── models/        # Response DTOs
└── packages/
    └── news_blocks/   # Serializable news block types

/android, /ios         # Platform-specific code

```

---

## 3. Architecture Patterns

### BLoC Pattern Implementation

#### Application-Level BLoCs

1. **AppBloc** (`lib/app/bloc/app_bloc.dart`)
   - Manages app-wide state (authentication, user, onboarding)
   - Emits `AppStatus`: `authenticated`, `unauthenticated`, `onboardingRequired`
   - Tracks app open count for login overlay
   - Listens to user stream changes

2. **AnalyticsBloc** (`lib/analytics/bloc/analytics_bloc.dart`)
   - Tracks user analytics events
   - Sets user ID when user logs in
   - Integrates with Firebase Analytics

3. **ThemeModeBloc** (`lib/theme_selector/bloc/`)
   - Manages light/dark theme selection

4. **LoginWithEmailLinkBloc** (`lib/login/bloc/login_with_email_link_bloc.dart`)
   - Handles email link authentication flow
   - Listens to deep links for magic link login

#### Feature-Level BLoCs (HydratedBloc)

1. **FeedBloc** (`lib/feed/bloc/feed_bloc.dart`)
   - HydratedBloc: Persists feed state
   - Manages news feed by category
   - Pagination support (offset-based)
   - Events: `FeedRequested`, `FeedRefreshRequested`, `FeedResumed`

2. **ArticleBloc** (`lib/article/bloc/article_bloc.dart`)
   - HydratedBloc with articleId as identifier
   - Tracks article views and limits (4 views/day)
   - Manages related articles
   - Ad display logic (interstitial every 4 article opens)
   - Article content pagination

3. **CategoriesBloc** (`lib/categories/bloc/categories_bloc.dart`)
   - HydratedBloc: Persists selected category
   - Fetches available news categories

4. **SearchBloc** (`lib/search/bloc/search_bloc.dart`)
   - Handles popular and relevant search
   - Debounce transformer (300ms) for search input

5. **NewsletterBloc** (`lib/newsletter/bloc/newsletter_bloc.dart`)
   - Newsletter subscription management

6. **NotificationPreferencesBloc** (`lib/notification_preferences/bloc/`)
   - Category-based notification preferences

7. **OnboardingBloc** (`lib/onboarding/bloc/onboarding_bloc.dart`)
   - Ad consent tracking
   - Notification permission handling

8. **SubscriptionsBloc** (`lib/subscriptions/`)
   - In-app purchase subscription management

9. **UserProfileBloc** (`lib/user_profile/bloc/`)
   - User profile data management

10. **LoginBloc** (`lib/login/bloc/login_bloc.dart`)
    - Email validation
    - Social login handlers (Google, Apple, Twitter, Facebook)
    - Email link login

11. **FullScreenAdsBloc** (`lib/ads/bloc/full_screen_ads_bloc.dart`)
    - Loads and shows interstitial and rewarded ads
    - Retry policy with exponential backoff
    - Ad pre-loading for smooth UX

#### HomeCubit
- Simple cubit for home page state management

---

## 4. Data Flow & Repositories

### Repository Pattern

Each repository provides abstraction over data sources:

#### UserRepository (`packages/user_repository/`)
**Purpose**: Manages user authentication and profile
- **Data Sources**: 
  - AuthenticationClient (Firebase)
  - DemoNewsApiClient (HTTP)
  - UserStorage (SharedPreferences)
  - DeepLinkService (Dynamic links)

- **Key Methods**:
  - `logInWithApple()`, `logInWithGoogle()`, `logInWithTwitter()`, `logInWithFacebook()`
  - `sendLoginEmailLink()`, `logInWithEmailLink()`
  - `logOut()`, `deleteAccount()`
  - `fetchAppOpenedCount()`, `incrementAppOpenedCount()`
  - `updateSubscriptionPlan()`

- **User Stream**: Combines auth state + subscription plan

#### NewsRepository (`packages/news_repository/`)
**Purpose**: Fetches and manages news content
- **Data Sources**: DemoNewsApiClient (HTTP)

- **Key Methods**:
  - `getFeed(category?, limit?, offset?)` - Paginated news feed
  - `getCategories()` - Available categories
  - `popularSearch()` - Trending articles
  - `relevantSearch(term)` - Search results
  - `subscribeToNewsletter(email)`

#### ArticleRepository (`packages/article_repository/`)
**Purpose**: Article content and view tracking
- **Storage**: ArticleStorage (SharedPreferences)
- **Key Methods**:
  - `getArticle(id, limit?, offset?)` - Article content with pagination
  - `getRelatedArticles(id, limit?)` - Related content
  - Article view counters: `incrementArticleViews()`, `resetArticleViews()`, `decrementArticleViews()`
  - Total views tracking for ad frequency

#### NotificationsRepository (`packages/notifications_repository/`)
**Purpose**: Push notifications and preferences
- **Data Sources**: NotificationsClient, PermissionClient, DemoNewsApiClient
- **Key Methods**:
  - `toggleNotifications(enable)` - Enable/disable notifications
  - `fetchNotificationsEnabled()` - Check status
  - `setCategoriesPreferences()` - Category subscription
  - `fetchCategoriesPreferences()` - Get preferences
  - Auto-initializes category preferences on creation

#### InAppPurchaseRepository (`packages/in_app_purchase_repository/`)
**Purpose**: Subscription and purchase management
- **Data Sources**: In-app purchase client, DemoNewsApiClient
- **Key Methods**:
  - `fetchSubscriptions()` - Available subscriptions
  - `queryProductDetails()` - Product details
  - `purchase(productId)` - Purchase flow
  - `deliverPurchase(purchaseDetails)` - Server-side validation

#### AnalyticsRepository (`packages/analytics_repository/`)
**Purpose**: Event tracking and analytics
- **Data Source**: Firebase Analytics
- **Key Methods**:
  - `track(event)` - Log custom events
  - `setUserId(userId)` - Identify user

### Data Flow Example: Article Reading

```
ArticleBloc receives ArticleRequested
    ↓
Calls ArticleRepository.getArticle(id)
    ↓
ArticleRepository calls DemoNewsApiClient.getArticle(id)
    ↓
API response → ArticleResponse model (JSON deserialized)
    ↓
ArticleBloc emits ArticleState with content
    ↓
UI renders article content blocks
    ↓
ArticleBloc tracks view count via ArticleRepository
    ↓
FullScreenAdsBloc may show interstitial based on view count
    ↓
AnalyticsBloc tracks article view event
```

---

## 5. Authentication & User Management

### Multi-Provider Authentication

**Supported Methods:**
1. **Email/Password** → Magic Link Flow
   - `sendLoginEmailLink(email)` - Firebase sends email
   - Deep links to app with magic link
   - `logInWithEmailLink(email, link)` - Firebase authenticates

2. **Social Logins** → OAuth Providers
   - **Google**: `GoogleSignIn` package
   - **Apple**: `sign_in_with_apple` package
   - **Facebook**: `flutter_facebook_auth` package
   - **Twitter**: Custom OAuth via `twitter_login` package

### Authentication Flow

```
LoginPage
    ↓
LoginBloc (multiple submit handlers)
    ├→ _onGoogleSubmitted() → UserRepository.logInWithGoogle()
    ├→ _onAppleSubmitted() → UserRepository.logInWithApple()
    ├→ _onFacebookSubmitted() → UserRepository.logInWithFacebook()
    ├→ _onTwitterSubmitted() → UserRepository.logInWithTwitter()
    └→ _onSendEmailLinkSubmitted() → UserRepository.sendLoginEmailLink()
    
UserRepository delegates to FirebaseAuthenticationClient
    ↓
FirebaseAuth updates auth state
    ↓
AppBloc listens to user stream changes
    ↓
Route to authenticated flow or onboarding
```

### Token Management

- **InMemoryTokenStorage**: Development use
- Tokens passed via Authorization header
- `TokenStorage` interface for abstraction
- Firebase Auth manages tokens automatically

### Appwrite Integration (Experimental)

- Located in `lib/login/appwrite/appwrite_login.dart`
- Provides alternative auth backend
- Methods: `login()`, `register()`, `logout()`
- Uses Appwrite Account API
- Configured with endpoint: `https://sfo.cloud.appwrite.io/v1`
- Project ID: `6911690b003198add805`

---

## 6. Network & API Layer

### DemoNewsApiClient (`api/lib/src/client/demo_news_api_client.dart`)

**HTTP Client Architecture**:
- Base URL: Production or localhost (development)
- Token provider pattern for dynamic token injection
- Bearer token authentication
- JSON request/response handling

**Endpoints**:

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/v1/articles/{id}` | Get article content |
| GET | `/api/v1/articles/{id}/related` | Related articles |
| GET | `/api/v1/feed` | News feed (paginated) |
| GET | `/api/v1/categories` | Available categories |
| GET | `/api/v1/users/me` | Current user + subscription |
| GET | `/api/v1/search/popular` | Trending content |
| GET | `/api/v1/search/relevant?q=term` | Search by term |
| POST | `/api/v1/newsletter/subscription` | Newsletter signup |
| POST | `/api/v1/subscriptions` | Create subscription |
| GET | `/api/v1/subscriptions` | List subscriptions |

**Request/Response Models** (`api/lib/src/models/`):
- `ArticleResponse` - Article content + metadata
- `FeedResponse` - List of articles with total count
- `CategoriesResponse` - Available categories
- `PopularSearchResponse` - Trending articles
- `RelevantSearchResponse` - Search results
- `CurrentUserResponse` - User + subscription info
- `SubscriptionsResponse` - Available subscriptions

**Error Handling**:
- `DemoNewsApiRequestFailure` - HTTP errors (statusCode + body)
- `DemoNewsApiMalformedResponse` - JSON parsing errors
- Custom failure types per repository operation

---

## 7. Storage & State Persistence

### Storage Hierarchy

```
SharedPreferences (Native Platform)
    ↓
PersistentStorage (Wrapper)
    ↓
Specific Storage Classes
    ├── UserStorage (app opens, user data)
    ├── ArticleStorage (article views)
    ├── NotificationsStorage (preferences)
    └── HydratedBloc (automatic state persistence)
```

### HydratedBloc Usage

**Automatic Serialization**:
```dart
class FeedBloc extends HydratedBloc<FeedEvent, FeedState> {
  @override
  FeedState? fromJson(Map<String, dynamic> json) => FeedState.fromJson(json);
  
  @override
  Map<String, dynamic>? toJson(FeedState state) => state.toJson();
}
```

**Affected Blocs**:
- FeedBloc - persists feed by category
- ArticleBloc - persists article state with ID
- CategoriesBloc - persists selected category

**Storage Location**: `getApplicationSupportDirectory()` via `path_provider`

**Development Mode**: Storage cleared on app start (for testing)

---

## 8. Ad Implementation

### Google Mobile Ads Integration

#### FullScreenAdsBloc (`lib/ads/bloc/full_screen_ads_bloc.dart`)

**Ad Types**:
1. **Interstitial Ads**: Full-screen ads between articles
2. **Rewarded Ads**: Give free article view on watch completion

**Configuration**:
```dart
FullScreenAdsConfig {
  interstitialAdUnitId: ?String
  rewardedAdUnitId: ?String
  // Falls back to test IDs if not provided
}
```

**Ad Loading Strategy**:
- Pre-load ads in app startup
- Retry policy with exponential backoff (3 retries)
- Platform-specific test ad IDs

**Interstitial Ad Frequency**:
- Shows every 4 article opens (configurable)
- Tracked via `ArticleBloc`

**Rewarded Ad Integration**:
- User watches ad to unlock article view
- Decrements article view count
- Only when user hits 4-view limit

**Events**:
- `LoadInterstitialAdRequested()` - Pre-load
- `LoadRewardedAdRequested()` - Pre-load
- `ShowInterstitialAdRequested()` - Display
- `ShowRewardedAdRequested()` - Display with callback
- `EarnedReward(reward)` - User watched to completion

### Ad Consent Management

**AdsConsentClient** (`packages/ads_consent_client/`)
- Google Consent Management Platform (CMP)
- Requested during onboarding
- GDPR/CCPA compliance

---

## 9. Navigation Structure

### Routing Architecture

**Flow**:
```
AppBloc State (AppStatus)
    ↓
FlowBuilder switches route
    ├→ unauthenticated/authenticated → HomePage
    └→ onboardingRequired → OnboardingPage

HomePage
    ├→ CategoriesBloc (fetch categories)
    ├→ FeedBloc (fetch news feed)
    └→ BottomNavigationBar
        ├── Feed Tab → FeedPage
        ├── Search Tab → SearchPage
        ├── Newsletter Tab → NewsletterPage
        └── Profile Tab → UserProfilePage

ArticleView (from feed) → ArticlePage
```

**Key Route Generators**:
- `onGenerateAppViewPages()` - Main app routes based on AppStatus
- Flow Builder from `flow_builder` package
- Automatic page transition management

**Navigation Components**:
- NavigationView - Bottom navigation structure
- Deep linking support via `deep_link_client`
- Dynamic link handling for authentication

---

## 10. Notifications

### Push Notification System

**Components**:
- **NotificationsClient**: Firebase Messaging abstraction
- **NotificationsRepository**: Preferences & permission management
- **NotificationsBloc**: (Not shown, but referenced)

**Permission Handling**:
```dart
PermissionClient.requestNotificationPermission()
    ↓
Platform-specific dialog (iOS/Android)
    ↓
User grants/denies
    ↓
NotificationsRepository.toggleNotifications(enable: true/false)
```

**Category-Based Subscriptions**:
```dart
NotificationsRepository.setCategoriesPreferences({
  Category.technology: true,
  Category.business: false,
  // ...
})
```

**Auto-Subscription**:
- Subscribes to topics matching user preferences
- Unsubscribes from disabled categories
- Syncs on preference changes

---

## 11. In-App Purchases & Subscriptions

### Purchase Flow

**SubscriptionsPage** displays available plans:

```
QueryProductDetails (from App Store/Play Store)
    ↓
Display SKUs with pricing
    ↓
User taps purchase
    ↓
PurchaseClient.buyNonConsumable(productId)
    ↓
Platform payment dialog
    ↓
InAppPurchaseRepository.deliverPurchase()
    ↓
Server-side validation via DemoNewsApiClient.createSubscription()
    ↓
AppBloc updates user.subscriptionPlan
```

**Subscription Plans**:
- Enum: `SubscriptionPlan.none`, `.monthly`, `.yearly`, etc.
- Stored in `User.subscriptionPlan`
- Checked in `ArticleBloc` for view limits

**Server Integration**:
```dart
// After successful purchase
await apiClient.createSubscription(subscriptionId: purchaseId)
```

---

## 12. Analytics Tracking

### Firebase Analytics Events

**Integrated Points**:
- User login/logout
- Article views
- Search queries
- Category selection
- Purchase completion
- Ad impressions

**AnalyticsBloc**:
```dart
class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  on<TrackAnalyticsEvent>(_onTrackAnalyticsEvent);
  // Sets user ID when logged in
  _setUserId(user.id)
}
```

**AppBlocObserver**:
- Logs all BLoC transitions for debugging
- Integrates with AnalyticsBloc

---

## 13. Key Features & Implementation

### 1. News Feed
- **BLoC**: FeedBloc
- **Pagination**: Offset-based, loads 10+ articles
- **Categories**: Multi-category support
- **Refresh**: Pull-to-refresh support
- **Persistence**: HydratedBloc state saved

### 2. Article Reading
- **Content Pagination**: Load blocks progressively
- **View Tracking**: Daily limit (4 free views)
- **Related Articles**: Shown after main content
- **Sharing**: Share button with launcher
- **Comments**: Placeholder (not implemented)

### 3. Search
- **Popular**: Trending content on open
- **Relevant**: Search by term with debounce (300ms)
- **Results**: Articles and topics returned

### 4. Authentication
- **Methods**: Email link, Google, Apple, Facebook, Twitter
- **Onboarding**: Required for new users
- **App Open Tracking**: Shows login overlay after 5 opens
- **Deep Links**: Magic link via Firebase Dynamic Links (deprecated, but stub exists)

### 5. Subscriptions
- **In-App Purchases**: Monthly/yearly plans
- **Article Limits**: 4 free views/day, unlimited with subscription
- **Reward Videos**: Watch ad to get extra view
- **Verification**: Server-side validation

### 6. Notifications
- **Permission Gating**: Request on onboarding
- **Category Preferences**: Per-category opt-in
- **Topic Subscription**: Firebase Messaging topics
- **Manual Control**: Toggle in settings

### 7. User Profile
- **Data**: User email, name, subscription status
- **Actions**: Delete account, logout
- **Settings**: Notification preferences, theme

---

## 14. Testing & Code Generation

### Code Generation
- **build_runner**: Generates serialization code
- **json_serializable**: Auto JSON converters
- **hydrated_bloc**: Generates `fromJson`/`toJson` methods
- **l10n**: Auto-generates localization classes

### Testing
- **mocktail**: Mocking for BLoCs
- **bloc_test**: BLoC testing utilities
- **fake_async**: Time manipulation in tests

---

## 15. External Integrations

### Firebase
- **Firebase Auth**: OAuth + email authentication
- **Firebase Messaging**: Push notifications
- **Firebase Analytics**: Event tracking
- **Firebase Crashlytics**: Error reporting
- **Firebase Dynamic Links**: Deprecated, replaced by deep links

### Third-Party Services
- **Google Sign-In**: OAuth provider
- **Sign in with Apple**: OAuth provider
- **Facebook Auth**: OAuth provider
- **Twitter Login**: OAuth provider
- **Google Mobile Ads**: Ads network
- **Appwrite**: Backend-as-a-service (experimental)

### Localization
- **intl**: Internationalization
- **flutter_localizations**: Built-in translations
- **ARB files**: (`lib/l10n/arb/`) for translations

---

## 16. Environment Configuration

### Build Variants
- **Development**: `main_development.dart`
  - Uses localhost API: `http://localhost:8080`
  - Package: `com.demo.news.dev`
  - Clears HydratedBloc storage on start
- **Production**: `main_production.dart`
  - Uses production API: `https://...`
  - Package: `com.demo.news`

### Configuration Files
- `pubspec.yaml` - Dependencies and metadata
- `analysis_options.yaml` - Lint rules (very_good_analysis)
- `l10n.yaml` - Localization config
- `build.yaml` - Build configuration
- `codemagic.yaml` - CI/CD pipeline

---

## 17. UI/Theming

### App UI Package
- **app_ui**: Custom theme, colors, typography
- **news_blocks_ui**: Reusable article block components
- **AppTheme**: Light theme
- **AppDarkTheme**: Dark theme
- **ThemeModeBloc**: Theme switching

### UI Components
- **NewsBlocks**: Serializable content blocks
  - `PostLargeBlock`, `PostMediumBlock`, `PostSmallBlock`
  - `TextHeadlineBlock`, `TextParagraphBlock`
  - `BannerAdBlock`, `SectionHeaderBlock`
  - `UnknownBlock` (fallback)

---

## 18. Error Handling

### Failure Classes Hierarchy
```
Failure (Interface)
    ├── UserFailure
    ├── NewsFailure
    ├── ArticleFailure
    ├── NotificationsFailure
    ├── InAppPurchaseFailure
    ├── AuthenticationException
    └── DemoNewsApiRequestFailure
```

### Error Recovery
- **Retry Policies**: Exponential backoff in FullScreenAdsBloc
- **Network Errors**: Graceful fallback UI
- **State Recovery**: HydratedBloc restores last valid state

---

## 19. Performance & Optimization

### Lazy Loading
- BLoCs created with `lazy: false` only when needed
- Feed pagination prevents loading entire feed at once
- Article content loaded in blocks

### State Caching
- HydratedBloc caches state locally
- Feed categorized by type (technology, business, etc.)
- Subscription plan cached in user stream

### Memory Management
- Stream subscriptions properly closed
- BLoCs dispose resources in `close()`
- Article viewers unique per ID (HydratedBloc isolation)

---

## 20. Key Dependencies & Versions

```
Core Framework:
  flutter: 3.24.2
  dart: >=3.5.0 <4.0.0

State Management:
  bloc: ^8.1.0
  flutter_bloc: ^8.0.1
  hydrated_bloc: ^9.0.0
  flow_builder: ^0.0.7

Authentication:
  firebase_auth: ^6.1.2
  google_sign_in
  sign_in_with_apple
  flutter_facebook_auth
  twitter_login

Networking & API:
  http (via DemoNewsApiClient)
  appwrite: ^17.0.0

Analytics & Notifications:
  firebase_analytics: ^12.0.4
  firebase_messaging: ^16.0.4
  firebase_crashlytics: ^5.0.4

Ads:
  google_mobile_ads: ^5.0.0

Storage:
  shared_preferences: ^2.0.15
  path_provider: ^2.1.4

UI:
  flutter_svg: ^2.0.5
  font_awesome_flutter: ^10.1.0
  visibility_detector: ^0.4.0+2

Utilities:
  equatable: ^2.0.3
  collection: ^1.16.0
  intl: ^0.19.0
  clock: ^1.1.0
```

---

## Summary

This is a **production-grade Flutter news application** with:

1. **Clean Architecture**: Separated into layers (UI → BLoC → Repository → Data)
2. **Multi-Package Structure**: Modular, testable, reusable packages
3. **Comprehensive Authentication**: Multiple OAuth providers + email links
4. **Monetization**: In-app purchases with server validation + rewarded ads
5. **User Engagement**: Push notifications, analytics, consent management
6. **State Management**: BLoC with persistence via HydratedBloc
7. **API Integration**: Custom REST client with token management
8. **Platform Support**: iOS/Android with platform-specific optimizations
9. **Internationalization**: Multi-language support via ARB files
10. **Error Handling**: Comprehensive failure types and recovery strategies

The app demonstrates best practices for Flutter development including proper separation of concerns, dependency injection, stream management, and platform integration.
