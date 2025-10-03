# GeoRemind - Setup & Development Guide

## Quick Start Guide

### Prerequisites Installation

#### Step 1: Install Flutter SDK
1. Download Flutter SDK from https://flutter.dev/docs/get-started/install/windows
2. Extract to `C:\flutter-sdk\flutter` (or any preferred location)
3. Add to PATH:
   ```powershell
   # Add Flutter to PATH (temporary for current session)
   $env:Path += ";C:\flutter-sdk\flutter\bin"
   
   # Add Flutter to PATH (permanent)
   [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\flutter-sdk\flutter\bin", "User")
   ```

#### Step 2: Enable Windows Developer Mode
**IMPORTANT**: Required for Windows development with plugins!

```powershell
# Open Developer Settings
start ms-settings:developers
```
Then toggle **"Developer Mode"** to **ON**.

#### Step 3: Install Visual Studio Build Tools
1. Download Visual Studio 2019 or later
2. Install with "Desktop development with C++" workload
3. Verify: `flutter doctor`

#### Step 4: Verify Installation
```powershell
flutter doctor
```

Expected output should show:
- ✓ Flutter (Channel stable)
- ✓ Windows Version
- ✓ Visual Studio
- ✓ VS Code (optional)

### Project Setup

#### 1. Clone and Navigate
```powershell
cd "c:\Users\janak\Desktop\GitHub\New folder\GeoRemind"
```

#### 2. Install Dependencies
```powershell
flutter pub get
```

#### 3. Run the App

**Windows Desktop:**
```powershell
flutter run -d windows
```

**Android (with connected device/emulator):**
```powershell
flutter run -d <device-id>
```

**Check available devices:**
```powershell
flutter devices
```

## Project Architecture

### Clean Architecture Layers

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (UI, Screens, Widgets, Providers)      │
├─────────────────────────────────────────┤
│          Domain Layer                   │
│    (Entities, Repository Interfaces)    │
├─────────────────────────────────────────┤
│           Data Layer                    │
│ (Models, Repository Impl, Services)     │
└─────────────────────────────────────────┘
```

### Directory Structure Explained

```
lib/
├── core/                    # Core functionality
│   ├── constants/           # App-wide constants (radius, intervals, etc.)
│   ├── theme/              # Theme configuration (colors, text styles)
│   └── utils/              # Utility functions and helpers
│
├── data/                    # Data layer (closest to external sources)
│   ├── models/             # Data models with serialization
│   │   └── reminder_model.dart        # Converts between DB and Entity
│   ├── repositories/       # Repository implementations
│   │   └── reminder_repository_impl.dart  # Implements domain interface
│   └── services/           # External service integrations
│       ├── database_service.dart      # SQLite operations
│       ├── location_service.dart      # GPS and geolocation
│       └── notification_service.dart  # Push notifications
│
├── domain/                  # Business logic layer
│   ├── entities/           # Pure business objects
│   │   └── reminder.dart              # Core reminder entity
│   └── repositories/       # Repository contracts (interfaces)
│       └── reminder_repository.dart   # Abstract repository
│
├── presentation/            # UI layer
│   ├── providers/          # State management
│   │   └── reminder_provider.dart     # App state and business logic
│   ├── screens/            # Full-page views
│   │   ├── home_screen.dart           # Main list view
│   │   ├── add_edit_reminder_screen.dart  # Create/edit form
│   │   ├── location_picker_screen.dart    # Location selection
│   │   └── map_screen.dart            # Map visualization
│   └── widgets/            # Reusable UI components
│       └── reminder_card.dart         # Reminder list item
│
└── main.dart               # App entry point
```

### Data Flow

```
User Action (UI)
    ↓
Provider (State Management)
    ↓
Repository (Data Access Interface)
    ↓
Service (External APIs/DB)
    ↓
Database / Location / Notifications
    ↓
Model (Data Serialization)
    ↓
Entity (Business Object)
    ↓
Provider (State Update)
    ↓
UI Update (Consumer/Selector)
```

## Key Features Implementation

### 1. Geofencing
```dart
// Location tracking in ReminderProvider
void _checkReminders(Position position) {
  for (final reminder in activeReminders) {
    if (_locationService.isWithinRadius(...)) {
      _triggerReminder(reminder);
    }
  }
}
```

### 2. Local Storage
```dart
// SQLite database with sqflite
- CREATE TABLE reminders (...)
- CRUD operations
- Async/await pattern
- Stream for reactive updates
```

### 3. Notifications
```dart
// Flutter Local Notifications
- Channel creation
- Permission handling
- Notification triggering
- Tap handling
```

### 4. State Management
```dart
// Provider pattern
- ChangeNotifier for state
- Consumer/Selector for updates
- Dependency injection
- Separation of concerns
```

## Development Workflow

### Running the App
```powershell
# Development mode (hot reload enabled)
flutter run -d windows

# Release mode (optimized)
flutter run --release -d windows
```

### Hot Reload
While app is running:
- Press `r` to hot reload
- Press `R` to hot restart
- Press `q` to quit

### Debugging
```powershell
# Run with debugging
flutter run --debug

# Verbose logging
flutter run -v
```

### Testing
```powershell
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test
flutter test test/reminder_test.dart
```

### Code Quality
```powershell
# Analyze code
flutter analyze

# Format code
flutter format lib/

# Fix formatting issues
dart fix --apply
```

## Building for Production

### Windows Desktop
```powershell
# Build release executable
flutter build windows --release

# Output: build\windows\x64\runner\Release\
```

### Android
```powershell
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Output: build\app\outputs\
```

### iOS (macOS only)
```powershell
# Build iOS app
flutter build ios --release

# Output: build\ios\iphoneos\
```

## Common Issues & Solutions

### Issue 1: "Building with plugins requires symlink support"
**Solution:** Enable Developer Mode in Windows Settings

### Issue 2: Location not working on Windows
**Workaround:** Use manual coordinate entry in LocationPickerScreen

### Issue 3: Notifications not showing
**Check:**
- Notification permissions granted
- Notification channel created
- System notifications enabled

### Issue 4: Build errors after pub get
**Solution:**
```powershell
flutter clean
flutter pub get
flutter pub upgrade
```

### Issue 5: "Flutter command not found"
**Solution:**
```powershell
# Add to PATH for current session
$env:Path += ";C:\Users\janak\flutter-sdk\flutter\bin"

# Check Flutter
flutter doctor
```

## Performance Optimization

### Database
- Use indexes for frequent queries
- Batch operations when possible
- Close connections properly

### Location Services
- Set appropriate distance filter
- Adjust update interval
- Stop tracking when not needed

### Memory Management
- Dispose controllers
- Cancel stream subscriptions
- Clear caches

## Security Best Practices

1. **Permissions**
   - Request only necessary permissions
   - Explain why permissions needed
   - Handle permission denials gracefully

2. **Data Storage**
   - Encrypt sensitive data
   - Use secure storage for tokens
   - Clear data on uninstall

3. **Location Privacy**
   - Allow users to disable tracking
   - Clear location history option
   - Transparent about data usage

## Deployment Checklist

- [ ] Update version in pubspec.yaml
- [ ] Run all tests
- [ ] Check for compilation warnings
- [ ] Test on physical devices
- [ ] Update README and CHANGELOG
- [ ] Create release notes
- [ ] Build release artifacts
- [ ] Test release build
- [ ] Submit to stores (if applicable)

## Resources

### Documentation
- [Flutter Docs](https://docs.flutter.dev/)
- [Dart Docs](https://dart.dev/guides)
- [Provider Package](https://pub.dev/packages/provider)
- [Geolocator Package](https://pub.dev/packages/geolocator)

### Learning
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Provider State Management](https://docs.flutter.dev/data-and-backend/state-mgmt/simple)

## Support

For issues and questions:
1. Check existing GitHub issues
2. Read the documentation
3. Create a new issue with:
   - Clear description
   - Steps to reproduce
   - Expected vs actual behavior
   - Flutter/Dart versions
   - Platform (Windows/Android/iOS)

---

**Happy Coding! 🚀**
