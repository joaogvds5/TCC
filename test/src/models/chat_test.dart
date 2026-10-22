import 'package:flutter_test/flutter_test.dart';
import 'package:nearu/src/models/chat.dart';

void main() {
  group('Chat.fromMap', () {
    test('Converte mapa completo', () {
      final map = {
        'id': 'chat-1',
        'event': {'title': 'Show de Rock'},
        'last_message': 'Bora!',
        'updated_at': '2024-01-01T10:00:00Z',
      };

      final chat = Chat.fromMap(map);

      expect(chat.id, equals('chat-1'));
      expect(chat.eventTitle, equals('Show de Rock'));
      expect(chat.lastMessage, equals('Bora!'));
      expect(chat.updatedAt, equals(DateTime.parse('2024-01-01T10:00:00Z')));
    });

    test('Usa string vazia quando last_message é null', () {
      final map = {
        'id': 'chat-1',
        'event': {'title': 'Evento'},
        'updated_at': '2024-01-01T10:00:00Z',
      };

      final chat = Chat.fromMap(map);
      expect(chat.lastMessage, equals(''));
    });
  });
}
