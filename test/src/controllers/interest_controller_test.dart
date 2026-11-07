// test/controllers/interest_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nearu/src/controllers/interest_controller.dart';
import 'package:nearu/src/models/interest.dart';
import 'package:nearu/src/services/interest_service.dart';

class MockInterestService extends Mock implements InterestService {}

List<Interest> _catalog() => [
  Interest(id: 1, name: 'Música', icon: 'music_note'),
  Interest(id: 2, name: 'Tecnologia', icon: 'computer'),
  Interest(id: 3, name: 'Comida', icon: 'restaurant'),
  Interest(id: 4, name: 'Natureza', icon: 'park'),
  Interest(id: 5, name: 'Cultura', icon: 'theater_comedy'),
  Interest(id: 6, name: 'Viagem', icon: 'flight'),
  Interest(id: 7, name: 'Estudar', icon: 'school'),
  Interest(id: 8, name: 'Outros', icon: 'category'),
];

void main() {
  late MockInterestService mockService;

  setUp(() {
    mockService = MockInterestService();
    registerFallbackValue(<int>{});
  });

  InterestController _c() => InterestController(service: mockService);

  group('load', () {
    test('popula catálogo e seleção', () async {
      when(
        () => mockService.getAllInterests(),
      ).thenAnswer((_) async => _catalog());
      when(
        () => mockService.getUserInterestIds('u1'),
      ).thenAnswer((_) async => {1, 3, 6});

      final c = _c();
      await c.load(userUuid: 'u1');

      expect(c.allInterests.length, 8);
      expect(c.allInterests.map((i) => i.name).toList(), [
        'Música',
        'Tecnologia',
        'Comida',
        'Natureza',
        'Cultura',
        'Viagem',
        'Estudar',
        'Outros',
      ]);
      expect(c.selectedIds, {1, 3, 6});
      expect(c.isSelected(1), isTrue);
      expect(c.isSelected(2), isFalse);
      expect(c.isLoading, isFalse);
      expect(c.error, isNull);
    });

    test('define error em exceção', () async {
      when(() => mockService.getAllInterests()).thenThrow(Exception('boom'));

      final c = _c();
      await c.load(userUuid: 'u1');

      expect(c.error, 'Erro ao carregar interesses');
      expect(c.isLoading, isFalse);
    });
  });

  group('toggle', () {
    test('alterna os 8 interesses', () async {
      when(
        () => mockService.getAllInterests(),
      ).thenAnswer((_) async => _catalog());
      when(
        () => mockService.getUserInterestIds('u1'),
      ).thenAnswer((_) async => <int>{});

      final c = _c();
      await c.load(userUuid: 'u1');

      for (var id in [1, 2, 3, 4, 5, 6, 7, 8]) {
        c.toggle(id);
      }
      expect(c.selectedIds.length, 8);

      c.toggle(3);
      c.toggle(7);
      expect(c.selectedIds, {1, 2, 4, 5, 6, 8});
    });

    test('ignora IDs fora do catálogo quando carregado', () async {
      when(
        () => mockService.getAllInterests(),
      ).thenAnswer((_) async => _catalog());
      when(
        () => mockService.getUserInterestIds('u1'),
      ).thenAnswer((_) async => <int>{});

      final c = _c();
      await c.load(userUuid: 'u1');
      c.toggle(999);

      expect(c.isSelected(999), isFalse);
    });
  });

  group('save', () {
    test('persiste seleção atual', () async {
      when(
        () => mockService.setUserInterests(
          userUuid: any(named: 'userUuid'),
          interestIds: any(named: 'interestIds'),
        ),
      ).thenAnswer((_) async => true);

      final c = _c();
      c.setSelection({2, 5});

      final ok = await c.save(userUuid: 'u1');
      expect(ok, isTrue);

      final captured =
          verify(
                () => mockService.setUserInterests(
                  userUuid: 'u1',
                  interestIds: captureAny(named: 'interestIds'),
                ),
              ).captured.single
              as Set<int>;
      expect(captured, {2, 5});
    });

    test('envia conjunto vazio quando nada selecionado', () async {
      when(
        () => mockService.setUserInterests(
          userUuid: any(named: 'userUuid'),
          interestIds: any(named: 'interestIds'),
        ),
      ).thenAnswer((_) async => true);

      final c = _c();
      final ok = await c.save(userUuid: 'u1');

      expect(ok, isTrue);
      verify(
        () =>
            mockService.setUserInterests(userUuid: 'u1', interestIds: <int>{}),
      ).called(1);
    });

    test('retorna false em exceção', () async {
      when(
        () => mockService.setUserInterests(
          userUuid: any(named: 'userUuid'),
          interestIds: any(named: 'interestIds'),
        ),
      ).thenThrow(Exception('x'));

      final c = _c();
      final ok = await c.save(userUuid: 'u1');

      expect(ok, isFalse);
      expect(c.error, 'Erro ao salvar interesses');
    });
  });

  test('setSelection sobrescreve seleção', () {
    final c = _c();
    c.setSelection({1, 2});
    expect(c.selectedIds, {1, 2});
  });
}
