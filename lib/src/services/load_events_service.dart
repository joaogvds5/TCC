import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Modelo de evento para o mapa
class EventModel {
  final String id;
  final String title;
  final String description;
  final int category;
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['interest_category'] ?? 0,
      latitude: (map['latitude_event'] as num).toDouble(),
      longitude: (map['longitude_event'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

/// Cluster de eventos próximos
class EventCluster {
  final EventModel mainEvent;
  final List<EventModel> events;

  EventCluster({required this.mainEvent, required this.events});

  int get heatScore => events.length;

  double get intensity {
    if (heatScore >= 10) return 1.0;
    return heatScore / 10.0;
  }
}

/// Serviço de carregamento e clusterização de eventos
class LoadEventsService {
  final SupabaseClient _client = Supabase.instance.client;

  static const double proximityThreshold = 0.02;

  Future<List<EventCluster>> loadEvents() async {
    try {
      final response = await _client
          .from('active_events')
          .select()
          .order('created_at', ascending: false);

      final List data = response as List;
      final events = data.map((e) => EventModel.fromMap(e)).toList();

      return _clusterEvents(events);
    } catch (e) {
      debugPrint('Erro ao carregar eventos: $e');
      return [];
    }
  }

  List<EventCluster> _clusterEvents(List<EventModel> events) {
    final List<EventCluster> clusters = [];

    for (var event in events) {
      bool added = false;

      for (int i = 0; i < clusters.length; i++) {
        if (_isClose(event, clusters[i].mainEvent)) {
          final updatedEvents = [...clusters[i].events, event];

          final newMain =
              event.createdAt.isAfter(clusters[i].mainEvent.createdAt)
              ? event
              : clusters[i].mainEvent;

          clusters[i] = EventCluster(mainEvent: newMain, events: updatedEvents);

          added = true;
          break;
        }
      }

      if (!added) {
        clusters.add(EventCluster(mainEvent: event, events: [event]));
      }
    }

    return clusters;
  }

  bool _isClose(EventModel a, EventModel b) {
    final latDiff = (a.latitude - b.latitude).abs();
    final lonDiff = (a.longitude - b.longitude).abs();
    return latDiff <= proximityThreshold && lonDiff <= proximityThreshold;
  }
}
