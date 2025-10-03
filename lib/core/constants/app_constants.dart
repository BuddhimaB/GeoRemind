class AppConstants {
  // App Info
  static const String appName = 'GeoRemind';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'georemind.db';
  static const int databaseVersion = 1;
  
  // Geofencing
  static const double defaultRadius = 100.0; // meters
  static const double minRadius = 50.0;
  static const double maxRadius = 5000.0;
  
  // Location Updates
  static const int locationUpdateInterval = 60; // seconds
  static const double distanceFilter = 10.0; // meters
  
  // Notifications
  static const String notificationChannelId = 'georemind_notifications';
  static const String notificationChannelName = 'Location Reminders';
  static const String notificationChannelDescription = 'Notifications for location-based reminders';
  
  // Preferences Keys
  static const String keyFirstLaunch = 'first_launch';
  static const String keyLocationPermission = 'location_permission';
  static const String keyNotificationPermission = 'notification_permission';
  static const String keyThemeMode = 'theme_mode';
  
  // Map
  static const double defaultZoom = 15.0;
  static const double defaultLatitude = 37.7749;
  static const double defaultLongitude = -122.4194;
}
