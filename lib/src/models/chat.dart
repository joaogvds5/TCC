class Chat {
  final String id;
  final String eventTitle;
  final String lastMessage;
  final DateTime updatedAt;

  Chat({
    required this.id,
    required this.eventTitle,
    required this.lastMessage,
    required this.updatedAt,
  });

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'],
      eventTitle: map['event']['title'],
      lastMessage: map['last_message'] ?? '',
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
