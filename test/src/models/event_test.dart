import 'package:flutter_test/flutter_test.dart';
import 'package:nearu/src/models/event.dart';

void main() {
  group('Event.fromMap', () {
    test('Converte mapa completo em Event', () {
      final map = {
        'id': 42,
        'title': 'Show de Rock',
        'description': 'Banda ao vivo',
        'interest_category': 2,
        'latitude_event': -23.5505,
        'longitude_event': -46.6333,
        'user_creator': 'uuid-123',
        'photo_event': 'https://example.com/foto.jpg',
        'created_at': '2024-01-01T10:00:00Z',
        'in_activity': true,
      };

      final event = Event.fromMap(map);

      expect(event.id, equals('42'));
      expect(event.title, equals('Show de Rock'));
      expect(event.description, equals('Banda ao vivo'));
      expect(event.categoryId, equals(2));
      expect(event.latitude, equals(-23.5505));
      expect(event.longitude, equals(-46.6333));
      expect(event.userId, equals('uuid-123'));
      expect(event.photoUrl, equals('https://example.com/foto.jpg'));
      expect(event.createdAt, isNotNull);
      expect(event.inActivity, isTrue);
    });

    test('Usa valores padrão quando campos estão ausentes', () {
      final event = Event.fromMap({
        'latitude_event': 0.0,
        'longitude_event': 0.0,
      });

      expect(event.id, isNull);
      expect(event.title, equals(''));
      expect(event.description, equals(''));
      expect(event.categoryId, equals(0));
      expect(event.userId, equals(''));
      expect(event.photoUrl, isNull);
      expect(event.createdAt, isNull);
      expect(event.inActivity, isTrue); // default
    });
  });

  group('Event.toMap', () {
    test('Converte Event em mapa corretamente', () {
      final event = Event(
        title: 'Feira',
        description: 'Feira de artesanato',
        categoryId: 4,
        latitude: -23.0,
        longitude: -46.0,
        userId: 'uuid-abc',
        photoUrl: null,
      );

      final map = event.toMap();

      expect(map['title'], equals('Feira'));
      expect(map['description'], equals('Feira de artesanato'));
      expect(map['interest_category'], equals(4));
      expect(map['latitude_event'], equals(-23.0));
      expect(map['longitude_event'], equals(-46.0));
      expect(map['user_creator'], equals('uuid-abc'));
      expect(map['photo_event'], isNull);
      expect(map.containsKey('id'), isFalse); // id nulo não é incluído
    });

    test('Inclui id quando não for nulo', () {
      final event = Event(
        id: '99',
        title: 'Tecnologia',
        description: '',
        categoryId: 5,
        latitude: 0,
        longitude: 0,
        userId: 'uuid',
      );

      final map = event.toMap();
      expect(map['id'], equals('99'));
    });
  });
}
