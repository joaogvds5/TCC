import 'package:flutter_test/flutter_test.dart';
import 'package:nearu/src/controllers/event_controller.dart';

/// Simula a lógica de validação do EventController sem Supabase.
class FakeEventController {
  Future<String?> createEvent({
    required String title,
    required String description,
    required int categoryId,
    required double latitude,
    required double longitude,
    dynamic photoBytes,
  }) async {
    // Simula falha se título vazio
    if (title.trim().isEmpty) return null;

    // Simula falha se coordenadas inválidas
    if (latitude < -90 || latitude > 90) return null;
    if (longitude < -180 || longitude > 180) return null;

    // Sucesso: retorna id fake
    return 'event-123';
  }
}

void main() {
  late FakeEventController controller;

  setUp(() {
    controller = FakeEventController();
  });

  group('EventController - Criação de Evento', () {
    test('Retorna ID ao criar evento com dados válidos', () async {
      final id = await controller.createEvent(
        title: 'Show',
        description: 'Banda',
        categoryId: 2,
        latitude: -23.55,
        longitude: -46.63,
      );

      expect(id, equals('event-123'));
    });

    test('Retorna null quando título está vazio', () async {
      final id = await controller.createEvent(
        title: '',
        description: '',
        categoryId: 1,
        latitude: -23.55,
        longitude: -46.63,
      );

      expect(id, isNull);
    });

    test('Retorna null quando latitude é inválida', () async {
      final id = await controller.createEvent(
        title: 'Evento',
        description: '',
        categoryId: 1,
        latitude: 100.0, // inválido
        longitude: -46.63,
      );

      expect(id, isNull);
    });

    test('Retorna null quando longitude é inválida', () async {
      final id = await controller.createEvent(
        title: 'Evento',
        description: '',
        categoryId: 1,
        latitude: -23.55,
        longitude: 200.0, // inválido
      );

      expect(id, isNull);
    });

    test('Aceita latitude de -90 a 90', () async {
      final id1 = await controller.createEvent(
        title: 'Evento',
        description: '',
        categoryId: 1,
        latitude: -90,
        longitude: 0,
      );
      expect(id1, isNotNull);

      final id2 = await controller.createEvent(
        title: 'Evento',
        description: '',
        categoryId: 1,
        latitude: 90,
        longitude: 0,
      );
      expect(id2, isNotNull);
    });
  });

  group('UnauthenticatedException', () {
    test('Exceção com mensagem padrão', () {
      final ex = UnauthenticatedException();
      expect(ex.message, equals('Usuário não autenticado'));
    });

    test('Exceção com mensagem customizada', () {
      final ex = UnauthenticatedException('Login necessário');
      expect(ex.toString(), equals('Login necessário'));
    });
  });
}
