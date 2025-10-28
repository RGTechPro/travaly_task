# Clean Architecture Implementation - MyTravaly

## Architecture Overview

The project now follows **Clean Architecture** principles with **Cubit** (from flutter_bloc) for state management.

### Layer Structure

```
lib/
├── core/                          # Core/Shared layer
│   ├── error/
│   │   ├── exceptions.dart       # Custom exceptions
│   │   └── failures.dart          # Failure classes
│   └── usecase/
│       └── usecase.dart          # Base UseCase class
│
├── features/                      # Feature modules
│   ├── auth/                     # Authentication feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_local_data_source.dart
│   │   │   │   └── auth_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── check_auth_status.dart
│   │   │       ├── get_current_user.dart
│   │   │       ├── sign_in_with_google.dart
│   │   │       └── sign_out.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── auth_cubit.dart
│   │       │   └── auth_state.dart
│   │       └── pages/
│   │           ├── login_page.dart
│   │           └── splash_page.dart
│   │
│   └── hotels/                   # Hotels feature
│       ├── data/
│       │   ├── datasources/
│       │   │   └── hotel_remote_data_source.dart
│       │   ├── models/
│       │   │   └── hotel_model.dart
│       │   └── repositories/
│       │       └── hotel_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── hotel.dart
│       │   ├── repositories/
│       │   │   └── hotel_repository.dart
│       │   └── usecases/
│       │       ├── get_popular_hotels.dart
│       │       └── search_hotels.dart
│       └── presentation/
│           ├── cubit/
│           │   ├── hotel_cubit.dart
│           │   └── hotel_state.dart
│           └── pages/
│               ├── home_page.dart
│               └── search_results_page.dart
│
├── utils/                        # Shared utilities
│   └── app_theme.dart
│
├── widgets/                      # Reusable widgets
│   └── hotel_card.dart
│
├── injection_container.dart      # Dependency Injection setup
└── main.dart                     # App entry point
```

## Clean Architecture Principles

### 1. **Separation of Concerns**

Each layer has a specific responsibility:

- **Domain**: Business logic, entities, use cases (framework independent)
- **Data**: API calls, local storage, repository implementations
- **Presentation**: UI, state management with Cubit

### 2. **Dependency Rule**

Dependencies point inward:

- Presentation → Domain ← Data
- Domain layer has no dependencies on outer layers
- Data and Presentation depend on Domain abstractions

### 3. **Dependency Inversion**

- Abstractions (interfaces) defined in Domain
- Implementations in Data layer
- Presentation uses abstractions through Dependency Injection

## Key Components

### Cubit (State Management)

#### AuthCubit

```dart
States:
- AuthInitial: Initial state
- AuthLoading: Processing auth operations
- AuthAuthenticated(User): User logged in
- AuthUnauthenticated: No user session
- AuthError(String): Auth error occurred

Methods:
- checkAuth(): Check if user is signed in
- signIn(): Sign in with Google
- logout(): Sign out
```

#### HotelCubit

```dart
States:
- HotelInitial: Initial state
- HotelLoading: Loading hotels
- HotelLoaded(List<Hotel>): Hotels loaded
- HotelSearchResults: Search results with pagination
- HotelError(String): Error occurred

Methods:
- loadPopularHotels(): Load featured hotels
- searchForHotels(query, page): Search with pagination
```

### Use Cases (Domain Layer)

Each use case encapsulates a single business operation:

**Auth Use Cases:**

- `SignInWithGoogle`: Handle Google authentication
- `SignOut`: Sign out user
- `CheckAuthStatus`: Check if user is signed in
- `GetCurrentUser`: Get cached user data

**Hotel Use Cases:**

- `GetPopularHotels`: Fetch popular/featured hotels
- `SearchHotels`: Search hotels with query and pagination

### Repositories (Domain → Data)

**Abstract Repositories (Domain):**

```dart
abstract class AuthRepository {
  Future<Either<Failure, User>> signInWithGoogle();
  Future<Either<Failure, void>> signOut();
  ...
}

abstract class HotelRepository {
  Future<Either<Failure, List<Hotel>>> searchHotels(...);
  Future<Either<Failure, List<Hotel>>> getPopularHotels(...);
}
```

**Implementations (Data):**

- Handle API calls via data sources
- Transform models to entities
- Error handling with Either<Failure, Success>

### Data Sources

**Remote Data Sources:**

- `HotelRemoteDataSource`: API calls to MyTravaly backend
- `AuthRemoteDataSource`: Google Sign-In integration

**Local Data Sources:**

- `AuthLocalDataSource`: SharedPreferences for session management

### Dependency Injection

Using **get_it** for service locator pattern:

```dart
// Registration in injection_container.dart
sl.registerFactory(() => AuthCubit(...));
sl.registerLazySingleton(() => SignInWithGoogle(sl()));
sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(...));
```

## Error Handling

### Exceptions (Data Layer)

```dart
- ServerException: API errors
- NetworkException: Connectivity issues
- CacheException: Local storage errors
- AuthException: Authentication failures
```

### Failures (Domain Layer)

```dart
- ServerFailure: Propagated from ServerException
- NetworkFailure: Propagated from NetworkException
- CacheFailure: Propagated from CacheException
- AuthFailure: Propagated from AuthException
```

### Either Type (Functional Programming)

Using `dartz` package for functional error handling:

```dart
Future<Either<Failure, User>> signIn() async {
  try {
    final user = await remoteDataSource.signIn();
    return Right(user);
  } catch (e) {
    return Left(AuthFailure(e.message));
  }
}
```

## Benefits of This Architecture

### 1. **Testability**

- Each layer can be tested independently
- Easy to mock dependencies
- Use cases are pure business logic

### 2. **Maintainability**

- Clear separation of concerns
- Easy to locate and fix bugs
- Changes in one layer don't affect others

### 3. **Scalability**

- Easy to add new features
- Can swap implementations (e.g., different APIs)
- Independent module development

### 4. **Reusability**

- Use cases can be reused across different UI components
- Domain entities are framework-independent
- Repository abstractions allow multiple implementations

### 5. **Team Collaboration**

- Different developers can work on different layers
- Clear contracts between layers
- Reduced merge conflicts

## State Management with Cubit

### Why Cubit over StatefulWidget?

1. **Predictable State Changes**: All state transitions go through cubit
2. **Separation**: Business logic separated from UI
3. **Testable**: Easy to test state changes
4. **Reactive**: UI automatically rebuilds on state changes
5. **Dev Tools**: Flutter DevTools support for debugging

### Cubit Pattern

```dart
// 1. Define states
abstract class AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}

// 2. Cubit emits states
class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> signIn() async {
    emit(AuthLoading());
    final result = await signInUseCase();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }
}

// 3. UI reacts to states
BlocBuilder<AuthCubit, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) return LoadingWidget();
    if (state is AuthAuthenticated) return HomeScreen();
    return LoginScreen();
  },
)
```

## Migration Notes

### What Changed?

1. **Old Structure** (Simple):

   ```
   lib/
   ├── models/
   ├── services/
   ├── screens/
   └── widgets/
   ```

2. **New Structure** (Clean Architecture):
   ```
   lib/
   ├── core/
   ├── features/
   │   ├── auth/
   │   │   ├── data/
   │   │   ├── domain/
   │   │   └── presentation/
   │   └── hotels/
   │       ├── data/
   │       ├── domain/
   │       └── presentation/
   └── injection_container.dart
   ```

### Key Differences:

- **State Management**: StatefulWidget → Cubit
- **Service Layer**: Direct services → Use Cases + Repositories
- **Error Handling**: try-catch → Either<Failure, Success>
- **Dependencies**: Manual instantiation → Dependency Injection (get_it)
- **Data Flow**: Direct API calls → Repository pattern

## How to Use

### 1. Initialize Dependencies

```dart
void main() async {
  await di.init(); // Initialize dependency injection
  runApp(MyApp());
}
```

### 2. Provide Cubits

```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => di.sl<AuthCubit>()),
    BlocProvider(create: (_) => di.sl<HotelCubit>()),
  ],
  child: MyApp(),
)
```

### 3. Use Cubits in UI

```dart
// Read cubit
context.read<AuthCubit>().signIn();

// Listen to state changes
BlocListener<AuthCubit, AuthState>(
  listener: (context, state) {
    if (state is AuthError) {
      showSnackBar(state.message);
    }
  },
  child: ...
)

// Build UI based on state
BlocBuilder<AuthCubit, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) return LoadingWidget();
    ...
  },
)
```

## Testing Strategy

### Unit Tests

- **Use Cases**: Test business logic
- **Repositories**: Test data transformations
- **Cubits**: Test state emissions

### Widget Tests

- Test UI with mock Cubits
- Verify correct widgets for each state

### Integration Tests

- End-to-end user flows
- Real API integration

## Future Enhancements

1. **Add more features** following the same pattern
2. **Implement caching strategy** for offline support
3. **Add integration tests** for critical flows
4. **Performance monitoring** with analytics
5. **CI/CD pipeline** for automated testing

---

## Summary

This clean architecture implementation provides:

- ✅ Separation of concerns
- ✅ Testable code
- ✅ Scalable structure
- ✅ Maintainable codebase
- ✅ Professional-grade architecture
- ✅ Industry best practices

The app is now production-ready with a solid foundation for growth!
