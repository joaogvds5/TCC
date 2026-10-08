class MessageModel {
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;

  MessageModel({
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
  });

  // Converte o objeto em JSON para enviar ao banco de dados
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': timestamp.toUtc().toIso8601String(),
    };
  }

  // Reconstrói o objeto a partir dos dados recebidos do banco
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      text: map['text'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
