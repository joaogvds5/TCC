// test/models/interest_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:nearu/src/models/interest.dart';

void main() {
  group('Interest.fromMap', () {
    test('usa "title"', () {
      final i = Interest.fromMap({
        'id': 1,
        'title': 'Música',
        'icon': 'music_note',
      });
      expect(i.id, 1);
      expect(i.name, 'Música');
      expect(i.icon, 'music_note');
    });

    test('cai para "interest_id"/"name"', () {
      final i = Interest.fromMap({'interest_id': 2, 'name': 'Tecnologia'});
      expect(i.id, 2);
      expect(i.name, 'Tecnologia');
    });

    test('mapa vazio retorna defaults', () {
      final i = Interest.fromMap({});
      expect(i.id, 0);
      expect(i.name, '');
      expect(i.icon, isNull);
    });

    test('parseia todos os ícones novos', () {
      final cases = {
        1: ('Música', 'music_note'),
        2: ('Tecnologia', 'computer'),
        3: ('Comida', 'restaurant'),
        4: ('Natureza', 'park'),
        5: ('Cultura', 'theater_comedy'),
        6: ('Viagem', 'flight'),
        7: ('Estudar', 'school'),
        8: ('Outros', 'category'),
      };
      cases.forEach((id, pair) {
        final i = Interest.fromMap({
          'id': id,
          'title': pair.$1,
          'icon': pair.$2,
        });
        expect(i.id, id);
        expect(i.name, pair.$1);
        expect(i.icon, pair.$2);
      });
    });
  });

  group('Interest equality', () {
    test('mesmo id = iguais', () {
      final a = Interest(id: 3, name: 'Comida');
      final b = Interest(id: 3, name: 'Comida (renomeado)');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('ids diferentes = não iguais', () {
      expect(
        Interest(id: 1, name: 'X'),
        isNot(equals(Interest(id: 2, name: 'X'))),
      );
    });
  });

  test('toMap', () {
    final i = Interest(id: 3, name: 'Comida', icon: 'restaurant');
    final map = i.toMap();
    expect(map['id'], 3);
    expect(map['title'], 'Comida');
    expect(map['icon'], 'restaurant');
  });

  test('toString contém id e name', () {
    final i = Interest(id: 5, name: 'Cultura');
    expect(i.toString(), contains('5'));
    expect(i.toString(), contains('Cultura'));
  });
}
