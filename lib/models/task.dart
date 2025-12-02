class Task {
  final int? id;
  final String title;
  final String? description;
  final double latitude;
  final double longitude;
  final double radiusMeters;
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
      latitude: (map['lat'] as num).toDouble(),
      longitude: (map['lng'] as num).toDouble(),
      radiusMeters: (map['radius_m'] as num).toDouble(),
      isCompleted: (map['is_completed'] as int) == 1,
    );
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    double? radiusMeters,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
