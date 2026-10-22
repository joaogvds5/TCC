import 'package:flutter_test/flutter_test.dart';
import 'package:nearu/src/models/event_participant.dart';

void main() {
  group('EventParticipant.fromMap', () {
    test('Converte mapa completo', () {
      final map = {
        'user_id': 'uuid-123',
        'users': {'name': 'João', 'photo_user': 'https://example.com/foto.jpg'},
        'joined_at': '2024-01-01T10:00:00Z',
      };

      final participant = EventParticipant.fromMap(map);

      expect(participant.userId, equals('uuid-123'));
      expect(participant.userName, equals('João'));
      expect(participant.userPhotoUrl, equals('https://example.com/foto.jpg'));
    });

    test('Usa fallback quando users é null', () {
      final map = {
        'user_id': 'uuid-123',
        'name': 'Maria',
        'joined_at': '2024-01-01T10:00:00Z',
      };

      final participant = EventParticipant.fromMap(map);
      expect(participant.userName, equals('Maria'));
    });

    test('Usa "Usuário" quando nome está ausente', () {
      final map = {'user_id': 'uuid-123'};
      final participant = EventParticipant.fromMap(map);
      expect(participant.userName, equals('Usuário'));
    });

    test('Usa data atual quando joined_at é null', () {
      final participant = EventParticipant.fromMap({'user_id': 'uuid-123'});
      expect(participant.joinedAt, isNotNull);
    });
  });

  group('EventParticipant.toMap', () {
    test('Converte em mapa corretamente', () {
      final participant = EventParticipant(
        userId: 'uuid-123',
        userName: 'João',
        joinedAt: DateTime(2024, 1, 1),
      );

      final map = participant.toMap();
      expect(map['user_id'], equals('uuid-123'));
      expect(map['joined_at'], contains('2024-01-01'));
    });
  });
}
