# Travaly Task - Hotel Search App

A Flutter hotel search application built with Clean Architecture, integrating with the MyTravaly API to provide seamless hotel discovery and browsing experience.

## 📱 Download APK

**[Download Release APK](https://drive.google.com/file/d/18fWZTC_G6jn1Wn3I__P7UbX17AO6MDlS/view?usp=sharing)** - Ready to install on Android devices

## Overview

This project demonstrates a production-ready Flutter app implementing Clean Architecture principles with proper separation of concerns, state management using Cubit (flutter_bloc), and comprehensive error handling.

## Features

### Authentication

- Google Sign-In integration with proper OAuth flow
- Persistent sessions using SharedPreferences
- Auto-login on app restart
- Clean error handling for auth failures

### Hotel Discovery

- Browse popular hotels in your city
- Real-time search across properties, cities, states
- Smooth pagination for search results
- Pull-to-refresh functionality
- Device fingerprinting for personalized results

### User Experience

- Minimalistic, modern UI with coral accent theme
- Shimmer loading animations
- Empty states with helpful messages
- Error states with retry options
- Smooth navigation and transitions

## Architecture

The app follows **Clean Architecture** with clear separation between layers:

```
lib/
├── core/                          # Shared utilities
│   ├── config/
│   │   └── api_config.dart       # API configuration constants
│   ├── error/
│   │   ├── exceptions.dart       # Custom exceptions
│   │   └── failures.dart         # Failure types
│   └── usecase/
│       └── usecase.dart          # Base usecase interface
│
├── features/
│   ├── auth/
│   │   ├── domain/               # Business logic layer
│   │   │   ├── entities/         # Core business objects
│   │   │   ├── repositories/     # Abstract contracts
│   │   │   └── usecases/         # Business use cases
│   │   ├── data/                 # Data layer
│   │   │   ├── models/           # Data models with JSON parsing
│   │   │   ├── datasources/      # Remote & local data sources
│   │   │   └── repositories/     # Repository implementations
│   │   └── presentation/         # UI layer
│   │       ├── cubit/            # State management
│   │       └── pages/            # UI screens
│   │
│   └── hotels/
│       ├── domain/
│       ├── data/
│       └── presentation/
│           ├── cubit/
│           └── pages/
│               ├── home/         # Home page with widgets
│               └── search/       # Search page with widgets
│
├── utils/
│   └── app_theme.dart           # Theme configuration
├── widgets/
│   └── hotel_card.dart          # Reusable components
├── injection_container.dart      # Dependency injection setup
└── main.dart                     # App entry point
```

### Layer Responsibilities

**Domain Layer**: Pure business logic, no framework dependencies

- Entities: Core business objects
- Repositories: Abstract interfaces
- Use Cases: Single responsibility business operations

**Data Layer**: External data handling

- Models: Extends entities with JSON serialization
- Data Sources: API calls, local storage
- Repository Implementations: Bridge between data sources and domain

**Presentation Layer**: UI and state management

- Cubit: BLoC pattern for state management
- Pages: UI screens organized by feature
- Widgets: Reusable UI components

## Tech Stack

```yaml
# State Management
flutter_bloc: ^8.1.3
equatable: ^2.0.5

# Dependency Injection
get_it: ^7.6.4
injectable: ^2.3.2

# Functional Programming
dartz: ^0.10.1 # Either for error handling

# API & Storage
http: ^1.2.0
shared_preferences: ^2.2.2
device_info_plus: ^10.1.0

# Authentication
google_sign_in: ^6.2.1
```

## Getting Started

### Prerequisites

- Flutter SDK (3.5.1+)
- Dart SDK (3.0+)
- Android Studio / Xcode
- Google Cloud Console project (for OAuth)

### Installation

1. Clone and setup:

```bash
git clone https://github.com/RGTechPro/travaly_task.git
cd travaly_task
flutter pub get
```

2. Run the app:

```bash
flutter run
```

### Configuration

The app uses centralized configuration in `lib/core/config/api_config.dart`:

- Base URL for MyTravaly API
- Authentication token
- Default limits and currencies
- Search types configuration

## API Integration

### MyTravaly API

Base URL: `https://api.mytravaly.com/public/v1/`

**Implemented Endpoints:**

1. **Device Register** - Generates visitor token with device fingerprint
2. **Search Auto Complete** - Multi-type search (city, state, country, property)
3. **Popular Stay** - Location-based popular hotels

**Features:**

- Automatic device registration on first launch
- Visitor token management for personalized results
- Real device info integration (Android/iOS)
- Comprehensive error handling with retry logic

## Design Patterns Used

- **Clean Architecture**: Separation of concerns across layers
- **Repository Pattern**: Abstract data sources
- **Dependency Injection**: GetIt for loose coupling
- **Cubit Pattern**: Predictable state management
- **Either Pattern**: Functional error handling with dartz
- **Factory Pattern**: Model creation from JSON

## State Management

Using **Cubit** (simplified BLoC) for predictable state management:

- Separate cubits for Auth and Hotels
- Immutable state classes with Equatable
- Clear state transitions (Initial → Loading → Success/Error)
- No business logic in UI layer

## Known Issues

- Some API responses don't include complete hotel data
- Pagination currently simulated on frontend
