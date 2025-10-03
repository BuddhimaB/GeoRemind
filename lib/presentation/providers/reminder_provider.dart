import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../data/services/location_service.dart';
import '../../data/services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  final ReminderRepository _repository;
  final LocationService _locationService;
  final NotificationService _notificationService;
  
  List<Reminder> _reminders = [];
  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;
  bool _locationPermissionGranted = false;
  
  List<Reminder> get reminders => _reminders;
  List<Reminder> get activeReminders => _reminders.where((r) => r.isActive).toList();
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get locationPermissionGranted => _locationPermissionGranted;
  
  ReminderProvider(
    this._repository,
    this._locationService,
    this._notificationService,
  ) {
    _initialize();
  }
  
  Future<void> _initialize() async {
    await loadReminders();
    await checkLocationPermission();
    if (_locationPermissionGranted) {
      _startLocationTracking();
    }
  }
  
  Future<void> checkLocationPermission() async {
    _locationPermissionGranted = await _locationService.checkPermission();
    notifyListeners();
  }
  
  Future<void> loadReminders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _reminders = await _repository.getAllReminders();
    } catch (e) {
      _error = 'Failed to load reminders: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> createReminder(Reminder reminder) async {
    try {
      await _repository.createReminder(reminder);
      await loadReminders();
    } catch (e) {
      _error = 'Failed to create reminder: $e';
      notifyListeners();
    }
  }
  
  Future<void> updateReminder(Reminder reminder) async {
    try {
      await _repository.updateReminder(reminder);
      await loadReminders();
    } catch (e) {
      _error = 'Failed to update reminder: $e';
      notifyListeners();
    }
  }
  
  Future<void> deleteReminder(String id) async {
    try {
      await _repository.deleteReminder(id);
      await loadReminders();
    } catch (e) {
      _error = 'Failed to delete reminder: $e';
      notifyListeners();
    }
  }
  
  Future<void> toggleReminder(String id, bool isActive) async {
    try {
      await _repository.toggleReminderActive(id, isActive);
      await loadReminders();
    } catch (e) {
      _error = 'Failed to toggle reminder: $e';
      notifyListeners();
    }
  }
  
  Future<void> getCurrentLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      _currentPosition = position;
      notifyListeners();
    }
  }
  
  void _startLocationTracking() {
    _locationService.getLocationStream().listen((position) {
      _currentPosition = position;
      _checkReminders(position);
      notifyListeners();
    });
  }
  
  void _checkReminders(Position position) {
    for (final reminder in activeReminders) {
      if (_locationService.isWithinRadius(
        position.latitude,
        position.longitude,
        reminder.latitude,
        reminder.longitude,
        reminder.radius,
      )) {
        _triggerReminder(reminder);
      }
    }
  }
  
  Future<void> _triggerReminder(Reminder reminder) async {
    await _notificationService.showReminderNotification(reminder);
    
    // Update reminder with triggered time
    final updatedReminder = reminder.copyWith(
      triggeredAt: DateTime.now(),
      isActive: false, // Optionally deactivate after triggering
    );
    await updateReminder(updatedReminder);
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
