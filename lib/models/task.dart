class Task {
  final int? id;
  final String title;
  final String? description;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final String? locationName;
  final bool isCompleted;
  final DateTime? expiresAt;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    this.locationName,
    this.isCompleted = false,
    this.expiresAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'lat': latitude,
      'lng': longitude,
      'radius_m': radiusMeters,
      'location_name': locationName,
      'is_completed': isCompleted ? 1 : 0,
      'expires_at': expiresAt?.millisecondsSinceEpoch,
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
      locationName: map['location_name'] as String?,
      isCompleted: (map['is_completed'] as int) == 1,
      expiresAt: map['expires_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['expires_at'] as int)
          : null,
    );
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    double? radiusMeters,
    String? locationName,
    bool? isCompleted,
    DateTime? expiresAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      locationName: locationName ?? this.locationName,
      isCompleted: isCompleted ?? this.isCompleted,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
