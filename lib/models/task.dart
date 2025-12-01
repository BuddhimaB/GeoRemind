class Task {
  final int? id;
  final String title;
  final String? description;
  final double latitude;
  final double longitude;
  final double radiusMeters;

  // Later we can add: speedThreshold, dwellTimeSeconds, isCompleted, etc.
  final bool isCompleted;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'lat': latitude,
      'lng': longitude,
      'radius_m': radiusMeters,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      latitude: map['lat'] as double,
      longitude: map['lng'] as double,
      radiusMeters: map['radius_m'] as double,
      isCompleted: (map['is_completed'] as int) == 1,
    );
  }
}
