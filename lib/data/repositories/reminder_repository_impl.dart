import 'dart:async';
import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../models/reminder_model.dart';
import '../services/database_service.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final DatabaseService _databaseService;
  final StreamController<List<Reminder>> _remindersController = StreamController<List<Reminder>>.broadcast();
  
  ReminderRepositoryImpl(this._databaseService);
  
  @override
  Future<List<Reminder>> getAllReminders() async {
    final models = await _databaseService.getAllReminders();
    final reminders = models.map((model) => model.toEntity()).toList();
    _remindersController.add(reminders);
    return reminders;
  }
  
  @override
  Future<List<Reminder>> getActiveReminders() async {
    final models = await _databaseService.getActiveReminders();
    return models.map((model) => model.toEntity()).toList();
  }
  
  @override
  Future<Reminder?> getReminderById(String id) async {
    final model = await _databaseService.getReminderById(id);
    return model?.toEntity();
  }
  
  @override
  Future<void> createReminder(Reminder reminder) async {
    final model = ReminderModel.fromEntity(reminder);
    await _databaseService.insertReminder(model);
    await getAllReminders(); // Refresh stream
  }
  
  @override
  Future<void> updateReminder(Reminder reminder) async {
    final model = ReminderModel.fromEntity(reminder);
    await _databaseService.updateReminder(model);
    await getAllReminders(); // Refresh stream
  }
  
  @override
  Future<void> deleteReminder(String id) async {
    await _databaseService.deleteReminder(id);
    await getAllReminders(); // Refresh stream
  }
  
  @override
  Future<void> toggleReminderActive(String id, bool isActive) async {
    await _databaseService.toggleReminderActive(id, isActive);
    await getAllReminders(); // Refresh stream
  }
  
  @override
  Stream<List<Reminder>> watchReminders() {
    getAllReminders(); // Initial load
    return _remindersController.stream;
  }
  
  void dispose() {
    _remindersController.close();
  }
}
