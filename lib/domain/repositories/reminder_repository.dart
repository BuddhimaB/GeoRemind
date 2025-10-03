import '../entities/reminder.dart';

abstract class ReminderRepository {
  Future<List<Reminder>> getAllReminders();
  Future<List<Reminder>> getActiveReminders();
  Future<Reminder?> getReminderById(String id);
  Future<void> createReminder(Reminder reminder);
  Future<void> updateReminder(Reminder reminder);
  Future<void> deleteReminder(String id);
  Future<void> toggleReminderActive(String id, bool isActive);
  Stream<List<Reminder>> watchReminders();
}
