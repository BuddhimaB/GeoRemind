# GeoRemind

## 1. Project Overview

GeoRemind is a mobile application developed with Flutter that allows users to create reminders based on geographic location rather than a specific time. When a user approaches a saved location (geofence), the app displays a local notification. The app supports offline usage with on-device storage.

---

## 2. Core Features

- Add reminders with title, description, radius, and selected location
- Search locations using Google Places Autocomplete
- Map picking and current GPS location selection
- Continuous location monitoring with speed and dwell filters
- Local notifications when entering the geofence area
- Task categorization: Active, Completed, Expired
- Local SQLite database for offline support

---

## 3. Tools, Libraries, and APIs Used

### Flutter and Dart
- Framework and programming language for building the app interface

### Maps and Location
- **google_maps_flutter** – Displays Google Map and markers
- **Google Maps API** – Map display service
- **Google Places API** – Search suggestions for locations
- **geolocator** – Device GPS location and distance checks

### Local Storage
- **sqflite** – SQLite database for task storage
- **path_provider** – Finds correct storage path for database

### User Interface
- **flutter_typeahead** – Suggestion list UI component

### Notifications
- **flutter_local_notifications** – Local push notifications

### Networking
- **http** – Makes REST API calls to Google Places

### Background Monitoring
- **flutter_background_service** – Background location monitoring

---

## 4. Setup and Installation

### Clone the Repository

```bash
git clone https://github.com/yourusername/your-repo-name.git
cd your-repo-name
```
## 5. Google API Configuration

This project requires Google API Keys for:

- Maps display (Maps SDK)
- Place Autocomplete (Places API)

Steps:

1. Go to **Google Cloud Console**
2. Enable:
   - Maps SDK for Android / iOS
   - Places API
3. Create an API key and add it to the project

#### Android

In:

```text
android/app/src/main/res/values/google_maps_api.xml
Add:
<string name="google_maps_key">YOUR_API_KEY</string>
```
## 6. Running the Application

Connect a device or start an emulator, then run:

```bash
flutter run
```
## 7. Application Usage

### Adding a Reminder

1. Tap the **Add** button.
2. Enter the title and description.
3. Enter the radius (meters).
4. Pick a location:
   - Using the map picker.
   - Using the search auto-suggest feature.
5. Save the reminder.

### Viewing Reminders

Reminders appear under three tabs:

- **Active** – Active and valid reminders.
- **Completed** – Reminders marked done.
- **Expired** – Reminders past expiry.

### Triggering Notifications

When the user enters a location radius and satisfies the context filters (speed, dwell time), a local notification is triggered.
## 8. Permissions

The app requires the following permissions:

- Location (foreground and background)
- Notifications

Ensure these are granted for proper functionality.
## 9. Optional Backend Integration

Integration with a backend service such as Firebase can provide:

- Syncing reminders across devices
- Secure user login
- Cloud backup of reminders

This is optional and not required for the core app functionality.

