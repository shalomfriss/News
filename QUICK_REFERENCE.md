# Flutter News App - Quick Reference Guide

## Key Files by Purpose

### App Entry Points
- `/lib/main/main_development.dart` - Dev environment (localhost API)
- `/lib/main/main_production.dart` - Production environment
- `/lib/main/bootstrap/bootstrap.dart` - Initialization & Firebase setup

### Core Architecture
- `/lib/app/bloc/app_bloc.dart` - App-wide state (auth, user, onboarding)
- `/lib/app/routes/routes.dart` - Page routing based on AppStatus
- `/lib/home/view/home_page.dart` - Main navigation hub

### State Management (BLoCs)
| BLoC | Location | Purpose |
|------|----------|---------|
| AppBloc | `lib/app/bloc/` | Authentication & app lifecycle |
| FeedBloc | `lib/feed/bloc/` | News feed (with HydratedBloc) ~~|~~
| ArticleBloc | `lib/article/bloc/` | Article viewing & view limits |
| CategoriesBloc | `lib/categories/bloc/` | Category management |
| SearchBloc | `lib/search/bloc/` | Popular/relevant search |
| LoginBloc | `lib/login/bloc/` | Authentication forms |
| FullScreenAdsBloc | `lib/ads/bloc/` | Ad loading/display |
| AnalyticsBloc | `lib/analytics/bloc/` | Event tracking |
| OnboardingBloc | `lib/onboarding/bloc/` | First-time setup |
| SubscriptionsBloc | `lib/subscriptions/` | In-app purchases |

### Repositories (Data Layer)
| Repository | Location | Responsibility |
|------------|----------|-----------------|
| UserRepository | `packages/user_repository/` | Auth, user profile |
| NewsRepository | `packages/news_repository/` | News content |
| ArticleRepository | `packages/article_repository/` | Article detail & view tracking |
| NotificationsRepository | `packages/notifications_repository/` | Push notifications |
| InAppPurchaseRepository | `packages/in_app_purchase_repository/` | Subscriptions |
| AnalyticsRepository | `packages/analytics_repository/` | Analytics events |

### API & Networking
- `/api/lib/src/client/demo_news_api_client.dart` - REST client
- `/api/lib/src/models/` - Response DTOs (ArticleResponse, FeedResponse, etc.)
- **Token Management**: `/packages/authentication_client/token_storage/`

### Authentication
- `/packages/authentication_client/authentication_client/` - Auth interface
- `/packages/authentication_client/firebase_authentication_client/` - Firebase implementation
- `/lib/login/appwrite/appwrite_login.dart` - Appwrite backend (experimental)

### Storage
- `/packages/storage/persistent_storage/` - SharedPreferences wrapper
- **User Storage**: `UserStorage` (app opens, user cache)
- **Article Storage**: `ArticleStorage` (view counts)
- **Notifications Storage**: `NotificationsStorage` (preferences)
- **HydratedBloc**: Automatic state persistence

### UI & Themes
- `/packages/app_ui/` - Theme, colors, typography
- `/packages/news_blocks_ui/` - Article block components
- `/lib/theme_selector/` - Light/dark theme toggle

## Data Flow Examples

### 1. Article Reading Flow
```
User taps article in feed
  ↓
ArticleBloc.add(ArticleRequested())
  ↓
ArticleBloc calls ArticleRepository.getArticle(id)
  ↓
ArticleRepository calls DemoNewsApiClient.getArticle(id)
  ↓
API returns ArticleResponse
  ↓
ArticleBloc emits ArticleState with content blocks
  ↓
ArticleBloc.add(ArticleContentSeen()) tracks view
  ↓
If 4 views reached, shows rewarded ad option
  ↓
AnalyticsBloc tracks article view event
```

### 2. Login Flow
```
User enters email & taps "Send Link"
  ↓
LoginBloc.add(SendEmailLinkSubmitted())
  ↓
UserRepository.sendLoginEmailLink(email)
  ↓
FirebaseAuthenticationClient sends email via Firebase Auth
  ↓
User clicks email link (deep link)
  ↓
LoginWithEmailLinkBloc captures deep link
  ↓
UserRepository.logInWithEmailLink(email, link)
  ↓
FirebaseAuth authenticates
  ↓
AppBloc listens to auth state change
  ↓
Route to onboarding (if new) or home
```

### 3. In-App Purchase Flow
```
User views subscription plans in SubscriptionsPage
  ↓
InAppPurchaseRepository.queryProductDetails()
  ↓
Displays available SKUs and prices
  ↓
User taps "Buy"
  ↓
InAppPurchaseRepository.purchase(productId)
  ↓
Platform payment dialog (iOS/Android)
  ↓
After successful purchase:
  ↓
InAppPurchaseRepository.deliverPurchase()
  ↓
DemoNewsApiClient.createSubscription(transactionId)
  ↓
Server validates purchase
  ↓
UserRepository.updateSubscriptionPlan()
  ↓
AppBloc updates user.subscriptionPlan
  ↓
ArticleBloc removes view limit
```

## Configuration

### Environment Setup
```yaml
# Development
baseUrl: "http://localhost:8080"
package: "com.demo.news.dev"
firebase: Optional (graceful fallback)

# Production  
baseUrl: "https://"
package: "com.demo.news"
firebase: Required
```

### Firebase Configuration
- Firebase Auth (email, Google, Apple, Facebook, Twitter OAuth)
- Firebase Messaging (push notifications)
- Firebase Analytics (event tracking)
- Firebase Crashlytics (error reporting)

### Appwrite Configuration
- Endpoint: `https://sfo.cloud.appwrite.io/v1`
- Project ID: `6911690b003198add805`
- Provides backend for authentication & data (experimental)

## Dependencies Overview

### State Management
- `bloc: ^8.1.0` - BLoC pattern
- `flutter_bloc: ^8.0.1` - Flutter integration
- `hydrated_bloc: ^9.0.0` - Persistent state

### Authentication
- `firebase_auth: ^6.1.2` - Email/OAuth
- `google_sign_in` - Google OAuth
- `sign_in_with_apple` - Apple OAuth
- `flutter_facebook_auth` - Facebook OAuth
- `twitter_login` - Twitter OAuth

### API & Networking
- `http` - HTTP client
- `appwrite: ^17.0.0` - Backend-as-a-service

### Ads & Analytics
- `google_mobile_ads: ^5.0.0` - Google Ads
- `firebase_analytics: ^12.0.4` - Analytics
- `firebase_messaging: ^16.0.4` - Push notifications

### Storage
- `shared_preferences: ^2.0.15` - Key-value storage
- `path_provider: ^2.1.4` - Document directory access

### Utilities
- `equatable: ^2.0.3` - Value equality
- `json_annotation: ^4.9.0` - JSON serialization
- `intl: ^0.19.0` - Internationalization

## Important Constants

### View Limits
- **Free views/day**: 4
- **Reset duration**: 24 hours
- **Reward video views**: Decrements limit by 1

### Ad Frequency
- **Interstitial ads**: Every 4 article opens
- **Retry attempts**: 3 with exponential backoff

### Search
- **Debounce delay**: 300ms
- **Related articles**: 5 shown after main content

### App Engagement
- **Login overlay after**: 5 app opens (without login)

### API Pagination
- **Default limit**: 10 items
- **Offset-based**: Supports cursor pagination

## Testing Commands

```bash
# Run all tests
flutter test

# Generate code
dart run build_runner build --delete-conflicting-outputs

# Check analysis
flutter analyze

# Build for release
flutter build apk --release
flutter build ios --release
```

## Common Tasks

### Add New Feature
1. Create feature directory: `/lib/feature/`
2. Add BLoC: `/lib/feature/bloc/`
3. Add View: `/lib/feature/view/`
4. Create Repository in `/packages/` if needed
5. Add routes in `/lib/app/routes/routes.dart`

### Modify API
1. Update DemoNewsApiClient in `/api/lib/src/client/`
2. Update/add response models in `/api/lib/src/models/`
3. Update corresponding repository
4. Update BLoC to call new repository method

### Add Authentication Method
1. Add OAuth provider setup in FirebaseAuthenticationClient
2. Add LoginBloc event handler
3. Add UI in LoginPage

### Track New Analytics
1. Add event to AnalyticsBloc
2. Call `analyticsBloc.add(TrackAnalyticsEvent(event))`
3. Event logged to Firebase Analytics

## Debugging Tips

- **BLoC States**: Check `AppBlocObserver` logs
- **Network Errors**: Check `DemoNewsApiRequestFailure`
- **Storage Issues**: Check HydratedBloc storage in device files
- **Firebase**: Check Firebase Console for auth/analytics
- **Ads**: Use test ad IDs (provided in FullScreenAdsConfig)

## File Paths Quick Access

```
Main App:           /lib/app/
Authentication:     /lib/login/
News Feed:          /lib/feed/
Article Detail:     /lib/article/
Search:             /lib/search/
Subscriptions:      /lib/subscriptions/
Settings:           /lib/user_profile/
API Client:         /api/lib/src/client/
Repositories:       /packages/*/lib/src/
Models:             /api/lib/src/models/
Storage:            /packages/storage/
```

---

For detailed architecture overview, see: `/CODEBASE_OVERVIEW.md`
