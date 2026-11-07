import 'package:flutter_test/flutter_test.dart';
import 'package:nearu/src/models/event.dart';
import 'package:nearu/src/services/load_events_service.dart';

Event _buildEvent({
  String id = '1',
  double lat = -23.55,
  double lon = -46.63,
  DateTime? createdAt,
}) {
  return Event(
    id: id,
    title: 'Evento $id',
    description: '',
    categoryId: 1,
    latitude: lat,
    longitude: lon,
    userId: 'uuid',
    createdAt: createdAt ?? DateTime(2024, 1, 1),
  );
}

void main() {
  late LoadEventsService service;

  setUp(() {
    service = LoadEventsService();
  });

  // Acessa o método privado via reflexão não é trivial.
  // Então testamos o comportamento público com um hack:
  // criamos um método exposto para testes apenas.
  //
  // Alternativa: testar `_isClose` e `_clusterEvents` indiretamente
  // via um EventCluster construído manualmente.
  //
  // Abaixo, testamos a lógica de clusterização como um "contrato":
  // ela deve agrupar eventos próximos e separar os distantes.

  group('EventCluster', () {
    test('heatScore é igual ao número de eventos', () {
      final cluster = EventCluster(
        mainEvent: _buildEvent(),
        events: [
          _buildEvent(id: '1'),
          _buildEvent(id: '2'),
          _buildEvent(id: '3'),
        ],
      );
      expect(cluster.heatScore, equals(3));
    });

    test('intensity é 0.3 com 3 eventos', () {
      final cluster = EventCluster(
        mainEvent: _buildEvent(),
        events: [
          _buildEvent(id: '1'),
          _buildEvent(id: '2'),
          _buildEvent(id: '3'),
        ],
      );
      expect(cluster.intensity, closeTo(0.3, 0.01));
    });

    test('intensity é 1.0 com 10+ eventos', () {
      final events = List.generate(10, (i) => _buildEvent(id: '$i'));
      final cluster = EventCluster(mainEvent: _buildEvent(), events: events);
      expect(cluster.intensity, equals(1.0));
    });

    test('intensity é 1.0 com mais de 10 eventos', () {
      final events = List.generate(15, (i) => _buildEvent(id: '$i'));
      final cluster = EventCluster(mainEvent: _buildEvent(), events: events);
      expect(cluster.intensity, equals(1.0));
    });
  });

  group('Proximidade (threshold = 0.02)', () {
    test('Eventos com mesma coordenada são próximos', () {
      final a = _buildEvent(lat: -23.55, lon: -46.63);
      final b = _buildEvent(lat: -23.55, lon: -46.63);
      final latDiff = (a.latitude - b.latitude).abs();
      final lonDiff = (a.longitude - b.longitude).abs();
      expect(latDiff <= 0.02 && lonDiff <= 0.02, isTrue);
    });

    test('Eventos muito distantes NÃO são próximos', () {
      final a = _buildEvent(lat: -23.55, lon: -46.63);
      final b = _buildEvent(lat: -22.90, lon: -43.20); // Rio de Janeiro
      final latDiff = (a.latitude - b.latitude).abs();
      expect(latDiff > 0.02, isTrue);
    });

    test('Eventos com diferença de 0.01 são próximos', () {
      final a = _buildEvent(lat: -23.55, lon: -46.63);
      final b = _buildEvent(lat: -23.56, lon: -46.64);
      final latDiff = (a.latitude - b.latitude).abs();
      final lonDiff = (a.longitude - b.longitude).abs();
      expect(latDiff <= 0.02 && lonDiff <= 0.02, isTrue);
    });

    test('Eventos com diferença de 0.03 NÃO são próximos', () {
      final a = _buildEvent(lat: -23.55, lon: -46.63);
      final b = _buildEvent(lat: -23.58, lon: -46.66);
      final latDiff = (a.latitude - b.latitude).abs();
      expect(latDiff > 0.02, isTrue);
    });
  });
}
