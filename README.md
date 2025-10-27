# MyTravaly - Flutter Hotel Booking App

A Flutter application for searching and browsing hotels using the MyTravaly API.

## Features

### 1. Google Sign-In/Sign-Up (Page 1)

- Clean and modern authentication screen
- Google Sign-In integration (frontend implementation)
- Persistent user sessions using SharedPreferences
- Smooth animations and transitions

### 2. Home Page - Hotel List (Page 2)

- Display featured hotels with beautiful card UI
- Search functionality by hotel name, city, state, or country
- Pull-to-refresh for latest data
- User-friendly empty states and loading indicators
- Integrated with MyTravaly API

### 3. Search Results Page (Page 3)

- Display search results from the API
- Pagination support for efficient data loading
- Infinite scroll with load-more functionality
- Error handling with retry options
- Shimmer loading effects

## Technical Implementation

### Architecture

- **Clean Code Structure**: Organized into models, services, screens, widgets, and utils
- **State Management**: Using StatefulWidget with proper state handling
- **API Integration**: RESTful API integration with the MyTravaly backend
- **Local Storage**: SharedPreferences for user session management

### Key Dependencies

```yaml
google_sign_in: ^6.2.1 # Google authentication
http: ^1.2.0 # API requests
shared_preferences: ^2.2.2 # Local storage
provider: ^6.1.1 # State management
shimmer: ^3.0.0 # Loading animations
cached_network_image: ^3.3.1 # Image caching
```

### Project Structure

```
lib/
├── main.dart                    # App entry point with splash screen
├── models/
│   ├── hotel.dart              # Hotel data model
│   └── search_response.dart    # API response model
├── screens/
│   ├── login_screen.dart       # Google Sign-In page
│   ├── home_screen.dart        # Hotel list with search
│   └── search_results_screen.dart  # Paginated results
├── services/
│   ├── api_service.dart        # API integration
│   └── auth_service.dart       # Authentication logic
├── widgets/
│   └── hotel_card.dart         # Reusable hotel card
└── utils/
    └── app_theme.dart          # App colors and text styles
```

## API Integration

### Base URL

```
https://api.mytravaly.com/public/v1/
```

### Authentication

- Auth Token: `71523fdd8d26f585315b4233e39d9263`
- Device registration for visitor token
- Proper header management

### Endpoints Used

1. **Device Register** - Register device and get visitor token
2. **Search Auto Complete** - Search hotels by various criteria
3. **Popular Stay** - Get featured hotels list

## Design Decisions

### UI/UX

- **Material Design 3**: Modern, clean interface
- **Custom Theme**: Consistent color scheme throughout
- **Animations**: Smooth transitions and loading states
- **Responsive**: Works on various screen sizes
- **Error Handling**: User-friendly error messages

### Code Quality

- **Type Safety**: Proper null-safety implementation
- **Error Handling**: Try-catch blocks with graceful fallbacks
- **Code Organization**: Separation of concerns
- **Reusability**: Modular widget architecture
- **Documentation**: Clear comments and structure

### UX Enhancements

- Splash screen with animated logo
- Pull-to-refresh functionality
- Infinite scroll pagination
- Shimmer loading effects
- Image caching for better performance
- Bottom sheet for hotel details
- Search query persistence
- Smooth page transitions

## Setup Instructions

### Prerequisites

- Flutter SDK (3.5.1 or higher)
- Dart SDK
- Android Studio / Xcode for platform-specific builds

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd travaly_task
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## Testing

The app has been tested for:

- ✅ Google Sign-In flow
- ✅ API integration with MyTravaly
- ✅ Search functionality
- ✅ Pagination
- ✅ Error handling
- ✅ Loading states
- ✅ Session persistence

## Code Quality Measures

- Consistent naming conventions
- Proper error handling
- Loading states for better UX
- Null-safety throughout
- Clean separation of concerns
- Reusable components
- Performance optimizations (image caching, lazy loading)

## Author

Rishabh Gupta

---

**Submission**: Flutter Developer Position - MyTravaly
