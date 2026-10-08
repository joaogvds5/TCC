// lib/src/models/event_participant.dart
class EventParticipant {
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final DateTime joinedAt;

  EventParticipant({
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.joinedAt,
  });

  factory EventParticipant.fromMap(Map<String, dynamic> map) {
    return EventParticipant(
      userId: map['user_id']?.toString() ?? '',
      userName: map['users']?['name'] ?? map['name'] ?? 'Usuário',
      userPhotoUrl: map['users']?['photo_user'] ?? map['photo_user'],
      joinedAt: map['joined_at'] != null
          ? DateTime.tryParse(map['joined_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'user_id': userId, 'joined_at': joinedAt.toIso8601String()};
  }
}
