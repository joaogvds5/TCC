import 'package:flutter_test/flutter_test.dart';
import 'package:nearu/src/models/profile.dart';

void main() {
  group('Profile.fromMap', () {
    test('Converte mapa completo em Profile', () {
      final map = {
        'user_id': 'uuid-123',
        'name': 'João Silva',
        'biography': 'Desenvolvedor',
        'birth_date': '1995-05-15',
        'photo_user': 'https://example.com/photo.jpg',
        'telephone': '(11) 99999-9999',
        'email': 'joao@email.com',
        'created_at': '2024-01-01T10:00:00Z',
      };

      final profile = Profile.fromMap(map);

      expect(profile.userUuid, equals('uuid-123'));
      expect(profile.name, equals('João Silva'));
      expect(profile.biography, equals('Desenvolvedor'));
      expect(profile.birthDate, equals(DateTime(1995, 5, 15)));
      expect(profile.email, equals('joao@email.com'));
      expect(profile.telephone, equals('(11) 99999-9999'));
    });

    test('Lida com campos nulos', () {
      final profile = Profile.fromMap({'user_id': 'uuid-123'});

      expect(profile.name, equals(''));
      expect(profile.biography, isNull);
      expect(profile.birthDate, isNull);
      expect(profile.photoUrl, isNull);
    });

    test('Converte interesses corretamente', () {
      final map = {
        'user_id': 'uuid-123',
        'name': 'Maria',
        'user_interest': [
          {
            'interest': {'id': 1, 'title': 'Música', 'icon': 'music'},
          },
          {
            'interest': {'id': 2, 'title': 'Esporte', 'icon': 'sports'},
          },
        ],
      };

      final profile = Profile.fromMap(map);

      expect(profile.interests, isNotNull);
      expect(profile.interests!.length, equals(2));
      expect(profile.interests![0].name, equals('Música'));
      expect(profile.interests![1].name, equals('Esporte'));
    });
  });

  group('Profile.initials', () {
    test('Retorna 2 iniciais para nome composto', () {
      final profile = Profile(userUuid: 'uuid', name: 'João Silva');
      expect(profile.initials, equals('JS'));
    });

    test('Retorna 1 inicial para nome simples', () {
      final profile = Profile(userUuid: 'uuid', name: 'João');
      expect(profile.initials, equals('J'));
    });

    test('Retorna ? para nome vazio', () {
      final profile = Profile(userUuid: 'uuid', name: '');
      expect(profile.initials, equals('?'));
    });
  });

  group('Profile.age', () {
    test('Calcula idade a partir da data de nascimento', () {
      final profile = Profile(
        userUuid: 'uuid',
        name: 'João',
        birthDate: DateTime(1995, 5, 15),
      );
      expect(profile.age, isNotNull);
      expect(profile.age!, greaterThanOrEqualTo(29));
    });

    test('Retorna null quando birthDate é null', () {
      final profile = Profile(userUuid: 'uuid', name: 'João');
      expect(profile.age, isNull);
    });
  });

  group('Profile.copyWith', () {
    test('Cria cópia com campos atualizados', () {
      final original = Profile(userUuid: 'uuid', name: 'Antigo');
      final updated = original.copyWith(name: 'Novo');

      expect(updated.name, equals('Novo'));
      expect(updated.userUuid, equals('uuid'));
    });

    test('Mantém campos originais quando não especificados', () {
      final original = Profile(
        userUuid: 'uuid',
        name: 'Original',
        biography: 'Bio',
      );
      final updated = original.copyWith(name: 'Novo');

      expect(updated.biography, equals('Bio'));
    });
  });
}
