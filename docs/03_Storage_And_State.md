# Storage & State Management

## Table of Contents
- [Overview](#overview)
- [Storage Architecture](#storage-architecture)
- [HydratedBloc Implementation](#hydratedbloc-implementation)
- [SharedPreferences Layer](#sharedpreferences-layer)
- [State Persistence](#state-persistence)
- [Storage Patterns](#storage-patterns)

## Overview

The app uses a multi-layered storage approach combining SharedPreferences for key-value storage and HydratedBloc for automatic state persistence. This ensures data persists across app restarts while maintaining clean architecture principles.

**Key Storage Components:**
- **SharedPreferences** - Native platform storage
- **PersistentStorage** - Abstraction wrapper
- **HydratedBloc** - Automatic state serialization
- **Storage Classes** - Domain-specific storage
- **path_provider** - File system paths

## Storage Architecture

```mermaid
graph TB
    subgraph "Application Layer"
        BLoC[BLoC Components]
        Repo[Repositories]
    end

    subgraph "Storage Abstraction"
        PersistentStorage[PersistentStorage]
        UserStorage[UserStorage]
        ArticleStorage[ArticleStorage]
        NotificationStorage[NotificationsStorage]
    end

    subgraph "Persistence Layer"
        HydratedStorage[HydratedBlocStorage]
        SharedPrefs[SharedPreferences]
    end

    subgraph "Platform"
        iOS[iOS UserDefaults]
        Android[Android SharedPreferences]
    end

    BLoC --> HydratedStorage
    Repo --> UserStorage
    Repo --> ArticleStorage
    Repo --> NotificationStorage

    UserStorage --> PersistentStorage
    ArticleStorage --> PersistentStorage
    NotificationStorage --> PersistentStorage

    PersistentStorage --> SharedPrefs
    HydratedStorage --> SharedPrefs

    SharedPrefs --> iOS
    SharedPrefs --> Android

    style BLoC fill:#fff9c4
    style PersistentStorage fill:#c8e6c9
    style SharedPrefs fill:#e1f5ff
    style iOS fill:#ffccbc
    style Android fill:#ffccbc
```

## Storage Hierarchy

```mermaid
graph LR
    subgraph "High-Level APIs"
        A[HydratedBloc]
        B[UserStorage]
        C[ArticleStorage]
        D[NotificationsStorage]
    end

    subgraph "Abstraction Layer"
        E[PersistentStorage]
    end

    subgraph "Low-Level"
        F[SharedPreferences]
    end

    subgraph "Native Platform"
        G[iOS/Android Storage]
    end

    A --> F
    B --> E
    C --> E
    D --> E
    E --> F
    F --> G

    style A fill:#fff9c4
    style E fill:#c8e6c9
    style F fill:#e1f5ff
    style G fill:#ffccbc
```

## HydratedBloc Implementation

### What is HydratedBloc?

HydratedBloc automatically persists and restores BLoC state across app sessions. It serializes state to JSON and stores it locally.

```mermaid
graph TD
    Start[App Launch] --> Check{Storage Exists?}
    Check -->|Yes| Load[Load Persisted State]
    Check -->|No| Init[Initialize Fresh State]

    Load --> Deserialize[fromJson]
    Deserialize --> Restore[Restore BLoC State]

    Init --> Fresh[Create Initial State]

    Restore --> Running[BLoC Running]
    Fresh --> Running

    Running --> StateChange[State Changes]
    StateChange --> Serialize[toJson]
    Serialize --> Save[Save to Storage]
    Save --> Running

    style Start fill:#e1f5ff
    style Load fill:#fff9c4
    style Serialize fill:#c8e6c9
    style Save fill:#a5d6a7
```

### HydratedBloc BLoCs in the App

```mermaid
graph TB
    subgraph "Persisted BLoCs"
        Feed[FeedBloc]
        Article[ArticleBloc]
        Categories[CategoriesBloc]
    end

    subgraph "Storage"
        Storage[HydratedStorage]
    end

    subgraph "Persisted Data"
        FeedData[News Feed by Category]
        ArticleData[Article Content + View Count]
        CategoriesData[Selected Categories]
    end

    Feed -.persists.-> FeedData
    Article -.persists.-> ArticleData
    Categories -.persists.-> CategoriesData

    FeedData --> Storage
    ArticleData --> Storage
    CategoriesData --> Storage

    style Feed fill:#fff9c4
    style Storage fill:#c8e6c9
```

### HydratedBloc Usage Example

#### FeedBloc Implementation

```dart
class FeedBloc extends HydratedBloc<FeedEvent, FeedState> {
  FeedBloc({
    required NewsRepository newsRepository,
  }) : _newsRepository = newsRepository,
       super(const FeedState.initial());

  final NewsRepository _newsRepository;

  // Serialize state to JSON
  @override
  Map<String, dynamic>? toJson(FeedState state) {
    return state.toJson();
  }

  // Deserialize JSON to state
  @override
  FeedState? fromJson(Map<String, dynamic> json) {
    return FeedState.fromJson(json);
  }
}
```

#### State Serialization Flow

```mermaid
sequenceDiagram
    participant BLoC
    participant HydratedBloc
    participant Storage
    participant JSON

    Note over BLoC: State Changes
    BLoC->>BLoC: emit(newState)
    BLoC->>HydratedBloc: toJson(state)
    activate HydratedBloc

    HydratedBloc->>JSON: state.toJson()
    activate JSON
    JSON-->>HydratedBloc: Map<String, dynamic>
    deactivate JSON

    HydratedBloc->>Storage: write(json)
    activate Storage
    Storage-->>HydratedBloc: Success
    deactivate Storage
    deactivate HydratedBloc

    Note over Storage: Data Persisted

    Note over BLoC: App Restart

    BLoC->>HydratedBloc: Initialize
    HydratedBloc->>Storage: read()
    activate Storage
    Storage-->>HydratedBloc: JSON data
    deactivate Storage

    HydratedBloc->>JSON: fromJson(data)
    activate JSON
    JSON-->>HydratedBloc: State object
    deactivate JSON

    HydratedBloc->>BLoC: Restore state
```

### ArticleBloc with ID-Based Storage

The ArticleBloc uses a unique identifier for each article to maintain separate persisted states.

```dart
class ArticleBloc extends HydratedBloc<ArticleEvent, ArticleState> {
  ArticleBloc({
    required this.articleId,
    required ArticleRepository articleRepository,
  }) : _articleRepository = articleRepository,
       super(const ArticleState.initial());

  final String articleId;

  // Storage ID includes article ID for isolation
  @override
  String get id => articleId;

  @override
  Map<String, dynamic>? toJson(ArticleState state) => state.toJson();

  @override
  ArticleState? fromJson(Map<String, dynamic> json) =>
      ArticleState.fromJson(json);
}
```

```mermaid
graph LR
    A[ArticleBloc ID: 'article_1'] --> S1[Storage: article_1.json]
    B[ArticleBloc ID: 'article_2'] --> S2[Storage: article_2.json]
    C[ArticleBloc ID: 'article_3'] --> S3[Storage: article_3.json]

    style A fill:#fff9c4
    style S1 fill:#c8e6c9
```

## SharedPreferences Layer

### PersistentStorage Wrapper

```mermaid
classDiagram
    class PersistentStorage {
        -SharedPreferences _sharedPreferences

        +read(key) String?
        +write(key, value) Future~void~
        +delete(key) Future~void~
        +clear() Future~void~
    }

    class SharedPreferences {
        +getString(key) String?
        +setString(key, value) Future~bool~
        +remove(key) Future~bool~
        +clear() Future~bool~
    }

    PersistentStorage --> SharedPreferences
```

### Storage Interface

```dart
class PersistentStorage {
  const PersistentStorage({
    required SharedPreferences sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  final SharedPreferences _sharedPreferences;

  /// Read value by key
  String? read({required String key}) {
    return _sharedPreferences.getString(key);
  }

  /// Write value for key
  Future<void> write({required String key, required String value}) {
    return _sharedPreferences.setString(key, value);
  }

  /// Delete value by key
  Future<void> delete({required String key}) {
    return _sharedPreferences.remove(key);
  }

  /// Clear all stored values
  Future<void> clear() {
    return _sharedPreferences.clear();
  }
}
```

## Domain-Specific Storage Classes

### UserStorage

Manages user-related persistent data.

```dart
class UserStorage {
  const UserStorage({
    required PersistentStorage storage,
  }) : _storage = storage;

  final PersistentStorage _storage;

  static const _appOpenedCountKey = '__app_opened_count_key__';

  /// Fetch app opened count
  int fetchAppOpenedCount() {
    final count = _storage.read(key: _appOpenedCountKey);
    return count != null ? int.parse(count) : 0;
  }

  /// Increment app opened count
  Future<void> incrementAppOpenedCount() {
    final count = fetchAppOpenedCount() + 1;
    return _storage.write(
      key: _appOpenedCountKey,
      value: count.toString(),
    );
  }

  /// Reset app opened count
  Future<void> resetAppOpenedCount() {
    return _storage.delete(key: _appOpenedCountKey);
  }
}
```

### ArticleStorage

Tracks article view limits and ad display frequency.

```dart
class ArticleStorage {
  const ArticleStorage({
    required PersistentStorage storage,
  }) : _storage = storage;

  final PersistentStorage _storage;

  static const _articleViewsKey = '__article_views_key__';
  static const _totalArticleViewsKey = '__total_article_views_key__';

  /// Get remaining article views (4 per day)
  int fetchArticleViews() {
    final views = _storage.read(key: _articleViewsKey);
    return views != null ? int.parse(views) : 4; // Default: 4 views
  }

  /// Increment article views (decrement remaining)
  Future<void> incrementArticleViews() {
    final current = fetchArticleViews();
    if (current > 0) {
      return _storage.write(
        key: _articleViewsKey,
        value: (current - 1).toString(),
      );
    }
    return Future.value();
  }

  /// Reset article views (daily reset)
  Future<void> resetArticleViews() {
    return _storage.write(
      key: _articleViewsKey,
      value: '4',
    );
  }

  /// Decrement views (after watching rewarded ad)
  Future<void> decrementArticleViews() {
    final current = fetchArticleViews();
    return _storage.write(
      key: _articleViewsKey,
      value: (current + 1).toString(),
    );
  }

  /// Get total article views (for ad frequency)
  int fetchTotalArticleViews() {
    final views = _storage.read(key: _totalArticleViewsKey);
    return views != null ? int.parse(views) : 0;
  }

  /// Increment total views
  Future<void> incrementTotalArticleViews() {
    final total = fetchTotalArticleViews() + 1;
    return _storage.write(
      key: _totalArticleViewsKey,
      value: total.toString(),
    );
  }
}
```

### NotificationsStorage

Manages notification preferences.

```dart
class NotificationsStorage {
  const NotificationsStorage({
    required PersistentStorage storage,
  }) : _storage = storage;

  final PersistentStorage _storage;

  static const _notificationsEnabledKey = '__notifications_enabled_key__';
  static const _categoryPreferencesKey = '__category_preferences_key__';

  /// Check if notifications are enabled
  bool fetchNotificationsEnabled() {
    final enabled = _storage.read(key: _notificationsEnabledKey);
    return enabled == 'true';
  }

  /// Set notifications enabled/disabled
  Future<void> setNotificationsEnabled(bool enabled) {
    return _storage.write(
      key: _notificationsEnabledKey,
      value: enabled.toString(),
    );
  }

  /// Get category notification preferences
  Map<Category, bool> fetchCategoryPreferences() {
    final json = _storage.read(key: _categoryPreferencesKey);
    if (json == null) return {};

    final map = jsonDecode(json) as Map<String, dynamic>;
    return map.map(
      (key, value) => MapEntry(
        Category.values.byName(key),
        value as bool,
      ),
    );
  }

  /// Set category preferences
  Future<void> setCategoryPreferences(Map<Category, bool> preferences) {
    final map = preferences.map(
      (key, value) => MapEntry(key.name, value),
    );
    return _storage.write(
      key: _categoryPreferencesKey,
      value: jsonEncode(map),
    );
  }
}
```

## Storage Flow Diagrams

### User App Open Tracking

```mermaid
sequenceDiagram
    participant User
    participant AppBloc
    participant UserRepo
    participant UserStorage
    participant SharedPrefs

    User->>AppBloc: Opens App
    activate AppBloc

    AppBloc->>UserRepo: fetchAppOpenedCount()
    activate UserRepo
    UserRepo->>UserStorage: fetchAppOpenedCount()
    activate UserStorage
    UserStorage->>SharedPrefs: getString('__app_opened_count_key__')
    SharedPrefs-->>UserStorage: "4"
    UserStorage-->>UserRepo: 4
    deactivate UserStorage
    UserRepo-->>AppBloc: 4
    deactivate UserRepo

    alt Count >= 5
        AppBloc->>AppBloc: Show Login Overlay
    else Count < 5
        AppBloc->>AppBloc: Continue Normally
    end

    AppBloc->>UserRepo: incrementAppOpenedCount()
    activate UserRepo
    UserRepo->>UserStorage: incrementAppOpenedCount()
    activate UserStorage
    UserStorage->>SharedPrefs: setString('__app_opened_count_key__', '5')
    SharedPrefs-->>UserStorage: Success
    UserStorage-->>UserRepo: Success
    deactivate UserStorage
    UserRepo-->>AppBloc: Success
    deactivate UserRepo

    deactivate AppBloc
```

### Article View Limit Tracking

```mermaid
flowchart TD
    A[User Opens Article] --> B[ArticleBloc: ArticleRequested]
    B --> C[ArticleRepository.getArticle]
    C --> D{User Subscribed?}

    D -->|Yes| E[Load Article]
    D -->|No| F[Check View Count]

    F --> G[ArticleStorage.fetchArticleViews]
    G --> H{Views Remaining?}

    H -->|Yes, views > 0| I[Load Article]
    H -->|No, views = 0| J[Show Paywall]

    I --> K[ArticleStorage.incrementArticleViews]
    K --> L[Decrement remaining views]
    L --> M[SharedPreferences.setString]

    J --> N[Prompt: Subscribe or Watch Ad]

    E --> O[Display Article]
    I --> O

    style A fill:#e1f5ff
    style D fill:#fff9c4
    style H fill:#fff9c4
    style J fill:#ef9a9a
    style O fill:#a5d6a7
```

### Feed State Persistence

```mermaid
sequenceDiagram
    participant User
    participant FeedBloc
    participant HydratedStorage
    participant FileSystem

    Note over User: App First Launch
    User->>FeedBloc: Initialize
    FeedBloc->>HydratedStorage: Read state
    HydratedStorage->>FileSystem: Check for saved state
    FileSystem-->>HydratedStorage: No state found
    HydratedStorage-->>FeedBloc: null
    FeedBloc->>FeedBloc: Use initial state

    User->>FeedBloc: FeedRequested
    FeedBloc->>FeedBloc: Fetch from API
    FeedBloc->>FeedBloc: emit(FeedState.success)
    FeedBloc->>HydratedStorage: toJson(state)
    HydratedStorage->>FileSystem: Write JSON
    FileSystem-->>HydratedStorage: Success

    Note over User: App Restart
    User->>FeedBloc: Initialize
    FeedBloc->>HydratedStorage: Read state
    HydratedStorage->>FileSystem: Read saved state
    FileSystem-->>HydratedStorage: JSON data
    HydratedStorage->>FeedBloc: fromJson(data)
    FeedBloc->>FeedBloc: Restore previous state
    Note over FeedBloc: Feed displayed instantly!
```

## State Persistence Patterns

### Pattern 1: Automatic Persistence (HydratedBloc)

**Use Case:** Cache entire feature state (feed, articles, categories)

```dart
// Automatically persisted
class FeedState extends Equatable {
  const FeedState({
    this.status = FeedStatus.initial,
    this.feed = const [],
    this.category,
  });

  final FeedStatus status;
  final List<Article> feed;
  final Category? category;

  // Serialization
  Map<String, dynamic> toJson() => {
    'status': status.name,
    'feed': feed.map((article) => article.toJson()).toList(),
    'category': category?.name,
  };

  // Deserialization
  factory FeedState.fromJson(Map<String, dynamic> json) {
    return FeedState(
      status: FeedStatus.values.byName(json['status']),
      feed: (json['feed'] as List)
          .map((item) => Article.fromJson(item))
          .toList(),
      category: json['category'] != null
          ? Category.values.byName(json['category'])
          : null,
    );
  }
}
```

### Pattern 2: Manual Persistence (Storage Classes)

**Use Case:** Simple counters, flags, preferences

```dart
// Manually managed
class UserRepository {
  Future<void> trackAppOpen() async {
    final count = userStorage.fetchAppOpenedCount();
    await userStorage.incrementAppOpenedCount();

    if (count >= 5) {
      // Show login overlay
    }
  }
}
```

### Pattern 3: Hybrid Approach

**Use Case:** Complex state with metadata

```dart
class ArticleBloc extends HydratedBloc<ArticleEvent, ArticleState> {
  // State persisted via HydratedBloc
  @override
  ArticleState? fromJson(Map<String, dynamic> json);

  // View count persisted separately
  Future<void> _trackView() async {
    await articleRepository.incrementArticleViews();
    await articleRepository.incrementTotalArticleViews();
  }
}
```

## Storage Lifecycle

```mermaid
stateDiagram-v2
    [*] --> AppLaunch

    AppLaunch --> InitializeStorage: Initialize
    InitializeStorage --> LoadHydratedState: HydratedBloc
    InitializeStorage --> LoadSharedPrefs: Storage Classes

    LoadHydratedState --> CheckFile: Read persisted BLoC state
    CheckFile --> RestoreState: File exists
    CheckFile --> FreshState: No file

    LoadSharedPrefs --> ReadPrefs: Read user preferences
    ReadPrefs --> Ready

    RestoreState --> Ready
    FreshState --> Ready

    Ready --> Running: App Running

    Running --> StateChange: User Interaction
    StateChange --> SerializeState: HydratedBloc auto-saves
    StateChange --> WritePrefs: Manual storage write

    SerializeState --> Running
    WritePrefs --> Running

    Running --> AppClose: User exits
    AppClose --> [*]
```

## Development Mode: Storage Clearing

```dart
// main_development.dart
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // CLEAR storage in development
  final storage = await HydratedStorage.build(
    storageDirectory: await getApplicationSupportDirectory(),
  );

  await storage.clear(); // Clear all persisted state

  HydratedBlocOverrides.runZoned(
    () => runApp(const App()),
    storage: storage,
  );
}
```

## Storage Locations

### iOS
```
/Users/<user>/Library/Developer/CoreSimulator/Devices/<device>/
  data/Containers/Data/Application/<app>/
    Library/Preferences/com.demo.news.plist  (SharedPreferences)
    Library/Application Support/              (HydratedBloc)
```

### Android
```
/data/data/com.demo.news/
  shared_prefs/FlutterSharedPreferences.xml  (SharedPreferences)
  files/                                      (HydratedBloc)
```

## Performance Considerations

### Storage Performance

```mermaid
graph LR
    A[Operation] --> B{Type}

    B -->|HydratedBloc| C[Automatic]
    B -->|SharedPreferences| D[Manual]

    C --> E[Async Write]
    D --> F[Async Write]

    E --> G[Background Thread]
    F --> G

    G --> H[Platform Storage]

    style A fill:#e1f5ff
    style E fill:#c8e6c9
    style F fill:#c8e6c9
```

### Optimization Techniques

1. **Lazy Loading**: Only deserialize state when BLoC is accessed
2. **Selective Persistence**: Only persist necessary state fields
3. **Compression**: JSON serialization is space-efficient
4. **Batching**: SharedPreferences batches writes automatically

## Error Handling

```dart
// HydratedBloc error handling
@override
FeedState? fromJson(Map<String, dynamic> json) {
  try {
    return FeedState.fromJson(json);
  } catch (error) {
    // Log error and return null (falls back to initial state)
    debugPrint('Failed to restore FeedState: $error');
    return null;
  }
}

// Storage error handling
Future<void> write(String key, String value) async {
  try {
    await _storage.write(key: key, value: value);
  } catch (error) {
    // Handle storage errors gracefully
    debugPrint('Storage write failed: $error');
  }
}
```

## Summary

The storage layer provides:

- **Two-tier storage**: HydratedBloc for state, SharedPreferences for simple data
- **Automatic persistence**: BLoC state saved/restored transparently
- **Domain-specific storage**: UserStorage, ArticleStorage, NotificationsStorage
- **Type-safe APIs**: Clear interfaces for all storage operations
- **Development support**: Storage clearing in dev mode
- **Platform integration**: Native iOS/Android storage
- **Error resilience**: Graceful fallback when restoration fails
- **Performance**: Async operations, background threads, compression

This architecture ensures data persistence while maintaining clean separation between business logic and storage implementation.
