import 'package:flutter_test/flutter_test.dart';
import 'package:nearu/src/models/interest.dart';

void main() {
  group('Interest.fromMap', () {
    test('Converte mapa completo', () {
      final interest = Interest.fromMap({
        'id': 1,
        'title': 'Música',
        'icon': 'music_note',
      });

      expect(interest.id, equals(1));
      expect(interest.name, equals('Música'));
      expect(interest.icon, equals('music_note'));
    });

    test('Usa interest_id como fallback de id', () {
      final interest = Interest.fromMap({'interest_id': 5, 'name': 'Esporte'});

      expect(interest.id, equals(5));
      expect(interest.name, equals('Esporte'));
    });

    test('Usa valores padrão quando campos ausentes', () {
      final interest = Interest.fromMap({});
      expect(interest.id, equals(0));
      expect(interest.name, equals(''));
      expect(interest.icon, isNull);
    });
  });

  group('Interest.toMap', () {
    test('Converte Interest em mapa', () {
      final interest = Interest(id: 2, name: 'Feira', icon: 'store');
      final map = interest.toMap();

      expect(map['id'], equals(2));
      expect(map['title'], equals('Feira'));
      expect(map['icon'], equals('store'));
    });
  });

  group('Interest.toString', () {
    test('Retorna representação legível', () {
      final interest = Interest(id: 3, name: 'Tecnologia');
      expect(interest.toString(), contains('Tecnologia'));
    });
  });
}
