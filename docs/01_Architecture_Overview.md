# Flutter News App - Architecture Overview

## Table of Contents
- [Introduction](#introduction)
- [High-Level Architecture](#high-level-architecture)
- [Project Structure](#project-structure)
- [Architecture Patterns](#architecture-patterns)
- [Technology Stack](#technology-stack)
- [Module Dependencies](#module-dependencies)

## Introduction

This is a production-grade Flutter news application built with clean architecture principles. The app provides news content delivery, multi-provider authentication, subscription management, and ad monetization.

**Key Characteristics:**
- Multi-package modular architecture
- BLoC pattern for state management
- Repository pattern for data abstraction
- Clean separation of concerns
- Platform support: iOS & Android

## High-Level Architecture

```mermaid
graph TB
    subgraph "Presentation Layer"
        UI[Flutter UI Widgets]
        Pages[Feature Pages]
    end

    subgraph "Business Logic Layer"
        BLoC[BLoC Components]
        Events[Events]
        States[States]
    end

    subgraph "Data Layer"
        Repos[Repositories]
        Clients[Client Abstractions]
    end

    subgraph "External Services"
        API[Demo News API]
        Firebase[Firebase Services]
        GoogleAds[Google Mobile Ads]
        Appwrite[Appwrite Backend]
    end

    subgraph "Local Storage"
        SharedPrefs[SharedPreferences]
        HydratedStorage[Hydrated Storage]
    end

    UI --> BLoC
    Pages --> BLoC
    BLoC --> Events
    Events --> States
    BLoC --> Repos
    Repos --> Clients
    Clients --> API
    Clients --> Firebase
    Clients --> GoogleAds
    Clients --> Appwrite
    BLoC --> HydratedStorage
    Repos --> SharedPrefs

    style UI fill:#e1f5ff
    style BLoC fill:#fff4e1
    style Repos fill:#e8f5e9
    style API fill:#fce4ec
    style Firebase fill:#fce4ec
```

## Clean Architecture Layers

```mermaid
graph LR
    subgraph "UI Layer"
        A[Widgets & Pages]
    end

    subgraph "Presentation Logic"
        B[BLoC/Cubit]
    end

    subgraph "Domain Layer"
        C[Repositories]
        D[Models]
    end

    subgraph "Data Layer"
        E[API Clients]
        F[Storage]
    end

    subgraph "External"
        G[REST API]
        H[Firebase]
        I[Third-Party SDKs]
    end

    A --> B
    B --> C
    C --> D
    C --> E
    C --> F
    E --> G
    E --> H
    E --> I

    style A fill:#bbdefb
    style B fill:#fff9c4
    style C fill:#c8e6c9
    style E fill:#ffccbc
    style G fill:#f8bbd0
```

## Project Structure

```mermaid
graph TB
    Root[demo_news/]

    Root --> Lib[lib/]
    Root --> Packages[packages/]
    Root --> API[api/]
    Root --> Platform[Platform Code]

    Lib --> Features[25 Feature Modules]
    Lib --> Main[main/]

    Features --> Feed[feed/]
    Features --> Article[article/]
    Features --> Login[login/]
    Features --> Subscriptions[subscriptions/]
    Features --> More[... 21 more]

    Packages --> Repos[6 Repositories]
    Packages --> UIPackages[UI Packages]
    Packages --> Clients[Client Abstractions]

    Repos --> UserRepo[user_repository]
    Repos --> NewsRepo[news_repository]
    Repos --> ArticleRepo[article_repository]
    Repos --> NotifRepo[notifications_repository]
    Repos --> PurchaseRepo[in_app_purchase_repository]
    Repos --> AnalyticsRepo[analytics_repository]

    API --> APIClient[demo_news_api_client]
    API --> Models[Data Models]
    API --> NewsBlocks[news_blocks]

    Platform --> Android[android/]
    Platform --> iOS[ios/]

    style Root fill:#e3f2fd
    style Lib fill:#fff3e0
    style Packages fill:#e8f5e9
    style API fill:#fce4ec
```

## Directory Organization

```
demo_news/
├── lib/                          # Main application code
│   ├── ads/                      # Ad management
│   ├── analytics/                # Analytics tracking
│   ├── app/                      # App-level BLoC
│   ├── article/                  # Article viewing
│   ├── categories/               # Category management
│   ├── feed/                     # News feed
│   ├── home/                     # Home navigation
│   ├── login/                    # Authentication
│   ├── main/                     # Entry points
│   ├── navigation/               # Navigation structure
│   ├── notification_preferences/ # Push notification settings
│   ├── onboarding/               # First-time UX
│   ├── search/                   # Search functionality
│   ├── subscriptions/            # In-app purchases
│   ├── theme_selector/           # Theme switching
│   └── user_profile/             # User profile
│
├── packages/                     # Shared packages (22 total)
│   ├── analytics_repository/     # Analytics abstraction
│   ├── article_repository/       # Article data
│   ├── authentication_client/    # Auth abstraction
│   ├── in_app_purchase_repository/ # IAP management
│   ├── news_repository/          # News data
│   ├── notifications_repository/ # Notification management
│   ├── user_repository/          # User data
│   ├── app_ui/                   # UI components
│   ├── news_blocks_ui/           # News content blocks
│   └── storage/                  # Storage abstraction
│
├── api/                          # Backend API layer
│   ├── lib/src/
│   │   ├── client/               # HTTP client
│   │   ├── models/               # Response DTOs
│   │   └── middleware/           # Request interceptors
│   └── packages/news_blocks/     # Content block types
│
├── android/                      # Android platform
├── ios/                          # iOS platform
└── test/                         # Unit & widget tests
```

## Architecture Patterns

### 1. BLoC Pattern (Business Logic Component)

```mermaid
sequenceDiagram
    participant UI
    participant BLoC
    participant Repository
    participant API

    UI->>BLoC: Dispatch Event
    activate BLoC
    BLoC->>BLoC: Handle Event
    BLoC->>Repository: Request Data
    activate Repository
    Repository->>API: HTTP Request
    activate API
    API-->>Repository: Response
    deactivate API
    Repository-->>BLoC: Domain Model
    deactivate Repository
    BLoC->>BLoC: Transform to State
    BLoC-->>UI: Emit State
    deactivate BLoC
    UI->>UI: Rebuild Widget
```

**Key BLoCs in the App:**
- **AppBloc** - App-wide authentication state
- **FeedBloc** - News feed management
- **ArticleBloc** - Article viewing & tracking
- **LoginBloc** - Authentication flows
- **SubscriptionsBloc** - Purchase management
- **FullScreenAdsBloc** - Ad loading & display
- **CategoriesBloc** - Category management
- **SearchBloc** - Search functionality
- **NotificationPreferencesBloc** - Notification settings
- **NewsletterBloc** - Newsletter subscription
- **UserProfileBloc** - User profile management

### 2. Repository Pattern

```mermaid
graph LR
    subgraph "BLoC Layer"
        B[BLoC]
    end

    subgraph "Repository"
        R[Repository Interface]
        R --> Cache[Local Cache]
        R --> Remote[Remote Data]
        R --> Storage[Persistent Storage]
    end

    subgraph "Data Sources"
        API[REST API]
        Firebase[Firebase]
        SharedPrefs[SharedPreferences]
    end

    B --> R
    Remote --> API
    Remote --> Firebase
    Storage --> SharedPrefs

    style B fill:#fff9c4
    style R fill:#c8e6c9
    style API fill:#ffccbc
```

**Repository Responsibilities:**
- Abstract data sources from business logic
- Handle data transformation (DTO → Domain Model)
- Implement caching strategies
- Manage error handling
- Provide stream-based APIs

### 3. Dependency Injection

```mermaid
graph TB
    Main[main.dart]
    Main --> Bootstrap[bootstrap.dart]
    Bootstrap --> MultiRepoProvider[MultiRepositoryProvider]

    MultiRepoProvider --> UserRepo[UserRepository]
    MultiRepoProvider --> NewsRepo[NewsRepository]
    MultiRepoProvider --> ArticleRepo[ArticleRepository]
    MultiRepoProvider --> NotifRepo[NotificationsRepository]
    MultiRepoProvider --> PurchaseRepo[InAppPurchaseRepository]
    MultiRepoProvider --> AnalyticsRepo[AnalyticsRepository]

    UserRepo --> AuthClient[AuthenticationClient]
    UserRepo --> APIClient[DemoNewsApiClient]
    UserRepo --> UserStorage[UserStorage]

    NewsRepo --> APIClient2[DemoNewsApiClient]
    ArticleRepo --> APIClient3[DemoNewsApiClient]

    style Main fill:#e1f5ff
    style MultiRepoProvider fill:#fff9c4
    style UserRepo fill:#c8e6c9
```

## Technology Stack

### Core Framework
```yaml
Flutter: 3.24.2
Dart: >=3.5.0 <4.0.0
```

### State Management
- **bloc**: ^8.1.0 - Core BLoC library
- **flutter_bloc**: ^8.0.1 - Flutter widgets for BLoC
- **hydrated_bloc**: ^9.0.0 - Persistent state management
- **flow_builder**: ^0.0.7 - Navigation flow management

### Authentication
- **firebase_auth**: ^6.1.2 - Firebase authentication
- **google_sign_in** - Google OAuth
- **sign_in_with_apple** - Apple ID authentication
- **flutter_facebook_auth** - Facebook OAuth
- **twitter_login** - Twitter OAuth
- **appwrite**: 17.0.0 - Alternative backend (experimental)

### Networking
- **http** - HTTP client (via demo_news_api)
- Custom REST client implementation

### Analytics & Monitoring
- **firebase_analytics**: ^12.0.4 - Event tracking
- **firebase_crashlytics**: ^5.0.4 - Crash reporting
- **firebase_messaging**: ^16.0.4 - Push notifications

### Monetization
- **google_mobile_ads**: ^5.0.0 - Interstitial & rewarded ads
- **in_app_purchase** - Subscription purchases

### Storage
- **shared_preferences**: ^2.0.15 - Key-value storage
- **path_provider**: ^2.1.4 - File system paths

### UI Components
- **flutter_svg**: ^2.0.5 - SVG rendering
- **font_awesome_flutter**: ^10.1.0 - Icon library
- **visibility_detector**: ^0.4.0+2 - Visibility tracking

### Utilities
- **equatable**: ^2.0.3 - Value equality
- **collection**: ^1.16.0 - Collection utilities
- **intl**: ^0.19.0 - Internationalization
- **clock**: ^1.1.0 - Time manipulation

## Module Dependencies

```mermaid
graph TD
    subgraph "App Features"
        Feed[Feed]
        Article[Article]
        Login[Login]
        Subscriptions[Subscriptions]
    end

    subgraph "Repositories"
        NewsRepo[NewsRepository]
        ArticleRepo[ArticleRepository]
        UserRepo[UserRepository]
        PurchaseRepo[InAppPurchaseRepository]
    end

    subgraph "Clients"
        APIClient[DemoNewsApiClient]
        AuthClient[AuthenticationClient]
        NotifClient[NotificationsClient]
    end

    subgraph "External"
        Firebase[Firebase Services]
        GoogleAds[Google Ads]
        NewsAPI[News API Backend]
    end

    Feed --> NewsRepo
    Article --> ArticleRepo
    Login --> UserRepo
    Subscriptions --> PurchaseRepo

    NewsRepo --> APIClient
    ArticleRepo --> APIClient
    UserRepo --> APIClient
    UserRepo --> AuthClient
    PurchaseRepo --> APIClient

    APIClient --> NewsAPI
    AuthClient --> Firebase
    NotifClient --> Firebase

    style Feed fill:#e1f5ff
    style NewsRepo fill:#c8e6c9
    style APIClient fill:#ffccbc
    style Firebase fill:#f8bbd0
```

## Data Flow Architecture

```mermaid
graph TB
    User[User Interaction]

    subgraph "Presentation"
        Widget[Widget]
        Builder[BlocBuilder/Listener]
    end

    subgraph "Business Logic"
        BLoC[BLoC]
        Event[Event]
        State[State]
    end

    subgraph "Domain"
        Repository[Repository]
        Model[Domain Model]
    end

    subgraph "Data"
        Client[API Client]
        DTO[Response DTO]
        Storage[Local Storage]
    end

    User --> Widget
    Widget --> Event
    Event --> BLoC
    BLoC --> Repository
    Repository --> Client
    Client --> DTO
    DTO --> Model
    Model --> State
    State --> Builder
    Builder --> Widget

    Repository --> Storage
    Storage --> Model

    style User fill:#e1f5ff
    style BLoC fill:#fff9c4
    style Repository fill:#c8e6c9
    style Client fill:#ffccbc
```

## Build Variants

### Development Build
```dart
// main_development.dart
- Base URL: http://localhost:8080
- Package: com.demo.news.dev
- Clears storage on startup
- Debug logging enabled
```

### Production Build
```dart
// main_production.dart
- Base URL: Production API
- Package: com.demo.news
- Persistent storage
- Error reporting enabled
```

## Key Design Principles

1. **Separation of Concerns**: Each layer has a single responsibility
2. **Dependency Inversion**: High-level modules don't depend on low-level modules
3. **Abstraction**: Repositories and clients provide abstract interfaces
4. **Immutability**: BLoC states are immutable using Equatable
5. **Reactive Programming**: Stream-based data flow throughout the app
6. **Testability**: Clear boundaries enable comprehensive unit testing
7. **Modularity**: Shared packages can be reused across projects

## Summary

This Flutter news app demonstrates enterprise-grade architecture with:
- **25 feature modules** for organized functionality
- **11 BLoCs + 1 Cubit** managing different aspects of the app
- **6 core repositories** abstracting data operations
- **22 shared packages** promoting code reuse
- **Clean architecture** with clear layer separation
- **Multi-provider authentication** supporting 5 login methods
- **Comprehensive state management** with persistence
- **Production-ready** monetization and analytics

The architecture enables scalability, maintainability, and testability while following Flutter and Dart best practices.
