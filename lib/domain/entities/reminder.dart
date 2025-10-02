import 'package:equatable/equatable.dart';

class Reminder extends Equatable {
  final String id;
  final String title;
  final String? description;
  final double latitude;
  final double longitude;
  final String locationName;
  final double radius;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? triggeredAt;
  final ReminderPriority priority;
  final String? category;
  final int? color;
  
  const Reminder({
    required this.id,
    required this.title,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.radius,
    this.isActive = true,
    required this.createdAt,
    this.triggeredAt,
    this.priority = ReminderPriority.medium,
    this.category,
    this.color,
  });
  
  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    String? locationName,
    double? radius,
    bool? isActive,
    DateTime? createdAt,
    DateTime? triggeredAt,
    ReminderPriority? priority,
    String? category,
    int? color,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      radius: radius ?? this.radius,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      color: color ?? this.color,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    title,
    description,
    latitude,
    longitude,
    locationName,
    radius,
    isActive,
    createdAt,
    triggeredAt,
    priority,
    category,
    color,
  ];
}

enum ReminderPriority {
  low,
  medium,
  high,
}
