// test/unit/services/people_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:nearu/src/models/people.dart';
import 'package:nearu/src/models/interest.dart';

class FakePeopleService {
  final List<People> _peopleDatabase = [];
  final Map<int, People> _byId = {};
  int _nextId = 1;
  bool shouldThrowOnGet = false;
  bool shouldThrowOnCreate = false;
  bool shouldThrowOnDelete = false;
  int? lastDeletedId;

  Future<List<People>> getPeople() async {
    if (shouldThrowOnGet) throw Exception('Erro ao buscar pessoas');
    return List.unmodifiable(_peopleDatabase);
  }

  Future<void> createPeople(People people) async {
    if (shouldThrowOnCreate) throw Exception('Erro ao criar pessoa');
    _peopleDatabase.add(people);
    _byId[_nextId++] = people; // armazena com ID
  }

  Future<void> deletePeople(int id) async {
    if (shouldThrowOnDelete) throw Exception('Erro ao deletar pessoa');
    lastDeletedId = id;

    final person = _byId.remove(id);
    if (person != null) {
      _peopleDatabase.remove(person);
    }
  }
}

People _buildPeople({
  String name = 'João Silva',
  String biography = 'Desenvolvedor',
  DateTime? birthDate,
}) {
  return People(
    name: name,
    biography: biography,
    birthDate: birthDate ?? DateTime(1995, 5, 15),
    photoUrl: null,
    interest: Interest(id: 1, name: 'Música', icon: 'music_note'),
  );
}

void main() {
  late FakePeopleService service;

  setUp(() {
    service = FakePeopleService();
  });
  group('PeopleService - getPeople', () {
    test('Retorna lista vazia quando não há pessoas cadastradas', () async {
      final result = await service.getPeople();
      expect(result, isEmpty);
    });

    test('Retorna lista com pessoas cadastradas', () async {
      // Arrange
      await service.createPeople(_buildPeople(name: 'Maria'));
      await service.createPeople(_buildPeople(name: 'José'));

      final result = await service.getPeople();

      expect(result.length, equals(2));
      expect(result[0].name, equals('Maria'));
      expect(result[1].name, equals('José'));
    });

    test('Lança exceção quando a busca falha', () async {
      service.shouldThrowOnGet = true;

      expect(() => service.getPeople(), throwsA(isA<Exception>()));
    });
  });
  group('PeopleService - createPeople', () {
    test('Cria uma pessoa com sucesso', () async {
      final person = _buildPeople(name: 'Ana');

      await service.createPeople(person);
      final result = await service.getPeople();

      expect(result.length, equals(1));
      expect(result.first.name, equals('Ana'));
    });

    test('Cria múltiplas pessoas', () async {
      await service.createPeople(_buildPeople(name: 'Ana'));
      await service.createPeople(_buildPeople(name: 'Bruno'));
      await service.createPeople(_buildPeople(name: 'Carla'));

      final result = await service.getPeople();

      expect(result.length, equals(3));
      expect(
        result.map((p) => p.name).toList(),
        equals(['Ana', 'Bruno', 'Carla']),
      );
    });

    test('Lança exceção quando a criação falha', () async {
      service.shouldThrowOnCreate = true;

      expect(
        () => service.createPeople(_buildPeople()),
        throwsA(isA<Exception>()),
      );
    });

    test('Pessoa criada mantém os dados originais', () async {
      final birthDate = DateTime(2000, 1, 1);
      final person = _buildPeople(
        name: 'Pedro',
        biography: 'Estudante',
        birthDate: birthDate,
      );

      await service.createPeople(person);
      final result = await service.getPeople();

      expect(result.first.name, equals('Pedro'));
      expect(result.first.biography, equals('Estudante'));
      expect(result.first.birthDate, equals(birthDate));
    });
  });

  group('PeopleService - deletePeople', () {
    test('Deleta uma pessoa por ID', () async {
      await service.createPeople(_buildPeople(name: 'Ana'));
      final id = 123;
      await service.deletePeople(id);
      expect(service.lastDeletedId, equals(id));
    });

    test('Lança exceção quando a deleção falha', () async {
      // Arrange
      service.shouldThrowOnDelete = true;

      expect(() => service.deletePeople(1), throwsA(isA<Exception>()));
    });

    test('Chama deletePeople com o ID correto', () async {
      // Act
      await service.deletePeople(42);

      expect(service.lastDeletedId, equals(42));
    });
  });

  group('PeopleService - Fluxo completo', () {
    test('Criar, listar e deletar pessoas', () async {
      final person = _buildPeople(name: 'Lucas');

      await service.createPeople(person);
      final afterCreate = await service.getPeople();
      expect(afterCreate.length, equals(1));

      await service.deletePeople(1);
      final afterDelete = await service.getPeople();

      expect(afterDelete, isEmpty);
    });
  });
}
