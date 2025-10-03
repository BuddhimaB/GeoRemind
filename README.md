# GeoRemind 📍

A location-based reminder mobile application built with Flutter that helps users set reminders triggered by their geographic location.

## Features ✨

### Core Functionalities
- ✅ **Create Location-Based Reminders**: Set reminders that trigger when you reach a specific location
- ✅ **GPS Integration**: Automatic location tracking and geofencing
- ✅ **Smart Notifications**: Receive notifications when entering a reminder's radius
- ✅ **Customizable Radius**: Set detection radius from 50m to 5000m
- ✅ **Priority Levels**: Organize reminders by Low, Medium, or High priority
- ✅ **Active/Inactive Toggle**: Enable or disable reminders without deleting them
- ✅ **Persistent Storage**: All reminders saved locally using SQLite
- ✅ **Real-time Updates**: Live location tracking and reminder monitoring
- ✅ **Swipe to Delete**: Easy reminder management with swipe gestures

### User Interface
- 🎨 Modern Material Design 3
- 🌓 Light and Dark theme support
- 📱 Responsive layout for different screen sizes
- 🗺️ Map view for visualizing reminders (placeholder for Google Maps integration)
- 📝 Detailed reminder cards with all information at a glance

## Architecture 🏗️

The application follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/
│   ├── constants/        # App-wide constants
│   ├── theme/            # Theme configuration
│   └── utils/            # Utility functions
├── data/
│   ├── models/           # Data models
│   ├── repositories/     # Repository implementations
│   └── services/         # External services (DB, Location, Notifications)
├── domain/
│   ├── entities/         # Business entities
│   └── repositories/     # Repository interfaces
└── presentation/
    ├── providers/        # State management (Provider pattern)
    ├── screens/          # UI screens
    └── widgets/          # Reusable widgets
```

### Design Patterns Used
- **Repository Pattern**: Abstraction layer for data access
- **Provider Pattern**: State management
- **Dependency Injection**: Services injected through providers
- **Single Responsibility Principle**: Each class has one job
- **Interface Segregation**: Clean separation between domain and data layers

## Technology Stack 💻

- **Framework**: Flutter 3.35.5
- **Language**: Dart 3.9.2
- **State Management**: Provider
- **Local Database**: SQLite (sqflite)
- **Location Services**: Geolocator, Geocoding
- **Notifications**: Flutter Local Notifications
- **Background Tasks**: Workmanager

## Prerequisites 📋

1. **Flutter SDK** (3.0.0 or higher)
   - Download from [flutter.dev](https://flutter.dev)
   - Add to PATH environment variable

2. **For Windows Development**:
   - Enable Developer Mode: `Settings > Update & Security > For developers > Developer Mode`
   - Visual Studio 2019 or later with C++ desktop development tools

3. **For Android Development**:
   - Android Studio
   - Android SDK (API level 21 or higher)
   - Accept Android licenses: `flutter doctor --android-licenses`

4. **For iOS Development** (Mac only):
   - Xcode 12.0 or higher
   - CocoaPods

## Installation & Setup 🚀

### 1. Clone the Repository
```bash
git clone https://github.com/BuddhimaB/GeoRemind.git
cd GeoRemind
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Enable Developer Mode (Windows)
```powershell
start ms-settings:developers
```
Then toggle "Developer Mode" to ON.

### 4. Run the Application

**For Windows:**
```bash
flutter run -d windows
```

**For Android:**
```bash
flutter run -d <device-id>
```

**For iOS:**
```bash
flutter run -d <device-id>
```

**To see available devices:**
```bash
flutter devices
```

## Permissions 🔐

### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### iOS (Info.plist)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to trigger reminders</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location in the background to trigger reminders</string>
```

## Usage Guide 📖

### Creating a Reminder
1. Tap the **+** button on the home screen
2. Enter a **title** and optional **description**
3. Select a location:
   - Use "Current Location" button for your current position
   - Or manually enter coordinates and tap "Get Location Name"
4. Adjust the **radius** slider (50m - 5000m)
5. Set the **priority** level
6. Toggle **Active** status
7. Tap "Create Reminder"

### Managing Reminders
- **View All**: See all reminders on the home screen
- **Toggle Active/Inactive**: Use the switch on each reminder card
- **Edit**: Tap on a reminder card
- **Delete**: Swipe left on a reminder card
- **Refresh**: Pull down to refresh or tap the refresh icon

### Map View
- Switch to Map tab to see reminder locations visualized
- View your current location
- See all active and inactive reminders

## Project Structure 📁

```
GeoRemind/
├── android/              # Android platform code
├── ios/                  # iOS platform code
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart
│   │   └── theme/
│   │       └── app_theme.dart
│   ├── data/
│   │   ├── models/
│   │   │   └── reminder_model.dart
│   │   ├── repositories/
│   │   │   └── reminder_repository_impl.dart
│   │   └── services/
│   │       ├── database_service.dart
│   │       ├── location_service.dart
│   │       └── notification_service.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   └── reminder.dart
│   │   └── repositories/
│   │       └── reminder_repository.dart
│   ├── presentation/
│   │   ├── providers/
│   │   │   └── reminder_provider.dart
│   │   ├── screens/
│   │   │   ├── home_screen.dart
│   │   │   ├── add_edit_reminder_screen.dart
│   │   │   ├── location_picker_screen.dart
│   │   │   └── map_screen.dart
│   │   └── widgets/
│   │       └── reminder_card.dart
│   └── main.dart
├── test/                 # Unit and widget tests
├── pubspec.yaml         # Dependencies
└── README.md

```

## Future Enhancements 🚀

### Planned Features
- [ ] Google Maps integration for visual location selection
- [ ] Reminder categories and filtering
- [ ] Recurring reminders
- [ ] Reminder sharing
- [ ] Statistics and analytics
- [ ] Cloud backup and sync
- [ ] Multiple notification sounds
- [ ] Reminder templates
- [ ] Search and sort functionality
- [ ] Export/Import reminders

### Non-Functional Improvements
- [ ] Comprehensive unit tests
- [ ] Integration tests
- [ ] Performance optimization
- [ ] Accessibility features
- [ ] Localization (i18n)
- [ ] CI/CD pipeline
- [ ] Error analytics
- [ ] User onboarding tutorial

## Testing 🧪

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

## Building for Production 🏭

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Windows
```bash
flutter build windows --release
```

## Troubleshooting 🔧

### Location Not Working
- Ensure location permissions are granted
- Check if GPS is enabled on device
- Verify location services in app settings

### Notifications Not Showing
- Grant notification permissions
- Check notification settings for the app
- Ensure "Do Not Disturb" is off

### Build Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## Contributing 🤝

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License 📄

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact 📧

Project Link: [https://github.com/BuddhimaB/GeoRemind](https://github.com/BuddhimaB/GeoRemind)

## Acknowledgments 🙏

- Flutter team for the amazing framework
- All package maintainers
- Community contributors

---

**Built with ❤️ using Flutter**

