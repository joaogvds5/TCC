import 'package:flutter_test/flutter_test.dart';
import 'package:nearu/src/models/event.dart';
import 'package:nearu/src/services/load_events_service.dart';
import 'package:nearu/src/widgets/map_marker_style.dart';

/// Simula a lógica de filtro do HomeController (sem Supabase).
class FakeHomeController {
  List<EventCluster> clusters = [];
  List<EventCluster> allClusters = [];
  String selectedCategory = 'Todos';

  void setEvents(List<EventCluster> events) {
    allClusters = events;
    _applyFilter();
  }

  void filterByCategory(String category) {
    selectedCategory = category;
    _applyFilter();
  }

  void _applyFilter() {
    if (selectedCategory == 'Todos') {
      clusters = List.from(allClusters);
    } else {
      clusters = allClusters.where((cluster) {
        return MapMarkerStyle.getCategoryName(cluster.mainEvent.categoryId) ==
            selectedCategory;
      }).toList();
    }
  }
}

void main() {
  late FakeHomeController controller;

  EventCluster _cluster({int categoryId = 1, String id = '1'}) {
    final event = Event(
      id: id,
      title: 'Evento',
      description: '',
      categoryId: categoryId,
      latitude: -23.55,
      longitude: -46.63,
      userId: 'uuid',
      createdAt: DateTime(2024, 1, 1),
    );
    return EventCluster(mainEvent: event, events: [event]);
  }

  setUp(() {
    controller = FakeHomeController();
  });

  group('HomeController - Filtro por Categoria', () {
    test('Filtro "Todos" retorna todos os clusters', () {
      controller.setEvents([
        _cluster(categoryId: 1, id: '1'),
        _cluster(categoryId: 2, id: '2'),
        _cluster(categoryId: 3, id: '3'),
      ]);

      controller.filterByCategory('Todos');
      expect(controller.clusters.length, equals(3));
    });

    test(
      'Filtro por categoria específica retorna apenas os correspondentes',
      () {
        controller.setEvents([
          _cluster(categoryId: 2, id: '1'),
          _cluster(categoryId: 2, id: '2'),
          _cluster(categoryId: 3, id: '3'),
        ]);

        controller.filterByCategory('Música');
        expect(controller.clusters.length, equals(2));
      },
    );

    test('Filtro por categoria sem eventos retorna vazio', () {
      controller.setEvents([
        _cluster(categoryId: 1, id: '1'),
        _cluster(categoryId: 2, id: '2'),
      ]);

      controller.filterByCategory('Tecnologia');
      expect(controller.clusters, isEmpty);
    });

    test('Voltar para "Todos" após filtrar restaura lista completa', () {
      controller.setEvents([
        _cluster(categoryId: 1, id: '1'),
        _cluster(categoryId: 2, id: '2'),
      ]);

      controller.filterByCategory('Música');
      expect(controller.clusters.length, equals(1));

      controller.filterByCategory('Todos');
      expect(controller.clusters.length, equals(2));
    });
  });

  group('MapMarkerStyle', () {
    test('getCategoryName retorna nomes corretos', () {
      expect(MapMarkerStyle.getCategoryName(1), equals('Evento'));
      expect(MapMarkerStyle.getCategoryName(2), equals('Música'));
      expect(MapMarkerStyle.getCategoryName(3), equals('Esporte'));
      expect(MapMarkerStyle.getCategoryName(4), equals('Feira'));
      expect(MapMarkerStyle.getCategoryName(5), equals('Tecnologia'));
      expect(MapMarkerStyle.getCategoryName(99), equals('Outro'));
    });

    test('getCategoryColor retorna cor padrão para categoria desconhecida', () {
      expect(
        MapMarkerStyle.getCategoryColor(99),
        equals(MapMarkerStyle.defaultCategoryColor),
      );
    });

    test('getHeatOpacity retorna opacidades corretas', () {
      expect(MapMarkerStyle.getHeatOpacity(0.1), equals(0.5));
      expect(MapMarkerStyle.getHeatOpacity(0.5), equals(0.75));
      expect(MapMarkerStyle.getHeatOpacity(0.9), equals(1.0));
    });
  });
}
