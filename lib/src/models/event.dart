class Event {
  final String? id; // pode ser null na criação
  final String title;
  final String description;
  final int categoryId;
  final double latitude;
  final double longitude;
  final String userId;
  final String? photoUrl;
  final DateTime? createdAt; // null na criação, preenchido pelo banco
  final bool? inActivity; // para soft delete

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.latitude,
    required this.longitude,
    required this.userId,
    this.photoUrl,
    this.createdAt,
    this.inActivity,
  });

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id']?.toString(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      categoryId: map['interest_category'] ?? 0,
      latitude: (map['latitude_event'] as num).toDouble(),
      longitude: (map['longitude_event'] as num).toDouble(),
      userId: map['user_creator'] ?? '',
      photoUrl: map['photo_event'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      inActivity: map['in_activity'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'interest_category': categoryId,
      'latitude_event': latitude,
      'longitude_event': longitude,
      'user_creator': userId,
      'photo_event': photoUrl,
    };

    // Só incluir se não for null (para updates parciais)
    if (id != null) map['id'] = id;

    return map;
  }
}
