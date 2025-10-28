# Clean Architecture - Implementation Guide

This document explains how Clean Architecture is implemented in this Flutter project.

## Why Clean Architecture?

I chose Clean Architecture because:
- **Testability**: Each layer can be tested independently
- **Maintainability**: Clear separation makes code easier to understand
- **Scalability**: Easy to add new features without breaking existing code
- **Independence**: UI, database, and frameworks are replaceable

## The Three Layers

### 1. Domain Layer (Business Logic)
The innermost layer - pure Dart code with no Flutter dependencies.

**Contains:**
- **Entities**: Core business objects (e.g., `User`, `Hotel`)
- **Repositories**: Abstract contracts defining what data operations are needed
- **Use Cases**: Single-responsibility business operations

**Example:**
```dart
// Entity - Pure business object
class Hotel extends Equatable {
  final String propertyCode;
  final String propertyName;
  final String city;
  // ... business properties only
}

// Repository Interface - What operations are needed
abstract class HotelRepository {
  Future<Either<Failure, List<Hotel>>> searchHotels(String query, int page);
  Future<Either<Failure, List<Hotel>>> getPopularHotels(...);
}

// Use Case - Single business operation
class SearchHotels {
  final HotelRepository repository;
  
  Future<Either<Failure, List<Hotel>>> call(String query, int page) {
    return repository.searchHotels(query, page);
  }
}
```

### 2. Data Layer (External World)
Handles all external data - APIs, databases, device info, etc.

**Contains:**
- **Models**: Extend entities with JSON serialization (`fromJson`, `toJson`)
- **Data Sources**: Actual API calls and local storage operations
- **Repository Implementations**: Connect data sources to domain contracts

**Example:**
```dart
// Model - Extends entity with JSON capabilities
class HotelModel extends Hotel {
  HotelModel({...}) : super(...);
  
  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
      propertyCode: json['propertyCode'] ?? '',
      propertyName: json['propertyName'] ?? '',
      // ... parse JSON
    );
  }
}

// Data Source - Actual API implementation
class HotelRemoteDataSourceImpl {
  final http.Client client;
  
  Future<List<HotelModel>> searchHotels(String query, int page) async {
    final response = await client.post(Uri.parse(ApiConfig.baseUrl), ...);
    // ... handle response, return models
  }
}

// Repository Implementation - Glue between data and domain
class HotelRepositoryImpl implements HotelRepository {
  final HotelRemoteDataSource remoteDataSource;
  
  @override
  Future<Either<Failure, List<Hotel>>> searchHotels(String query, int page) async {
    try {
      final hotels = await remoteDataSource.searchHotels(query, page);
      return Right(hotels);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
```

### 3. Presentation Layer (UI & State)
Everything the user sees and interacts with.

**Contains:**
- **Cubits**: State management (BLoC pattern simplified)
- **States**: Immutable state classes
- **Pages**: Full screen widgets
- **Widgets**: Reusable UI components

**Example:**
```dart
// State - Immutable state classes
abstract class HotelState extends Equatable {}
class HotelLoading extends HotelState {}
class HotelLoaded extends HotelState {
  final List<Hotel> hotels;
}
class HotelError extends HotelState {
  final String message;
}

// Cubit - State management
class HotelCubit extends Cubit<HotelState> {
  final SearchHotels searchHotelsUseCase;
  
  void searchHotels(String query) async {
    emit(HotelLoading());
    final result = await searchHotelsUseCase(query, 1);
    result.fold(
      (failure) => emit(HotelError(failure.message)),
      (hotels) => emit(HotelLoaded(hotels)),
    );
  }
}

// Page - UI that reacts to state
class SearchResultsPage extends StatelessWidget {
  Widget build(BuildContext context) {
    return BlocBuilder<HotelCubit, HotelState>(
      builder: (context, state) {
        return switch (state) {
          HotelLoading() => LoadingState(),
          HotelLoaded() => HotelList(hotels: state.hotels),
          HotelError() => ErrorState(message: state.message),
          _ => EmptyState(),
        };
      },
    );
  }
}
```
- Implementations in Data layer

## Dependency Flow

The key rule: **Dependencies point inward**

```
Presentation Layer (UI, Cubit)
        ↓ (depends on)
Domain Layer (Entities, Use Cases, Repository Interfaces)
        ↑ (implemented by)
Data Layer (Models, Data Sources, Repository Implementations)
```

- **Presentation** knows about Domain (uses use cases and entities)
- **Data** knows about Domain (implements repository interfaces)
- **Domain** knows about nothing (pure business logic)

This means I can:
- Change the UI framework without touching business logic
- Swap APIs without changing use cases
- Test each layer independently

## Dependency Injection with GetIt

I use GetIt as a service locator to manage dependencies:

```dart
// Setup in injection_container.dart
final sl = GetIt.instance;

Future<void> init() async {
  // Cubits (recreated each time)
  sl.registerFactory(() => AuthCubit(
    signInWithGoogle: sl(),
    signOut: sl(),
    checkAuthStatus: sl(),
  ));
  
  // Use Cases (singleton)
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  
  // Repositories (singleton)
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  
  // Data Sources (singleton)
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(googleSignIn: sl()),
  );
  
  // External (Google Sign-In, HTTP client)
  sl.registerLazySingleton(() => GoogleSignIn());
  sl.registerLazySingleton(() => http.Client());
}
```

## Error Handling Pattern

I use the **Either** type from `dartz` for functional error handling:

```dart
// Success or Failure - no exceptions thrown
Future<Either<Failure, List<Hotel>>> searchHotels(...) async {
  try {
    final hotels = await remoteDataSource.searchHotels(...);
    return Right(hotels);  // Success
  } on ServerException {
    return Left(ServerFailure());  // Known error
  } on NetworkException {
    return Left(NetworkFailure());
  } catch (e) {
    return Left(UnknownFailure());  // Unexpected error
  }
}
```

**Benefits:**
- No try-catch in UI layer
- Explicit error handling
- Type-safe - compiler ensures we handle both cases
- Easy to test

## State Management with Cubit

Why Cubit over other solutions?
- **Simpler than full BLoC**: No events, just methods
- **Predictable**: Clear state transitions
- **Testable**: Easy to test state changes
- **No setState()**: UI reacts to state automatically

### Pattern I follow:

```dart
// 1. Define states (sealed with pattern matching)
sealed class HotelState extends Equatable {}
class HotelInitial extends HotelState {}
class HotelLoading extends HotelState {}
class HotelLoaded extends HotelState {
  final List<Hotel> hotels;
}

// 2. Create cubit with use cases
class HotelCubit extends Cubit<HotelState> {
  final SearchHotels searchHotelsUseCase;
  
  HotelCubit({required this.searchHotelsUseCase}) : super(HotelInitial());
  
  // 3. Call use case, emit states
  Future<void> searchHotels(String query) async {
    emit(HotelLoading());
    
    final result = await searchHotelsUseCase(query, 1);
    
    result.fold(
      (failure) => emit(HotelError(failure.message)),
      (hotels) => emit(HotelLoaded(hotels)),
    );
  }
}

// 4. UI reacts with BlocBuilder and switch expressions
BlocBuilder<HotelCubit, HotelState>(
  builder: (context, state) {
    return switch (state) {
      HotelInitial() => EmptyState(),
      HotelLoading() => LoadingState(),
      HotelLoaded() => HotelList(hotels: state.hotels),
      HotelError() => ErrorState(message: state.message),
    };
  },
)
```

## Project Structure Decisions

### Why organize by feature?
Instead of organizing by type (all cubits together, all models together), I organize by feature:

```
features/
  ├── auth/          # Everything auth-related in one place
  │   ├── domain/
  │   ├── data/
  │   └── presentation/
  └── hotels/        # Everything hotels-related in one place
      ├── domain/
      ├── data/
      └── presentation/
```

**Benefits:**
- Easy to find related code
- Can work on a feature without touching others
- Could extract a feature into a package easily
- Scales better as app grows

### Widget organization
I further organized widgets by page:

```
presentation/
  └── pages/
      ├── home/
      │   ├── home_page.dart
      │   └── widgets/         # Widgets only used by home page
      │       ├── shimmer_loading.dart
      │       ├── empty_state.dart
      │       └── error_state.dart
      └── search/
          ├── search_results_page.dart
          └── widgets/         # Widgets only used by search page
```

This keeps page-specific widgets separate from truly reusable ones (in `lib/widgets/`).

## What I Learned

### Challenges faced:
1. **Initial complexity**: Clean Architecture has more files/folders, but it paid off
2. **Dependency direction**: Had to resist the urge to import Flutter in domain layer
3. **Either type**: Functional error handling was new to me but makes sense now
4. **Cubit vs BLoC**: Chose Cubit for simplicity, but understand when BLoC is better

### Key takeaways:
- **Separation is powerful**: Each layer can evolve independently
- **Abstractions are worth it**: Repository pattern makes testing easy
- **Immutable state**: Prevents subtle bugs and makes state predictable
- **Use cases clarify intent**: Each one clearly states what business operation happens

## Testing Strategy

With Clean Architecture, testing becomes straightforward:

**Unit Tests:**
- Domain: Test use cases with mock repositories
- Data: Test repositories with mock data sources
- Presentation: Test cubits with mock use cases

**Widget Tests:**
- Test UI widgets in isolation
- Mock cubits to control state

**Integration Tests:**
- Test complete flows end-to-end
- Use real implementations

(Tests not fully implemented yet, but architecture supports it)

## References

Resources that helped me understand Clean Architecture:
- Robert C. Martin's Clean Architecture book
- Reso Coder's Flutter Clean Architecture tutorial
- Official BLoC documentation
- Dartz package for functional programming patterns

---

**Note**: This architecture might seem overkill for a small app, but it's designed to scale. As features are added, this structure keeps code organized and maintainable.


