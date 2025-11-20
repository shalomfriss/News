# Network Layer & API Integration

## Table of Contents
- [Overview](#overview)
- [API Client Architecture](#api-client-architecture)
- [Network Call Flow](#network-call-flow)
- [API Endpoints](#api-endpoints)
- [Request/Response Models](#requestresponse-models)
- [Error Handling](#error-handling)
- [Token Management](#token-management)

## Overview

The app uses a custom REST API client (`DemoNewsApiClient`) to communicate with the backend. The network layer follows a token-based authentication pattern with automatic error handling and request/response transformation.

**Key Components:**
- **DemoNewsApiClient** - HTTP client wrapper
- **TokenProvider** - Dynamic token injection
- **Response Models** - Type-safe DTOs
- **Middleware** - Request/response interceptors
- **Error Types** - Custom exception hierarchy

## API Client Architecture

```mermaid
graph TB
    subgraph "Repository Layer"
        Repo[Repository]
    end

    subgraph "API Client"
        Client[DemoNewsApiClient]
        TokenProvider[TokenProvider Interface]
        TokenStorage[TokenStorage]
    end

    subgraph "HTTP Layer"
        HTTPClient[HTTP Client]
        Middleware[Middleware]
    end

    subgraph "Backend"
        API[Demo News API]
    end

    subgraph "Response Processing"
        DTO[Response DTO]
        JSON[JSON Decoder]
        Model[Domain Model]
    end

    Repo --> Client
    Client --> TokenProvider
    TokenProvider --> TokenStorage
    Client --> HTTPClient
    HTTPClient --> Middleware
    Middleware --> API
    API --> JSON
    JSON --> DTO
    DTO --> Model
    Model --> Repo

    style Repo fill:#c8e6c9
    style Client fill:#fff9c4
    style API fill:#ffccbc
    style DTO fill:#e1f5ff
```

## DemoNewsApiClient Class Structure

```mermaid
classDiagram
    class DemoNewsApiClient {
        -String baseUrl
        -TokenProvider tokenProvider
        -http.Client httpClient

        +getArticle(id, limit, offset) ArticleResponse
        +getRelatedArticles(id, limit) RelatedArticlesResponse
        +getFeed(category, limit, offset) FeedResponse
        +getCategories() CategoriesResponse
        +getCurrentUser() CurrentUserResponse
        +popularSearch() PopularSearchResponse
        +relevantSearch(term) RelevantSearchResponse
        +subscribeToNewsletter(email) void
        +createSubscription(subscriptionId) void
        +getSubscriptions() SubscriptionsResponse
    }

    class TokenProvider {
        <<interface>>
        +fetchToken() Future~String?~
    }

    class InMemoryTokenStorage {
        +fetchToken() Future~String?~
        +saveToken(token) Future~void~
        +clearToken() Future~void~
    }

    DemoNewsApiClient --> TokenProvider
    InMemoryTokenStorage ..|> TokenProvider
```

## Network Call Flow

### Complete Request Flow

```mermaid
sequenceDiagram
    participant BLoC
    participant Repository
    participant APIClient as DemoNewsApiClient
    participant TokenProvider
    participant HTTP as HTTP Client
    participant API as Backend API

    BLoC->>Repository: Call method (e.g., getFeed)
    activate Repository

    Repository->>APIClient: getFeed(category, limit, offset)
    activate APIClient

    APIClient->>TokenProvider: fetchToken()
    activate TokenProvider
    TokenProvider-->>APIClient: token (or null)
    deactivate TokenProvider

    APIClient->>APIClient: Build request headers
    Note over APIClient: Authorization: Bearer {token}<br/>Content-Type: application/json

    APIClient->>HTTP: GET /api/v1/feed?...
    activate HTTP

    HTTP->>API: HTTP Request
    activate API
    API-->>HTTP: HTTP Response (200/4xx/5xx)
    deactivate API

    HTTP-->>APIClient: Response
    deactivate HTTP

    alt Success (200-299)
        APIClient->>APIClient: json.decode(response.body)
        APIClient->>APIClient: FeedResponse.fromJson()
        APIClient-->>Repository: FeedResponse
    else Error (4xx/5xx)
        APIClient->>APIClient: Throw DemoNewsApiRequestFailure
        APIClient-->>Repository: Exception
    else JSON Parse Error
        APIClient->>APIClient: Throw DemoNewsApiMalformedResponse
        APIClient-->>Repository: Exception
    end

    deactivate APIClient

    Repository->>Repository: Transform DTO to Domain Model
    Repository-->>BLoC: Domain Model / Exception
    deactivate Repository
```

### Simplified Flow Example: Fetching News Feed

```mermaid
flowchart TD
    A[FeedBloc: FeedRequested Event] --> B[NewsRepository.getFeed]
    B --> C[DemoNewsApiClient.getFeed]
    C --> D{Token Available?}
    D -->|Yes| E[Add Bearer Token to Headers]
    D -->|No| F[Make Request Without Token]
    E --> G[HTTP GET /api/v1/feed]
    F --> G
    G --> H{Response Status}
    H -->|200 OK| I[Parse JSON Response]
    H -->|4xx/5xx| J[Throw DemoNewsApiRequestFailure]
    I --> K[FeedResponse.fromJson]
    K --> L[Convert to Domain Models]
    L --> M[Return FeedResponse]
    M --> N[FeedBloc: Emit FeedState.success]
    J --> O[FeedBloc: Emit FeedState.failure]

    style A fill:#fff9c4
    style B fill:#c8e6c9
    style C fill:#e1f5ff
    style G fill:#ffccbc
    style N fill:#a5d6a7
    style O fill:#ef9a9a
```

## API Endpoints

### Base Configuration

```dart
// Development
const String baseUrl = 'http://localhost:8080';

// Production
const String baseUrl = 'https://api.production.com'; // Actual URL
```

### Endpoint Reference

```mermaid
graph LR
    subgraph "News Content"
        Feed[GET /api/v1/feed]
        Article[GET /api/v1/articles/:id]
        Related[GET /api/v1/articles/:id/related]
        Categories[GET /api/v1/categories]
    end

    subgraph "Search"
        Popular[GET /api/v1/search/popular]
        Relevant[GET /api/v1/search/relevant]
    end

    subgraph "User & Auth"
        CurrentUser[GET /api/v1/users/me]
    end

    subgraph "Subscriptions"
        CreateSub[POST /api/v1/subscriptions]
        GetSubs[GET /api/v1/subscriptions]
    end

    subgraph "Newsletter"
        Subscribe[POST /api/v1/newsletter/subscription]
    end
```

### Detailed Endpoints Table

| Method | Endpoint | Description | Auth Required | Query Parameters |
|--------|----------|-------------|---------------|------------------|
| GET | `/api/v1/feed` | Get paginated news feed | No | `category`, `limit`, `offset` |
| GET | `/api/v1/articles/{id}` | Get article content | No | `limit`, `offset` |
| GET | `/api/v1/articles/{id}/related` | Get related articles | No | `limit` |
| GET | `/api/v1/categories` | Get available categories | No | - |
| GET | `/api/v1/users/me` | Get current user + subscription | Yes | - |
| GET | `/api/v1/search/popular` | Get trending articles | No | - |
| GET | `/api/v1/search/relevant` | Search by term | No | `q` (query) |
| POST | `/api/v1/newsletter/subscription` | Subscribe to newsletter | No | Body: `{email}` |
| POST | `/api/v1/subscriptions` | Create subscription | Yes | Body: `{subscriptionId}` |
| GET | `/api/v1/subscriptions` | List subscriptions | Yes | - |

## Request/Response Models

### Data Model Architecture

```mermaid
graph TB
    subgraph "API Response (JSON)"
        JSON[Raw JSON String]
    end

    subgraph "DTO Layer"
        Response[Response DTO]
        ArticleResp[ArticleResponse]
        FeedResp[FeedResponse]
        UserResp[CurrentUserResponse]
    end

    subgraph "Domain Layer"
        Model[Domain Model]
        Article[Article]
        Feed[Feed]
        User[User]
    end

    JSON --> Response
    Response --> ArticleResp
    Response --> FeedResp
    Response --> UserResp

    ArticleResp --> Article
    FeedResp --> Feed
    UserResp --> User

    style JSON fill:#ffccbc
    style Response fill:#fff9c4
    style Model fill:#c8e6c9
```

### Key Response Models

#### 1. FeedResponse
```dart
class FeedResponse {
  final List<Article> feed;
  final int totalCount;

  factory FeedResponse.fromJson(Map<String, dynamic> json) {
    return FeedResponse(
      feed: (json['feed'] as List)
          .map((item) => Article.fromJson(item))
          .toList(),
      totalCount: json['totalCount'] as int,
    );
  }
}
```

#### 2. ArticleResponse
```dart
class ArticleResponse {
  final String id;
  final String title;
  final List<NewsBlock> content;
  final String? url;
  final bool isPremium;

  factory ArticleResponse.fromJson(Map<String, dynamic> json);
}
```

#### 3. CurrentUserResponse
```dart
class CurrentUserResponse {
  final User user;
  final SubscriptionPlan subscription;

  factory CurrentUserResponse.fromJson(Map<String, dynamic> json);
}
```

### Response Transformation Flow

```mermaid
sequenceDiagram
    participant API
    participant Client
    participant DTO
    participant Repository
    participant Domain

    API->>Client: JSON String
    activate Client
    Client->>Client: json.decode()
    Client->>DTO: fromJson(Map)
    activate DTO
    DTO->>DTO: Parse fields
    DTO->>DTO: Validate data
    DTO-->>Client: Response DTO
    deactivate DTO
    Client-->>Repository: Response DTO
    deactivate Client
    activate Repository
    Repository->>Domain: Transform to Domain Model
    activate Domain
    Domain-->>Repository: Domain Model
    deactivate Domain
    Repository-->>Repository: Return Domain Model
    deactivate Repository
```

## Error Handling

### Exception Hierarchy

```mermaid
classDiagram
    class Exception {
        <<abstract>>
    }

    class DemoNewsApiRequestFailure {
        +int statusCode
        +String body
        +String toString()
    }

    class DemoNewsApiMalformedResponse {
        +String error
        +String toString()
    }

    class NetworkException {
        +String message
    }

    Exception <|-- DemoNewsApiRequestFailure
    Exception <|-- DemoNewsApiMalformedResponse
    Exception <|-- NetworkException
```

### Error Handling Flow

```mermaid
flowchart TD
    A[Make API Call] --> B{HTTP Request}
    B -->|Success| C{Status Code}
    B -->|Network Error| D[Throw NetworkException]

    C -->|200-299| E{JSON Parsing}
    C -->|4xx/5xx| F[Throw DemoNewsApiRequestFailure]

    E -->|Success| G[Return Response DTO]
    E -->|Failure| H[Throw DemoNewsApiMalformedResponse]

    F --> I[BLoC Catches Exception]
    H --> I
    D --> I

    I --> J[Emit Failure State]
    J --> K[UI Shows Error Message]

    G --> L[Emit Success State]
    L --> M[UI Updates with Data]

    style A fill:#e1f5ff
    style G fill:#a5d6a7
    style F fill:#ef9a9a
    style H fill:#ef9a9a
    style D fill:#ef9a9a
```

### Error Handling Example

```dart
try {
  final response = await apiClient.getFeed(
    category: Category.technology,
    limit: 10,
    offset: 0,
  );
  emit(state.copyWith(status: FeedStatus.success, feed: response.feed));
} on DemoNewsApiRequestFailure catch (error) {
  // HTTP error (4xx, 5xx)
  emit(state.copyWith(
    status: FeedStatus.failure,
    error: 'Request failed: ${error.statusCode}',
  ));
} on DemoNewsApiMalformedResponse catch (error) {
  // JSON parsing error
  emit(state.copyWith(
    status: FeedStatus.failure,
    error: 'Invalid response format',
  ));
} catch (error) {
  // Unexpected error
  emit(state.copyWith(
    status: FeedStatus.failure,
    error: 'Unknown error occurred',
  ));
}
```

## Token Management

### Token Provider Pattern

```mermaid
graph TB
    subgraph "Authentication"
        Auth[Firebase Auth]
        Token[ID Token]
    end

    subgraph "Token Storage"
        Provider[TokenProvider Interface]
        Memory[InMemoryTokenStorage]
    end

    subgraph "API Client"
        Client[DemoNewsApiClient]
        Request[HTTP Request]
    end

    Auth --> Token
    Token --> Memory
    Memory -.implements.-> Provider
    Provider --> Client
    Client --> Request
    Request -.includes.-> Token

    style Auth fill:#fff9c4
    style Provider fill:#c8e6c9
    style Client fill:#e1f5ff
```

### Token Injection Flow

```mermaid
sequenceDiagram
    participant APIClient
    participant TokenProvider
    participant TokenStorage
    participant HTTPRequest

    APIClient->>TokenProvider: fetchToken()
    activate TokenProvider
    TokenProvider->>TokenStorage: Read stored token
    activate TokenStorage
    TokenStorage-->>TokenProvider: token (or null)
    deactivate TokenStorage
    TokenProvider-->>APIClient: token
    deactivate TokenProvider

    alt Token exists
        APIClient->>APIClient: Add Authorization header
        Note over APIClient: Authorization: Bearer {token}
    else No token
        APIClient->>APIClient: Skip Authorization header
    end

    APIClient->>HTTPRequest: Make request with headers
    activate HTTPRequest
    HTTPRequest-->>APIClient: Response
    deactivate HTTPRequest
```

### Token Storage Interface

```dart
abstract class TokenStorage {
  /// Fetches the current token
  Future<String?> fetchToken();

  /// Saves a new token
  Future<void> saveToken(String token);

  /// Clears the stored token
  Future<void> clearToken();
}

class InMemoryTokenStorage implements TokenStorage {
  String? _token;

  @override
  Future<String?> fetchToken() async => _token;

  @override
  Future<void> saveToken(String token) async => _token = token;

  @override
  Future<void> clearToken() async => _token = null;
}
```

## HTTP Client Configuration

### Request Headers

```dart
final headers = <String, String>{
  'Content-Type': 'application/json; charset=utf-8',
  'Accept': 'application/json',
};

// Add token if available
final token = await tokenProvider.fetchToken();
if (token != null) {
  headers['Authorization'] = 'Bearer $token';
}
```

### Request Builder Pattern

```mermaid
flowchart LR
    A[Build URL] --> B[Add Query Parameters]
    B --> C[Fetch Token]
    C --> D[Build Headers]
    D --> E[Create Request]
    E --> F[Send Request]
    F --> G[Handle Response]

    style A fill:#e1f5ff
    style C fill:#fff9c4
    style F fill:#ffccbc
    style G fill:#c8e6c9
```

## Real-World Usage Examples

### Example 1: Fetching News Feed

```dart
// 1. BLoC dispatches event
FeedBloc.add(FeedRequested(category: Category.technology));

// 2. BLoC handler calls repository
final response = await newsRepository.getFeed(
  category: Category.technology,
  limit: 10,
  offset: 0,
);

// 3. Repository calls API client
final response = await apiClient.getFeed(
  category: Category.technology,
  limit: 10,
  offset: 0,
);

// 4. API client makes HTTP request
// GET /api/v1/feed?category=technology&limit=10&offset=0
// Headers: Authorization: Bearer {token}

// 5. Response transformed
FeedResponse {
  feed: [Article(id: '1', ...), Article(id: '2', ...)],
  totalCount: 50
}

// 6. BLoC emits success state
emit(FeedState.success(feed: response.feed));
```

### Example 2: Creating Subscription

```dart
// 1. User completes purchase in SubscriptionsBloc
PurchaseBloc.add(PurchaseCompleted(purchaseId: 'abc123'));

// 2. BLoC calls repository
await inAppPurchaseRepository.deliverPurchase(purchaseDetails);

// 3. Repository validates with backend
await apiClient.createSubscription(subscriptionId: 'abc123');

// 4. API client makes POST request
// POST /api/v1/subscriptions
// Headers: Authorization: Bearer {token}
// Body: {"subscriptionId": "abc123"}

// 5. Backend validates purchase with Apple/Google
// 6. Backend updates user subscription plan
// 7. App refreshes user data
await userRepository.fetchUser();
```

## Performance Considerations

### Caching Strategy

```mermaid
graph TD
    Request[API Request] --> Cache{Check Cache}
    Cache -->|Hit| Return[Return Cached Data]
    Cache -->|Miss| API[Call API]
    API --> Store[Store in Cache]
    Store --> Return2[Return Fresh Data]

    style Cache fill:#fff9c4
    style Return fill:#a5d6a7
    style API fill:#ffccbc
```

### Optimization Techniques

1. **HydratedBloc Caching**
   - Feed, Article, and Categories BLoCs cache responses
   - Reduces unnecessary API calls
   - Instant loading on app restart

2. **Token Caching**
   - In-memory token storage
   - Avoids repeated Firebase Auth calls

3. **Request Debouncing**
   - Search uses 300ms debounce
   - Prevents excessive API calls during typing

4. **Pagination**
   - Offset-based pagination for feed
   - Limit parameter controls page size
   - Reduces payload size

## Summary

The network layer implements a robust, type-safe API integration:

- **Custom HTTP client** with token injection
- **Type-safe DTOs** with automatic JSON parsing
- **Comprehensive error handling** with custom exceptions
- **Token-based authentication** via Firebase
- **Clean separation** between API responses and domain models
- **10+ endpoints** covering all app features
- **Development/Production** environment support
- **Caching strategies** for performance optimization

The architecture enables easy testing, maintainability, and scalability while providing a reliable network communication layer for the entire application.
