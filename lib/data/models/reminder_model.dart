import '../../domain/entities/reminder.dart';

class ReminderModel extends Reminder {
  const ReminderModel({
    required super.id,
    required super.title,
    super.description,
    required super.latitude,
    required super.longitude,
    required super.locationName,
    required super.radius,
    super.isActive,
    required super.createdAt,
    super.triggeredAt,
    super.priority,
    super.category,
    super.color,
  });
  
  factory ReminderModel.fromEntity(Reminder reminder) {
    return ReminderModel(
      id: reminder.id,
      title: reminder.title,
      description: reminder.description,
      latitude: reminder.latitude,
      longitude: reminder.longitude,
      locationName: reminder.locationName,
      radius: reminder.radius,
      isActive: reminder.isActive,
      createdAt: reminder.createdAt,
      triggeredAt: reminder.triggeredAt,
      priority: reminder.priority,
      category: reminder.category,
      color: reminder.color,
    );
  }
  
  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      locationName: map['locationName'] as String,
      radius: map['radius'] as double,
      isActive: (map['isActive'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      triggeredAt: map['triggeredAt'] != null 
          ? DateTime.parse(map['triggeredAt'] as String)
          : null,
      priority: ReminderPriority.values[map['priority'] as int],
      category: map['category'] as String?,
      color: map['color'] as int?,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'radius': radius,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'triggeredAt': triggeredAt?.toIso8601String(),
      'priority': priority.index,
      'category': category,
      'color': color,
    };
  }
  
  Reminder toEntity() {
    return Reminder(
      id: id,
      title: title,
      description: description,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      radius: radius,
      isActive: isActive,
      createdAt: createdAt,
      triggeredAt: triggeredAt,
      priority: priority,
      category: category,
      color: color,
    );
  }
}
